#include "rtp_mpegts_player_gst.h"

#include <cstring>
#include <future>
#include <span>
#include "media/video_csd_util.h"
#include "util/log.h"

namespace {
static std::once_flag g_gst_once;
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
        //gst_debug_add_log_function(android_log_function, NULL, NULL);
      });
}

RtpMpegTsPlayerGst::~RtpMpegTsPlayerGst() {
}

bool RtpMpegTsPlayerGst::Start() {
  ALOGI("Starting player");

  if (playing_) {
    return true;
  }
  EnsurePipeline();
  if (!pipeline_) {
    return false;
  }

  GstStateChangeReturn ret = gst_element_set_state(pipeline_, GST_STATE_PLAYING);
  if (ret == GST_STATE_CHANGE_FAILURE) {
    TeardownPipeline();
    return false;
  }
  playing_ = true;

  ALOGI("Player started");

  return true;
}

void RtpMpegTsPlayerGst::Stop() {
  ALOGI("Stopping player");

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

  ALOGI("Player stopped");
}

uint16_t RtpMpegTsPlayerGst::GetPort() const {
  return bound_port_;
}

void RtpMpegTsPlayerGst::SetSurface(JNIEnv* env, jobject surface) {
  ResetVideoDecoder();

  if (native_window_) {
    ANativeWindow_release(native_window_);
    native_window_ = nullptr;
  }
  if (surface) {
    native_window_ = ANativeWindow_fromSurface(env, surface);
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
  ALOGI("TSdemux pad added: %s", pad_name);

  GstCaps* caps = gst_pad_get_current_caps(pad);
  if (caps) {
    gchar* caps_str = gst_caps_to_string(caps);
    ALOGI("TSdemux pad caps: %s", caps_str);

    const GstStructure* s = gst_caps_get_structure(caps, 0);
    const gchar* name = gst_structure_get_name(s);

    ALOGI("Structure name: %s", name);

    // 檢查是否為音頻
    if (g_str_has_prefix(name, "audio/")) {
      ALOGI("Found audio pad, connecting...");
      self->ConnectAudioPad(pad);
    } else if (g_str_has_prefix(name, "video/")) {
      ALOGI("Found video pad, connecting...");
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
               "buffer-time", G_GINT64_CONSTANT(50000),   // 50ms buffer
               "latency-time", G_GINT64_CONSTANT(10000),  // 10ms latency
               NULL);
#endif

  // set default mute
  g_object_set(volume_,
               "mute", TRUE,
               NULL);

  gst_bin_add_many(GST_BIN(pipeline_), queue, aacparse, decoder, volume_convert, volume_, convert, resample, sink, NULL);

  // 直接連接 tsdemux pad 到 queue sink pad
  GstPad* queue_sink = gst_element_get_static_pad(queue, "sink");
  if (!queue_sink) {
    ALOGE("Failed to get queue sink pad");
    TeardownPipeline();
    return;
  }

  GstPadLinkReturn ret = gst_pad_link(pad, queue_sink);

  gst_object_unref(queue_sink);

  if (ret != GST_PAD_LINK_OK) {
    ALOGE("Failed to link tsdemux pad to queue: %d", ret);

    TeardownPipeline();

    return;
  }

  // 連接 queue → aacparse → decoder → ...

  if (!gst_element_link_many(queue, aacparse, decoder, volume_convert, volume_, convert, resample, sink, NULL)) {
    ALOGE("Failed to link audio elements");

    TeardownPipeline();

    return;
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
  ALOGI("Connecting video pad");

  GstPad* queue_sink = gst_element_get_static_pad(queue_, "sink");
  if (!queue_sink) {
    ALOGE("Failed to get queue sink pad");
    TeardownPipeline();
    return;
  }

  GstPadLinkReturn link_ret = gst_pad_link(pad, queue_sink);
  gst_object_unref(queue_sink);

  if (link_ret != GST_PAD_LINK_OK) {
    ALOGE("Failed to link demux to queue: %d", link_ret);
    TeardownPipeline();
    return;
  }

  // 連接後續元素
  // Pipeline: queue → h264parse → capsfilter → decoder → sink
  bool link_ok = gst_element_link_many(queue_, h264parse_, capsfilter_, video_appsink_, NULL);
  if (!link_ok) {
    ALOGE("gst_element_link_many failed");
    TeardownPipeline();
    return;
  }

  // 同步所有元素狀態
  gst_element_sync_state_with_parent(queue_);
  gst_element_sync_state_with_parent(h264parse_);
  gst_element_sync_state_with_parent(capsfilter_);
  gst_element_sync_state_with_parent(video_appsink_);
  ALOGI("Video pad connected, waiting for first keyframe");

  GstStateChangeReturn pipe_state_ret = gst_element_set_state(pipeline_, GST_STATE_PLAYING);
  if (pipe_state_ret == GST_STATE_CHANGE_FAILURE) {
    TeardownPipeline();
    return;
  }
  gst_bin_recalculate_latency(GST_BIN(pipeline_));
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
        ALOGD("Lost RTP packet! SSRC=%u, Seq=%u (no flush, decoder will handle)", ssrc, seqnum);
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
  tsdemux_ = gst_element_factory_make("tsdemux", "tsdemux");
  queue_ = gst_element_factory_make("queue", "decode_queue");
  h264parse_ = gst_element_factory_make("h264parse", "h264parse");
  capsfilter_ = gst_element_factory_make("capsfilter", "capsfilter");
  video_appsink_ = gst_element_factory_make("appsink", "video_appsink");

  if (!udpsrc_ || !rtpbin_ || !depay_ || !tsparse || !tsdemux_ ||
      !queue_ || !h264parse_ || !capsfilter_ || !video_appsink_) {
    ALOGE("Failed to create elements -> teardown");
    TeardownPipeline();
    return;
  }

  g_object_set(tsdemux_, "latency", 100, NULL);

  g_object_set(rtpbin_,
               "latency", 50,  // 降低到 50ms
               "ntp-time-source", 4,
               "ntp-sync", FALSE,
               "do-lost", TRUE,
               NULL);

  // *** 監聽 jitterbuffer 創建 ***
  g_signal_connect(rtpbin_, "new-jitterbuffer",
                   G_CALLBACK(OnNewJitterBuffer), this);

  // *** Queue - 小 buffer + leaky ***
  g_object_set(queue_,
               "max-size-buffers", 20,  // 增加到 20
               "max-size-bytes", 0,
               "max-size-time", 0,
               "leaky", 0,  // *** 關閉 leaky ***
               "silent", FALSE,
               NULL);

  // *** 監聽 queue overrun ***
  g_signal_connect(queue_, "overrun", G_CALLBACK(OnQueueOverrun), this);

  gst_app_sink_set_emit_signals(GST_APP_SINK(video_appsink_), TRUE);
  gst_app_sink_set_drop(GST_APP_SINK(video_appsink_), TRUE);
  gst_app_sink_set_max_buffers(GST_APP_SINK(video_appsink_), 8);
  gst_app_sink_set_wait_on_eos(GST_APP_SINK(video_appsink_), FALSE);

  g_object_set(video_appsink_,
               "sync", FALSE,
               "async", FALSE,
               NULL);

  g_signal_connect(video_appsink_, "new-sample", G_CALLBACK(OnNewSampleCallback), this);

  // Capsfilter
  GstCaps* caps = gst_caps_from_string(
      "video/x-h264, "
      "stream-format=(string)byte-stream, "
      "alignment=(string)au");
  g_object_set(capsfilter_, "caps", caps, nullptr);
  gst_caps_unref(caps);

  // Debug levels
  gst_debug_set_threshold_for_name("udpsrc", GST_LEVEL_WARNING);
  gst_debug_set_threshold_for_name("rtpbin", GST_LEVEL_INFO);
  gst_debug_set_threshold_for_name("rtpjitterbuffer", GST_LEVEL_INFO);
  gst_debug_set_threshold_for_name("rtpmp2tdepay", GST_LEVEL_WARNING);
  gst_debug_set_threshold_for_name("tsparse", GST_LEVEL_WARNING);
  gst_debug_set_threshold_for_name("tsdemux", GST_LEVEL_INFO);
  gst_debug_set_threshold_for_name("h264parse", GST_LEVEL_INFO);
  gst_debug_set_threshold_for_name("queue", GST_LEVEL_INFO);
  gst_debug_set_threshold_for_name("appsink", GST_LEVEL_INFO);

  g_object_set(udpsrc_,
               "socket", socket_,
               "buffer-size", 4194304,
               NULL);

  gst_bin_add_many(GST_BIN(pipeline_), udpsrc_, rtpbin_, depay_, tsparse,
                   tsdemux_, queue_, h264parse_, capsfilter_, NULL);

  if (!gst_bin_add(GST_BIN(pipeline_), video_appsink_)) {
    TeardownPipeline();
    return;
  }

  // 連接 udpsrc → rtpbin
  rtpbin_rtp_sink_pad_ = gst_element_get_request_pad(rtpbin_, "recv_rtp_sink_0");
  GstPad* udp_src_pad = gst_element_get_static_pad(udpsrc_, "src");
  if (!rtpbin_rtp_sink_pad_ || !udp_src_pad) {
    if (udp_src_pad) {
      gst_object_unref(udp_src_pad);
    }
    TeardownPipeline();
    return;
  }

  GstPadLinkReturn udplink = gst_pad_link(udp_src_pad, rtpbin_rtp_sink_pad_);
  gst_object_unref(udp_src_pad);
  if (udplink != GST_PAD_LINK_OK) {
    ALOGE("Failed to link udpsrc to rtpbin");
    TeardownPipeline();
    return;
  }

  // 連接 depay → tsparse → tsdemux
  bool link_ok = gst_element_link_many(depay_, tsparse, tsdemux_, NULL);
  if (!link_ok) {
    ALOGE("Failed to link depay → tsparse → tsdemux");
    TeardownPipeline();
    return;
  }

  // 連接信號
  g_signal_connect(rtpbin_, "request-pt-map", G_CALLBACK(RtpMpegTsPlayerGst::OnRequestPtMap), this);
  g_signal_connect(rtpbin_, "pad-added", G_CALLBACK(RtpMpegTsPlayerGst::OnRtpbinPadAdded), this);
  g_signal_connect(tsdemux_, "pad-added", G_CALLBACK(RtpMpegTsPlayerGst::OnDemuxPadAdded), this);

  // Bus
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
  queue_restore_pending_.store(false);
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
  queue_ = nullptr;
  h264parse_ = nullptr;
  video_appsink_ = nullptr;
  udpsrc_ = nullptr;
  rtpbin_ = nullptr;
  depay_ = nullptr;
  capsfilter_ = nullptr;
  tsdemux_ = nullptr;
  volume_ = nullptr;

  ResetVideoDecoder();

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

void RtpMpegTsPlayerGst::OnNewJitterBuffer(GstElement* rtpbin, GstElement* jitterbuffer, guint session, guint ssrc, gpointer user_data) {
  ALOGI("Configuring jitterbuffer for session %u, ssrc %u", session, ssrc);

  g_object_set(jitterbuffer,
               "latency", 50,  // 50ms 低延遲
               "do-lost", TRUE,
               "max-dropout-time", 500,
               "max-misorder-time", 100,
               "rtx-max-retries", 0,  // 不重傳
               NULL);

  // 驗證配置
  guint actual_latency = 0;
  gint actual_mode = 0;
  g_object_get(jitterbuffer,
               "latency", &actual_latency,
               "mode", &actual_mode,
               NULL);
  ALOGI("Jitterbuffer: latency=%u ms, mode=%d (1=SLAVE)", actual_latency, actual_mode);
}

GstFlowReturn RtpMpegTsPlayerGst::OnNewSampleCallback(GstAppSink* sink, gpointer user_data) {
  RtpMpegTsPlayerGst* self = static_cast<RtpMpegTsPlayerGst*>(user_data);
  if (!self) {
    return GST_FLOW_OK;
  }

  return self->OnNewSample(sink);
}

GstFlowReturn RtpMpegTsPlayerGst::OnNewSample(GstAppSink* sink) {
  GstSample* sample = gst_app_sink_pull_sample(sink);

  if (!sample) {
    return GST_FLOW_EOS;
  }

  GstFlowReturn ret = HandleNewSample(sample);

  gst_sample_unref(sample);

  return ret;
}

GstFlowReturn RtpMpegTsPlayerGst::HandleNewSample(GstSample* sample) {
  if (!sample) {
    return GST_FLOW_OK;
  }

  GstBuffer* buffer = gst_sample_get_buffer(sample);

  if (!buffer) {
    return GST_FLOW_OK;
  }

  GstMapInfo map;

  if (!gst_buffer_map(buffer, &map, GST_MAP_READ)) {
    ALOGE("Failed to map sample buffer");

    return GST_FLOW_OK;
  }

  bool key_frame = !GST_BUFFER_FLAG_IS_SET(buffer, GST_BUFFER_FLAG_DELTA_UNIT);

  GstClockTime pts = GST_BUFFER_PTS(buffer);

  {
    std::lock_guard<std::mutex> lock(decoder_mutex_);

    if (awaiting_key_frame_ && !key_frame) {
      gst_buffer_unmap(buffer, &map);

      return GST_FLOW_OK;
    }

    if (!EnsureVideoDecoderLocked(map.data, map.size, key_frame)) {
      awaiting_key_frame_ = true;

      gst_buffer_unmap(buffer, &map);

      return GST_FLOW_OK;
    }

    awaiting_key_frame_ = false;

    DispatchFrameToDecoderLocked(map.data, map.size, pts, key_frame);
  }

  gst_buffer_unmap(buffer, &map);

  return GST_FLOW_OK;
}

bool RtpMpegTsPlayerGst::EnsureVideoDecoderLocked(const uint8_t* frame, size_t size, bool key_frame) {
  if (video_decoder_failed_ && key_frame) {
    video_decoder_failed_ = false;
  }

  if (key_frame && frame && size > 0) {
    auto csd = ParseVideoCsd(VideoCodecType::kH264, std::span<const uint8_t>(frame, size));

    if (csd.has_value()) {
      bool csd_changed = !video_csd_.has_value() ||
                         csd->width != video_csd_->width ||
                         csd->height != video_csd_->height ||
                         csd->csd0 != video_csd_->csd0 ||
                         csd->csd1 != video_csd_->csd1;

      if (csd_changed) {
        video_csd_ = csd;

        video_decoder_failed_ = false;

        if (video_decoder_) {
          video_decoder_->Stop();

          video_decoder_.reset();
        }
      }
    }
  }

  if (video_decoder_) {
    return true;
  }

  if (video_decoder_failed_ || !video_csd_.has_value() || !native_window_) {
    return false;
  }

  bool attempts[2];

  size_t attempt_count = 0;

  if (decoder_use_software_) {
    attempts[attempt_count++] = true;

  } else {
    attempts[attempt_count++] = false;
    attempts[attempt_count++] = true;
  }

  for (size_t i = 0; i < attempt_count; ++i) {
    bool use_software = attempts[i];

    ALOGI("Creating video decoder");
    auto decoder = CreateVideoDecoder(
        VideoCodecType::kH264,
        use_software,
        *video_csd_,
        video_decoder_params_,
        native_window_,
        this);

    if (!decoder) {
      ALOGW("Failed to create video decoder");
      continue;
    }

    if (!decoder->Start()) {
      decoder->Stop();

      continue;
    }

    video_decoder_ = std::move(decoder);

    decoder_use_software_ = use_software;

    video_decoder_failed_ = false;

    return true;
  }

  video_decoder_failed_ = true;

  return false;
}

void RtpMpegTsPlayerGst::DispatchFrameToDecoderLocked(const uint8_t* frame, size_t size, GstClockTime pts, bool /*key_frame*/) {
  if (!video_decoder_) {
    return;
  }

  uint64_t pts_us = 0;

  if (pts != GST_CLOCK_TIME_NONE) {
    pts_us = GST_TIME_AS_USECONDS(pts);
  }

  if (!video_decoder_->Decode(frame, size, pts_us)) {
    ALOGW("VideoDecoderNdk::Decode failed (size=%zu)", size);
  }
}

void RtpMpegTsPlayerGst::ResetVideoDecoder() {
  std::lock_guard<std::mutex> lock(decoder_mutex_);
  ALOGI("Reset video decoder");

  if (video_decoder_) {
    video_decoder_->Stop();

    video_decoder_.reset();
  }

  video_csd_.reset();

  decoder_use_software_ = false;

  video_decoder_failed_ = false;

  awaiting_key_frame_ = true;
}

void RtpMpegTsPlayerGst::OnVideoFormatChanged(int width, int height) {
  NotifyVideoResolution(width, height);
}

void RtpMpegTsPlayerGst::OnVideoFrameRate(int fps) {
  ALOGD("Decoded video FPS: %d", fps);
}

void RtpMpegTsPlayerGst::OnQueueOverrun(GstElement* queue, gpointer user_data) {
  RtpMpegTsPlayerGst* self = static_cast<RtpMpegTsPlayerGst*>(user_data);
  // Queue 滿了，但不會自動丟棄，因為我們在 probe 中已經處理了
  if (++self->overrun_count_ % 10 == 0) {
    ALOGW("Queue OVERRUN #%d - probe should be dropping delta units", self->overrun_count_);
  }
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
  ALOGD("Pausing pipeline to prepare for surface destruction");

  if (is_paused_) {
    return;
  }

  // is_paused_ = true;

  // if (pipeline_) {
  //   gst_element_set_state(pipeline_, GST_STATE_PAUSED);
  // }

  ResetVideoDecoder();

  ReleaseWindowHandle();

  ALOGD("Pipeline paused safely");
}

void RtpMpegTsPlayerGst::Restart(JNIEnv* env, jobject surface) {
  ALOGD("Restart pipeline with new window");

  ResetVideoDecoder();

  if (native_window_) {
    ANativeWindow_release(native_window_);

    native_window_ = nullptr;
  }

  if (surface) {
    native_window_ = ANativeWindow_fromSurface(env, surface);
  }

  if (pipeline_) {
    gst_element_set_state(pipeline_, GST_STATE_PLAYING);
  }

  is_paused_ = false;
}

void RtpMpegTsPlayerGst::ReleaseWindowHandle() {
  if (native_window_) {
    ANativeWindow_release(native_window_);
    native_window_ = nullptr;
    ALOGD("Released ANativeWindow handle");
  }
}
