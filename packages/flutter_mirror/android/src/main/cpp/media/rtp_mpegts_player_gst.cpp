#include "rtp_mpegts_player_gst.h"

#include <cstring>
#include <future>
#include "log.h"

namespace {
static std::once_flag g_gst_once;
}

static void on_element_added(GstBin* bin, GstElement* element, gpointer user_data) {
  const gchar* element_name = gst_element_get_name(element);
  const gchar* factory_name = gst_plugin_feature_get_name(
      GST_PLUGIN_FEATURE(gst_element_get_factory(element)));

  ALOGI("decodebin added element: %s (factory: %s)", element_name, factory_name);

  // 特別留意解碼器
  if (strstr(factory_name, "dec") || strstr(factory_name, "decoder")) {
    ALOGI("*** DECODER SELECTED: %s ***", factory_name);
  }
}

RtpMpegTsPlayerGst::RtpMpegTsPlayerGst() {
  std::call_once(
      g_gst_once,
      []() {
        int argc = 0;
        char** argv = nullptr;
        gst_init(&argc, &argv);
        gst_debug_set_default_threshold(GST_LEVEL_WARNING);
        gst_debug_remove_log_function(gst_debug_log_default);
        gst_debug_add_log_function(android_log_function, NULL, NULL);
      });
}

RtpMpegTsPlayerGst::~RtpMpegTsPlayerGst() {
  Stop();
}

bool RtpMpegTsPlayerGst::Start() {
  GstRegistry* registry = gst_registry_get();
  GstPluginFeature* f = gst_registry_find_feature(registry, "avdec_h264", GST_TYPE_ELEMENT_FACTORY);
  if (f) {
    gst_plugin_feature_set_rank(f, GST_RANK_NONE);
    gst_object_unref(f);
  }

  std::lock_guard<std::mutex> lock(mutex_);
  if (playing_) {
    return true;
  }
  EnsurePipeline();
  if (!pipeline_) {
    return false;
  }

  if (native_window_ != nullptr) {
    AttachOverlay();
  }
  GstStateChangeReturn ret = gst_element_set_state(pipeline_, GST_STATE_PLAYING);
  if (ret == GST_STATE_CHANGE_FAILURE) {
    TeardownPipeline();
    return false;
  }
  playing_ = true;
  return true;
}

void RtpMpegTsPlayerGst::Stop() {
  std::lock_guard<std::mutex> lock(mutex_);
  if (!playing_) {
    return;
  }
  if (pipeline_) {
    gst_element_set_state(pipeline_, GST_STATE_NULL);
  }
  if (loop_) {
    g_main_loop_quit(loop_);
  }
  if (loop_thread_.joinable()) {
    loop_thread_.join();
  }
  TeardownPipeline();
  playing_ = false;
}

uint16_t RtpMpegTsPlayerGst::GetPort() const {
  std::lock_guard<std::mutex> lock(mutex_);
  return bound_port_;
}

void RtpMpegTsPlayerGst::SetSurface(JNIEnv* env, jobject surface) {
  std::lock_guard<std::mutex> lock(mutex_);
  if (native_window_) {
    ANativeWindow_release(native_window_);
    native_window_ = nullptr;
  }
  if (surface) {
    native_window_ = ANativeWindow_fromSurface(env, surface);
  }
  if (pipeline_ && video_sink_) {
    AttachOverlay();
  }
}

void RtpMpegTsPlayerGst::OnBusMessage(GstBus* bus, GstMessage* message, gpointer user_data) {
  RtpMpegTsPlayerGst* self = static_cast<RtpMpegTsPlayerGst*>(user_data);
  if (!self) {
    return;
  }
  self->HandleBusMessage(message);
}

void RtpMpegTsPlayerGst::OnDemuxPadAdded(GstElement* element, GstPad* pad, gpointer user_data) {
  RtpMpegTsPlayerGst* self = static_cast<RtpMpegTsPlayerGst*>(user_data);

  gchar* pad_name = gst_pad_get_name(pad);
  ALOGW("TSdemux pad added: %s", pad_name);

  GstCaps* caps = gst_pad_get_current_caps(pad);
  if (caps) {
    gchar* caps_str = gst_caps_to_string(caps);
    ALOGW("TSdemux pad caps: %s", caps_str);

    const GstStructure* s = gst_caps_get_structure(caps, 0);
    const gchar* name = gst_structure_get_name(s);

    ALOGI("Structure name: %s", name);

    // 檢查是否為音頻
    if (g_str_has_prefix(name, "audio/")) {
      ALOGI("Found audio pad, connecting...");
      self->ConnectAudioPad(pad);
    } else if (g_str_has_prefix(name, "video/")) {
      ALOGW("Found video pad, connecting...");
      self->ConnectVideoPad(pad);
    } else {
      ALOGI("Unknown pad type: %s", name);
    }

    g_free(caps_str);
    gst_caps_unref(caps);
  } else {
    ALOGE("No caps on pad %s", pad_name);
  }

  g_free(pad_name);
}

void RtpMpegTsPlayerGst::ConnectAudioPad(GstPad* pad) {
  GstElement* queue = gst_element_factory_make("queue", NULL);
  GstElement* aacparse = gst_element_factory_make("aacparse", NULL);
  GstElement* decoder = gst_element_factory_make("avdec_aac", NULL);
  GstElement* volume_convert = gst_element_factory_make("audioconvert", NULL);
  volume_ = gst_element_factory_make("volume", "volume");
  GstElement* convert = gst_element_factory_make("audioconvert", NULL);
  GstElement* resample = gst_element_factory_make("audioresample", NULL);
  GstElement* sink = gst_element_factory_make("openslessink", NULL);

  if (!queue || !aacparse || !volume_convert || !volume_ || !decoder || !convert || !resample || !sink) {
    // cleanup if any element creation failed
    if (queue)
      gst_object_unref(queue);
    if (aacparse)
      gst_object_unref(aacparse);
    if (volume_convert)
      gst_object_unref(volume_convert);
    if (volume_)
      gst_object_unref(volume_);
    if (decoder)
      gst_object_unref(decoder);
    if (convert)
      gst_object_unref(convert);
    if (resample)
      gst_object_unref(resample);
    if (sink)
      gst_object_unref(sink);

    TeardownPipeline();
    return;
  }

#ifdef __arm__
  // ARM 32位元：使用較小的數值和明確轉型
  g_object_set(sink, "stream-type", 3, NULL);  // 只設定基本參數
#else
  // 64位元：可以使用完整參數
  g_object_set(sink,
               "stream-type", 3,
               "buffer-time", G_GINT64_CONSTANT(200000),
               "latency-time", G_GINT64_CONSTANT(20000),
               NULL);
#endif

  gst_bin_add_many(GST_BIN(pipeline_), queue, aacparse, decoder, volume_convert, volume_, convert, resample, sink, NULL);

  if (!gst_element_link_many(queue, aacparse, decoder, volume_convert, volume_, convert, resample, sink, NULL)) {
    ALOGE("Failed to link audio elements");
    TeardownPipeline();
    return;
  }

  GstPad* queue_sink_pad = gst_element_get_static_pad(queue, "sink");
  if (queue_sink_pad) {
    GstPadLinkReturn ret = gst_pad_link(pad, queue_sink_pad);
    if (ret != GST_PAD_LINK_OK) {
      ALOGE("Failed to link demux pad to audio queue");
      TeardownPipeline();
    }
    gst_object_unref(queue_sink_pad);
  }

  // 同步新元件的狀態
  gst_element_sync_state_with_parent(queue);
  gst_element_sync_state_with_parent(aacparse);
  gst_element_sync_state_with_parent(decoder);
  gst_element_sync_state_with_parent(volume_convert);
  gst_element_sync_state_with_parent(volume_);
  gst_element_sync_state_with_parent(convert);
  gst_element_sync_state_with_parent(resample);
  gst_element_sync_state_with_parent(sink);
}

void RtpMpegTsPlayerGst::SetMute(bool mute) {
  if (!volume_ || !GST_IS_ELEMENT(volume_)) {
    return;
  }
  g_object_set(volume_,
               "mute", mute,
               NULL);
}

void RtpMpegTsPlayerGst::ConnectVideoPad(GstPad* pad) {
  // queue_ = gst_element_factory_make("queue", "decode_queue");
  // GstElement* decodebin = gst_element_factory_make("decodebin", "decodebin");

  // if (!queue_ || !decodebin_) {
  //   ALOGE("Failed to create elements");
  //   TeardownPipeline();
  //   return;
  // }

  // g_object_set(queue_,
  //              "max-size-time", 1000 * GST_MSECOND,
  //              "leaky", 0,
  //              NULL);

  // gst_debug_set_threshold_for_name("decodebin", GST_LEVEL_LOG);

  // gst_bin_add_many(GST_BIN(pipeline_), queue_, decodebin_, NULL);
  gst_element_link(queue_, decodebin_);

  // decodebin 會自動選擇正確的 parser 和 decoder
  // g_signal_connect(decodebin, "pad-added", G_CALLBACK(RtpMpegTsPlayerGst::OnDecodebinPadAdded), this);
  // g_signal_connect(decodebin, "element-added", G_CALLBACK(on_element_added), nullptr);

  // 連接 demux pad 到 queue
  GstPad* queue_sink = gst_element_get_static_pad(queue_, "sink");
  gst_pad_link(pad, queue_sink);
  gst_object_unref(queue_sink);

  gst_element_sync_state_with_parent(queue_);
  gst_element_sync_state_with_parent(decodebin_);
}

void RtpMpegTsPlayerGst::OnDecodebinPadAdded(GstElement* decodebin, GstPad* pad, gpointer user_data) {
  ALOGW("Decodebin Pad added");
  RtpMpegTsPlayerGst* self = static_cast<RtpMpegTsPlayerGst*>(user_data);
  if (!self) {
    return;
  }

  gst_pad_add_probe(pad, GST_PAD_PROBE_TYPE_EVENT_DOWNSTREAM, OnCapsProbe, self, nullptr);  // get video size

  GstCaps* pad_caps = gst_pad_get_current_caps(pad);
  if (pad_caps) {
    gchar* caps_str = gst_caps_to_string(pad_caps);
    ALOGW("Decodebin output caps: %s", caps_str);
    g_free(caps_str);
    gst_caps_unref(pad_caps);
  }

  if (!self->video_sink_) {
    return;
  }

  GstState current_state, pending_state;
  gst_element_get_state(self->pipeline_, &current_state, &pending_state, 0);
  ALOGW("[PAD_ADDED] Pipeline current state: %s", gst_element_state_get_name(current_state));

  gst_element_sync_state_with_parent(self->video_sink_);

  GstPad* glimagesink_sinkpad = gst_element_get_static_pad(self->video_sink_, "sink");
  if (!glimagesink_sinkpad) {
    self->TeardownPipeline();
    return;
  }
  GstPadLinkReturn ret = gst_pad_link(pad, glimagesink_sinkpad);
  if (GST_PAD_LINK_FAILED(ret)) {
    self->TeardownPipeline();
    return;
  }
  gst_object_unref(glimagesink_sinkpad);

  GstClock* video_clock = gst_element_get_clock(self->video_sink_);
  gst_pipeline_use_clock(GST_PIPELINE(self->pipeline_), video_clock);
  gst_object_unref(video_clock);
  // gst_pipeline_set_latency(GST_PIPELINE(self->pipeline_), 400 * GST_MSECOND);

  GstStateChangeReturn pipe_state_ret = gst_element_set_state(self->pipeline_, GST_STATE_PLAYING);
  if (pipe_state_ret == GST_STATE_CHANGE_FAILURE) {
    self->TeardownPipeline();
    return;
  }

  gst_element_set_state(self->video_sink_, GST_STATE_PLAYING);
}

GstPadProbeReturn RtpMpegTsPlayerGst::OnCapsProbe(GstPad* pad, GstPadProbeInfo* info, gpointer user_data) {
  RtpMpegTsPlayerGst* self = static_cast<RtpMpegTsPlayerGst*>(user_data);
  if (!self) {
    return GST_PAD_PROBE_OK;
  }

  if (GST_PAD_PROBE_INFO_TYPE(info) & GST_PAD_PROBE_TYPE_EVENT_DOWNSTREAM) {
    GstEvent* event = GST_PAD_PROBE_INFO_EVENT(info);
    if (GST_EVENT_TYPE(event) == GST_EVENT_CAPS) {
      GstCaps* caps = NULL;
      gst_event_parse_caps(event, &caps);

      if (caps) {
        GstStructure* s = gst_caps_get_structure(caps, 0);
        int width = 0, height = 0;
        gst_structure_get_int(s, "width", &width);
        gst_structure_get_int(s, "height", &height);

        ALOGI("video size: %d x %d", width, height);
        self->NotifyVideoResolution(width, height);
      }
    }
  }
  return GST_PAD_PROBE_OK;
}

GstPadProbeReturn RtpMpegTsPlayerGst::OnDepayEvent(GstPad* pad, GstPadProbeInfo* info, gpointer user_data) {
  RtpMpegTsPlayerGst* self = static_cast<RtpMpegTsPlayerGst*>(user_data);
  if (!self) {
    return GST_PAD_PROBE_OK;
  }

  if (GST_PAD_PROBE_INFO_TYPE(info) & GST_PAD_PROBE_TYPE_EVENT_DOWNSTREAM) {
    GstEvent* event = GST_PAD_PROBE_INFO_EVENT(info);
    if (GST_EVENT_TYPE(event) == GST_EVENT_CUSTOM_DOWNSTREAM) {
      const GstStructure* s = gst_event_get_structure(event);
      if (gst_structure_has_name(s, "GstRTPPacketLost")) {
        guint seqnum = 0;
        guint ssrc = 0;
        gst_structure_get_uint(s, "seqnum", &seqnum);
        gst_structure_get_uint(s, "ssrc", &ssrc);
        ALOGD("Lost RTP packet (event)! SSRC=%u, Seq=%u\n", ssrc, seqnum);
        self->NotifyPacketLost();
      }
    }
  }
  return GST_PAD_PROBE_OK;
}

void RtpMpegTsPlayerGst::OnRtpbinPadAdded(GstElement* element, GstPad* pad, gpointer user_data) {
  RtpMpegTsPlayerGst* self = static_cast<RtpMpegTsPlayerGst*>(user_data);

  gchar* pad_name = gst_pad_get_name(pad);
  ALOGI("RTPbin pad added: %s", pad_name);

  // 檢查是否是 RTP source pad
  if (g_str_has_prefix(pad_name, "recv_rtp_src_")) {
    // 連接到 rtpmp2tdepay
    GstPad* depay_sink = gst_element_get_static_pad(self->depay_, "sink");
    if (depay_sink) {
      GstPadLinkReturn ret = gst_pad_link(pad, depay_sink);
      if (ret == GST_PAD_LINK_OK) {
        ALOGI("Successfully linked rtpbin to depay");
      } else {
        ALOGE("Failed to link rtpbin to depay: %d", ret);
      }

      gst_pad_add_probe(depay_sink, GST_PAD_PROBE_TYPE_EVENT_DOWNSTREAM, OnDepayEvent, self, nullptr);

      gst_object_unref(depay_sink);
    } else {
      ALOGE("Could not get depay sink pad");
    }
  }

  g_free(pad_name);
}

void RtpMpegTsPlayerGst::HandleBusMessage(GstMessage* message) {
  switch (GST_MESSAGE_TYPE(message)) {
    case GST_MESSAGE_ERROR: {
      GError* err = nullptr;
      gchar* dbg = nullptr;
      gst_message_parse_error(message, &err, &dbg);
      if (err) {
        g_error_free(err);
      }
      if (dbg) {
        g_free(dbg);
      }
      break;
    }
    case GST_MESSAGE_EOS: {
      break;
    }
    default: {
      break;
    }
  }
}

void RtpMpegTsPlayerGst::EnsurePipeline() {
  if (!gst_is_initialized()) {
    ALOGE("GStreamer not initialized!");
    return;
  }

  socket_ = CreateBoundSocket(0);
  if (!socket_) {
    return;
  }

  if (pipeline_) {
    ALOGI("pipeline_ is already created");
    return;
  }
  context_ = g_main_context_new();
  loop_ = g_main_loop_new(context_, FALSE);
  loop_thread_ = std::thread([this]() {
    g_main_context_push_thread_default(context_);
    g_main_loop_run(loop_);
    g_main_context_pop_thread_default(context_);
  });

  ALOGI("create pipeline");
  pipeline_ = gst_pipeline_new("rtp_mpegts_pipeline");
  if (!pipeline_) {
    ALOGI("create pipeline failed");
    return;
  }

  udpsrc_ = gst_element_factory_make("udpsrc", "udpsrc");
  rtpbin_ = gst_element_factory_make("rtpbin", "rtpbin");
  depay_ = gst_element_factory_make("rtpmp2tdepay", "depay");
  GstElement* tsparse = gst_element_factory_make("tsparse", "tsparse");
  GstElement* tsdemux = gst_element_factory_make("tsdemux", "tsdemux");
  queue_ = gst_element_factory_make("queue", "decode_queue");
  decodebin_ = gst_element_factory_make("decodebin", "decodebin");

  video_sink_ = gst_element_factory_make("glimagesink", "glimagesink");
  if (video_sink_) {
    g_object_set(video_sink_,
                 "sync", TRUE,
                 "async", FALSE,
                 "enable-last-sample", FALSE,
                 "force-aspect-ratio", FALSE,
                 NULL);

    AttachOverlay();
  }

  if (!udpsrc_)
    ALOGE("udpsrc is null");
  if (!rtpbin_)
    ALOGE("rtpbin is null");
  if (!depay_)
    ALOGE("rtpmp2tdepay is null");
  if (!tsparse)
    ALOGE("tsparse is null");
  if (!tsdemux)
    ALOGE("tsdemux is null");
  if (!decodebin_)
    ALOGE("decodebin is null");

  if (!udpsrc_ || !rtpbin_ || !depay_ || !tsparse || !tsdemux || !queue_ || !decodebin_) {
    ALOGE("something is null -> teardown");
    TeardownPipeline();
    return;
  }

  g_object_set(queue_,
               "max-size-time", 1000 * GST_MSECOND,
               "leaky", 0,
               NULL);

  g_signal_connect(decodebin_, "pad-added", G_CALLBACK(RtpMpegTsPlayerGst::OnDecodebinPadAdded), this);
  g_signal_connect(decodebin_, "element-added", G_CALLBACK(on_element_added), nullptr);

  g_object_set(rtpbin_,
               "do-lost", TRUE,
               "latency", 500,
               //  "drop-on-latency", TRUE,
               NULL);

  GST_DEBUG("Testing debug output - this should appear in logcat");

  gst_debug_set_threshold_for_name("udpsrc", GST_LEVEL_WARNING);
  gst_debug_set_threshold_for_name("rtpbin", GST_LEVEL_LOG);
  gst_debug_set_threshold_for_name("rtpjitterbuffer", GST_LEVEL_LOG);
  gst_debug_set_threshold_for_name("rtpmp2tdepay", GST_LEVEL_LOG);
  gst_debug_set_threshold_for_name("tsparse", GST_LEVEL_LOG);
  gst_debug_set_threshold_for_name("tsdemux", GST_LEVEL_LOG);
  gst_debug_set_threshold_for_name("decodebin", GST_LEVEL_LOG);
  gst_debug_set_threshold_for_name("glupload", GST_LEVEL_LOG);
  gst_debug_set_threshold_for_name("glcolorconvert", GST_LEVEL_LOG);
  gst_debug_set_threshold_for_name("queue", GST_LEVEL_LOG);
  gst_debug_set_threshold_for_name("glimagesink", GST_LEVEL_LOG);
  gst_debug_set_threshold_for_name("gldebug", GST_LEVEL_LOG);
  gst_debug_set_threshold_for_name("glwindow", GST_LEVEL_LOG);
  gst_debug_set_threshold_for_name("opengl", GST_LEVEL_LOG);
  gst_debug_set_threshold_for_name("glcontext", GST_LEVEL_LOG);

  g_object_set(udpsrc_,
               "socket", socket_,
               "buffer-size", 4194304,
               NULL);

  gst_bin_add_many(GST_BIN(pipeline_), udpsrc_, rtpbin_, depay_, tsparse, tsdemux, queue_, decodebin_, NULL);

  if (!gst_bin_add(GST_BIN(pipeline_), video_sink_)) {
    TeardownPipeline();
    return;
  }

  rtpbin_rtp_sink_pad_ = gst_element_get_request_pad(rtpbin_, "recv_rtp_sink_0");
  GstPad* udp_src_pad = gst_element_get_static_pad(udpsrc_, "src");
  if (!rtpbin_rtp_sink_pad_ || !udp_src_pad) {
    if (rtpbin_rtp_sink_pad_) {
      ALOGE("udp_src_pad is null");
    }
    if (udp_src_pad) {
      ALOGE("rtpbin_rtp_sink_pad_ is null");
      gst_object_unref(udp_src_pad);
    }
    TeardownPipeline();
    return;
  }

  GstPadLinkReturn udplink = gst_pad_link(udp_src_pad, rtpbin_rtp_sink_pad_);
  gst_object_unref(udp_src_pad);
  if (udplink != GST_PAD_LINK_OK) {
    ALOGE("udplink != GST_PAD_LINK_OK");
    TeardownPipeline();
    return;
  }

  bool link_ok = gst_element_link_many(depay_, tsparse, tsdemux, NULL);
  if (!link_ok) {
    ALOGE("gst_element_link_many failed");
    TeardownPipeline();
    return;
  }

  g_signal_connect(rtpbin_, "request-pt-map", G_CALLBACK(RtpMpegTsPlayerGst::OnRequestPtMap), this);
  g_signal_connect(rtpbin_, "pad-added", G_CALLBACK(RtpMpegTsPlayerGst::OnRtpbinPadAdded), this);
  g_signal_connect(tsdemux, "pad-added", G_CALLBACK(RtpMpegTsPlayerGst::OnDemuxPadAdded), this);
  bus_ = gst_element_get_bus(pipeline_);
  if (bus_) {
    GSource* src = gst_bus_create_watch(bus_);
    g_source_set_callback(src, (GSourceFunc)gst_bus_async_signal_func, bus_, NULL);
    g_source_attach(src, context_);
    g_source_unref(src);
    g_signal_connect(bus_, "message", G_CALLBACK(RtpMpegTsPlayerGst::OnBusMessage), this);
  }
}

GstCaps* RtpMpegTsPlayerGst::OnRequestPtMap(GstElement* rtpbin, guint session, guint pt, gpointer user_data) {
  ALOGI("PT map requested for session %u, payload type %u", session, pt);

  if (pt == 33) {
    // 回傳 MPEG-TS over RTP 的 caps
    GstCaps* caps = gst_caps_new_simple("application/x-rtp",
                                        "media", G_TYPE_STRING, "video",
                                        "encoding-name", G_TYPE_STRING, "MP2T",
                                        "clock-rate", G_TYPE_INT, 90000,
                                        NULL);
    ALOGI("Returning caps for PT 33: %" GST_PTR_FORMAT, caps);
    return caps;
  }

  ALOGW("Unknown payload type: %u", pt);
  return NULL;
}

void RtpMpegTsPlayerGst::TeardownPipeline() {
  if (bus_) {
    gst_bus_remove_signal_watch(bus_);
    gst_object_unref(bus_);
    bus_ = nullptr;
  }
  if (pipeline_) {
    gst_element_set_state(pipeline_, GST_STATE_NULL);
  }
  if (rtpbin_rtp_sink_pad_) {
    if (rtpbin_) {
      gst_element_release_request_pad(rtpbin_, rtpbin_rtp_sink_pad_);
    }
    gst_object_unref(rtpbin_rtp_sink_pad_);
    rtpbin_rtp_sink_pad_ = nullptr;
  }
  if (pipeline_) {
    gst_object_unref(pipeline_);
    pipeline_ = nullptr;
  }
  if (socket_) {
    g_object_unref(socket_);
    socket_ = nullptr;
  }
  if (loop_) {
    g_main_loop_unref(loop_);
    loop_ = nullptr;
  }
  if (context_) {
    g_main_context_unref(context_);
    context_ = nullptr;
  }
}

void RtpMpegTsPlayerGst::AttachOverlay() {
  if (!video_sink_) {
    return;
  }
  if (!GST_IS_VIDEO_OVERLAY(video_sink_)) {
    return;
  }
  if (!native_window_) {
    return;
  }
  overlay_handle_ = reinterpret_cast<guintptr>(native_window_);
  gst_video_overlay_set_window_handle(GST_VIDEO_OVERLAY(video_sink_), overlay_handle_);
  gst_video_overlay_handle_events(GST_VIDEO_OVERLAY(video_sink_), FALSE);
}

GSocket* RtpMpegTsPlayerGst::CreateBoundSocket(uint16_t requested_port) {
  GError* err = nullptr;
  GSocket* sock = g_socket_new(G_SOCKET_FAMILY_IPV4, G_SOCKET_TYPE_DATAGRAM, G_SOCKET_PROTOCOL_UDP, &err);
  if (err) {
    g_error_free(err);
    err = nullptr;
  }
  if (!sock) {
    return nullptr;
  }
  GInetAddress* addr = g_inet_address_new_any(G_SOCKET_FAMILY_IPV4);
  if (!addr) {
    g_object_unref(sock);
    return nullptr;
  }
  GSocketAddress* saddr = g_inet_socket_address_new(addr, requested_port);
  g_object_unref(addr);
  if (!saddr) {
    g_object_unref(sock);
    return nullptr;
  }
  gboolean ok = g_socket_bind(sock, saddr, TRUE, &err);
  g_object_unref(saddr);
  if (!ok) {
    if (err) {
      g_error_free(err);
      err = nullptr;
    }
    g_object_unref(sock);
    return nullptr;
  }
  GSocketAddress* local = g_socket_get_local_address(sock, &err);
  if (!local) {
    if (err) {
      g_error_free(err);
      err = nullptr;
    }
    g_object_unref(sock);
    return nullptr;
  }
  if (G_IS_INET_SOCKET_ADDRESS(local)) {
    bound_port_ = g_inet_socket_address_get_port(G_INET_SOCKET_ADDRESS(local));
  } else {
    bound_port_ = 0;
  }
  g_object_unref(local);
  return sock;
}

void RtpMpegTsPlayerGst::RunMainLoop() {
  if (!loop_) {
    return;
  }
  g_main_loop_run(loop_);
}

void RtpMpegTsPlayerGst::SetJavaInstance(JNIEnv* env, jobject thiz) {
  if (java_instance_) {
    env->DeleteGlobalRef(java_instance_);
  }
  java_instance_ = env->NewGlobalRef(thiz);
}

extern JavaVM* g_vm;

void RtpMpegTsPlayerGst::NotifyVideoResolution(int width, int height) {
  if (!java_instance_)
    return;

  JNIEnv* env = nullptr;
  if (g_vm->AttachCurrentThread(&env, nullptr) != JNI_OK)
    return;

  jclass cls = env->GetObjectClass(java_instance_);
  if (!cls) {
    ALOGE("NotifyVideoResolution: GetObjectClass failed");
    return;
  }

  jmethodID method = env->GetMethodID(cls, "onVideoResolution", "(II)V");
  if (!method) {
    ALOGE("NotifyVideoResolution: GetMethodID failed");
    return;
  }
  if (method) {
    env->CallVoidMethod(java_instance_, method, width, height);
  }
}

void RtpMpegTsPlayerGst::NotifyPacketLost() {
  if (!java_instance_)
    return;

  JNIEnv* env = nullptr;
  if (g_vm->AttachCurrentThread(&env, nullptr) != JNI_OK)
    return;

  jclass cls = env->GetObjectClass(java_instance_);
  if (!cls) {
    ALOGE("NotifyPacketLost: GetObjectClass failed");
    return;
  }

  jmethodID method = env->GetMethodID(cls, "onPacketLost", "()V");
  if (!method) {
    ALOGE("NotifyPacketLost: GetMethodID failed");
    return;
  }
  if (method) {
    env->CallVoidMethod(java_instance_, method);
  }
}

void RtpMpegTsPlayerGst::Pause() {
  std::lock_guard<std::mutex> lock(mutex_);
  ALOGD("Pausing pipeline to prepare for surface destruction");

  if (is_paused_) {
    return;
  }

  is_paused_ = true;

  if (pipeline_) {
    // 快速停止渲染，避免寫入已銷毀的 Surface
    gst_element_set_state(pipeline_, GST_STATE_PAUSED);
    gst_video_overlay_set_window_handle(GST_VIDEO_OVERLAY(video_sink_), 0);
    ALOGD("Cleared old surface");
  }

  ReleaseWindowHandle();

  ALOGD("Pipeline paused safely");
}

void RtpMpegTsPlayerGst::Restart(JNIEnv* env, jobject surface) {
  std::lock_guard<std::mutex> lock(mutex_);

  ALOGD("Restart pipeline with new window");

  if (surface) {
    native_window_ = ANativeWindow_fromSurface(env, surface);
  }
  if (pipeline_ && video_sink_) {
    AttachOverlay();
  }

  gst_element_set_state(pipeline_, GST_STATE_PLAYING);

  is_paused_ = false;
}

void RtpMpegTsPlayerGst::ReleaseWindowHandle() {
  if (native_window_) {
    ANativeWindow_release(native_window_);
    native_window_ = nullptr;
    ALOGD("Released ANativeWindow handle");
  }
}