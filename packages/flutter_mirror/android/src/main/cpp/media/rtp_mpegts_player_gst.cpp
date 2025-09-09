#include "rtp_mpegts_player_gst.h"

#include <cstring>
#include "log.h"

namespace {
static std::once_flag g_gst_once;
}

static void android_log_function(GstDebugCategory* category,
                                 GstDebugLevel level,
                                 const gchar* file,
                                 const gchar* function,
                                 gint line,
                                 GObject* object,
                                 GstDebugMessage* message,
                                 gpointer user_data) {
  android_LogPriority priority = ANDROID_LOG_DEBUG;
  const char* level_str = "DEBUG";

  switch (level) {
    case GST_LEVEL_ERROR:
      priority = ANDROID_LOG_ERROR;
      level_str = "ERROR";
      break;
    case GST_LEVEL_WARNING:
      priority = ANDROID_LOG_WARN;
      level_str = "WARN";
      break;
    case GST_LEVEL_INFO:
      priority = ANDROID_LOG_INFO;
      level_str = "INFO";
      break;
    case GST_LEVEL_DEBUG:
      priority = ANDROID_LOG_DEBUG;
      level_str = "DEBUG";
      break;
    case GST_LEVEL_LOG:
      priority = ANDROID_LOG_VERBOSE;
      level_str = "LOG";
      break;
    default:
      priority = ANDROID_LOG_VERBOSE;
      level_str = "TRACE";
      break;
  }

  const gchar* category_name = gst_debug_category_get_name(category);
  const gchar* msg = gst_debug_message_get(message);

  __android_log_print(priority, "GST_DEBUG", "[%s] %s", category_name, msg);
}

RtpMpegTsPlayerGst::RtpMpegTsPlayerGst()
    : native_window_(nullptr), overlay_handle_(0), context_(nullptr), loop_(nullptr), pipeline_(nullptr), udpsrc_(nullptr), rtpbin_(nullptr), depay_(nullptr), tsparse_(nullptr), tsdemux_(nullptr), video_queue_(nullptr), decodebin_(nullptr), video_sink_(nullptr), bus_(nullptr), socket_(nullptr), bound_port_(0), playing_(false), rtpbin_rtp_sink_pad_(nullptr) {
  std::call_once(g_gst_once, []() {
    int argc = 0;
    char** argv = nullptr;
    gst_init(&argc, &argv);
    gst_debug_set_default_threshold(GST_LEVEL_WARNING);

    gst_debug_remove_log_function(gst_debug_log_default);

    // 加上我們的 log function
    gst_debug_add_log_function(android_log_function, NULL, NULL);
  });
}

RtpMpegTsPlayerGst::~RtpMpegTsPlayerGst() {
  Stop();
}

bool RtpMpegTsPlayerGst::Start() {
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
    ALOGI("pipeline_ playing failed");
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
  ALOGI("TSdemux pad added: %s", pad_name);

  GstCaps* caps = gst_pad_get_current_caps(pad);
  if (caps) {
    gchar* caps_str = gst_caps_to_string(caps);
    ALOGI("TSdemux pad caps: %s", caps_str);

    const GstStructure* s = gst_caps_get_structure(caps, 0);
    const gchar* name = gst_structure_get_name(s);

    ALOGI("Structure name: %s", name);  // 加上這個 debug

    // 檢查是否為音頻
    if (g_str_has_prefix(name, "audio/")) {
      ALOGI("Found audio pad, connecting...");
      self->ConnectAudioPad(pad);
    } else if (g_str_has_prefix(name, "video/")) {
      ALOGI("Found video pad, connecting to fakesink...");
      // 連接 video 到 fakesink 避免 not-linked 錯誤
      GstElement* video_fakesink = gst_element_factory_make("fakesink", NULL);
      if (video_fakesink) {
        gst_bin_add(GST_BIN(self->pipeline_), video_fakesink);
        gst_element_sync_state_with_parent(video_fakesink);

        GstPad* sink_pad = gst_element_get_static_pad(video_fakesink, "sink");
        if (sink_pad) {
          GstPadLinkReturn ret = gst_pad_link(pad, sink_pad);
          ALOGI("Video pad link result: %d", ret);
          gst_object_unref(sink_pad);
        }
      }
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
  GstElement* convert = gst_element_factory_make("audioconvert", NULL);
  GstElement* resample = gst_element_factory_make("audioresample", NULL);
  GstElement* sink = gst_element_factory_make("openslessink", NULL);

  if (!queue || !aacparse || !decoder || !convert || !resample || !sink) {
    // cleanup if any element creation failed
    if (queue)
      gst_object_unref(queue);
    if (aacparse)
      gst_object_unref(aacparse);
    if (decoder)
      gst_object_unref(decoder);
    if (convert)
      gst_object_unref(convert);
    if (resample)
      gst_object_unref(resample);
    if (sink)
      gst_object_unref(sink);
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

  gst_bin_add_many(GST_BIN(pipeline_), queue, aacparse, decoder, convert, resample, sink, NULL);

  if (!gst_element_link_many(queue, aacparse, decoder, convert, resample, sink, NULL)) {
    ALOGE("Failed to link audio elements");
    return;
  }

  GstPad* queue_sink_pad = gst_element_get_static_pad(queue, "sink");
  if (queue_sink_pad) {
    GstPadLinkReturn ret = gst_pad_link(pad, queue_sink_pad);
    if (ret != GST_PAD_LINK_OK) {
      ALOGE("Failed to link demux pad to audio queue");
    }
    gst_object_unref(queue_sink_pad);
  }

  // 同步新元件的狀態
  gst_element_sync_state_with_parent(queue);
  gst_element_sync_state_with_parent(aacparse);
  gst_element_sync_state_with_parent(decoder);
  gst_element_sync_state_with_parent(convert);
  gst_element_sync_state_with_parent(resample);
  gst_element_sync_state_with_parent(sink);
}

void RtpMpegTsPlayerGst::OnDecodebinPadAdded(GstElement* decodebin, GstPad* pad, gpointer user_data) {
  RtpMpegTsPlayerGst* self = static_cast<RtpMpegTsPlayerGst*>(user_data);
  if (!self) {
    return;
  }
  if (!self->video_sink_) {
    self->video_sink_ = gst_element_factory_make("glimagesink", "video_sink");
    if (self->video_sink_) {
      g_object_set(self->video_sink_, "sync", TRUE, NULL);
      g_object_set(self->video_sink_, "force-aspect-ratio", TRUE, NULL);
      gst_bin_add(GST_BIN(self->pipeline_), self->video_sink_);
      gst_element_sync_state_with_parent(self->video_sink_);
      self->AttachOverlay();
    }
  }
  if (!self->video_sink_) {
    return;
  }
  GstCaps* caps = gst_pad_get_current_caps(pad);
  if (!caps) {
    caps = gst_pad_query_caps(pad, nullptr);
  }
  if (!caps) {
    return;
  }
  GstPad* sinkpad = gst_element_get_static_pad(self->video_sink_, "sink");
  if (!sinkpad) {
    gst_caps_unref(caps);
    return;
  }
  if (gst_pad_is_linked(sinkpad)) {
    gst_object_unref(sinkpad);
    gst_caps_unref(caps);
    return;
  }
  GstPadLinkReturn linkret = gst_pad_link(pad, sinkpad);
  gst_object_unref(sinkpad);
  gst_caps_unref(caps);
  if (linkret != GST_PAD_LINK_OK) {
    return;
  }
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
  tsparse_ = gst_element_factory_make("tsparse", "tsparse");
  tsdemux_ = gst_element_factory_make("tsdemux", "tsdemux");

  if (!udpsrc_)
    ALOGE("udpsrc is null");
  if (!rtpbin_)
    ALOGE("rtpbin is null");
  if (!depay_)
    ALOGE("rtpmp2tdepay is null");
  if (!tsparse_)
    ALOGE("tsparse is null");
  if (!tsdemux_)
    ALOGE("tsdemux is null");

  if (!udpsrc_ || !rtpbin_ || !depay_ || !tsparse_ || !tsdemux_) {
    ALOGE("something is null -> teardown");
    TeardownPipeline();
    return;
  }

  GST_DEBUG("Testing debug output - this should appear in logcat");

  gst_debug_set_threshold_for_name("udpsrc", GST_LEVEL_DEBUG);
  gst_debug_set_threshold_for_name("rtpbin", GST_LEVEL_DEBUG);
  gst_debug_set_threshold_for_name("rtpmp2tdepay", GST_LEVEL_DEBUG);
  gst_debug_set_threshold_for_name("tsparse", GST_LEVEL_WARNING);
  gst_debug_set_threshold_for_name("tsdemux", GST_LEVEL_DEBUG);

  g_object_set(udpsrc_, "socket", socket_, NULL);
  g_object_set(rtpbin_, "latency", 200, NULL);

  gst_bin_add_many(GST_BIN(pipeline_), udpsrc_, rtpbin_, depay_, tsparse_, tsdemux_, NULL);

  rtpbin_rtp_sink_pad_ = gst_element_get_request_pad(rtpbin_, "recv_rtp_sink_0");
  GstPad* udp_src_pad = gst_element_get_static_pad(udpsrc_, "src");
  if (!rtpbin_rtp_sink_pad_ || !udp_src_pad) {
    if (rtpbin_rtp_sink_pad_) {
      ALOGE("udp_src_pad is null");
      gst_object_unref(rtpbin_rtp_sink_pad_);
      rtpbin_rtp_sink_pad_ = nullptr;
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
    gst_element_release_request_pad(rtpbin_, rtpbin_rtp_sink_pad_);
    gst_object_unref(rtpbin_rtp_sink_pad_);
    rtpbin_rtp_sink_pad_ = nullptr;
    TeardownPipeline();
    return;
  }

  bool link_ok = gst_element_link_many(depay_, tsparse_, tsdemux_, NULL);
  if (!link_ok) {
    ALOGE("gst_element_link_many failed");
    TeardownPipeline();
    return;
  }

  g_signal_connect(rtpbin_, "request-pt-map", G_CALLBACK(RtpMpegTsPlayerGst::OnRequestPtMap), this);
  g_signal_connect(rtpbin_, "pad-added", G_CALLBACK(RtpMpegTsPlayerGst::OnRtpbinPadAdded), this);
  g_signal_connect(tsdemux_, "pad-added", G_CALLBACK(RtpMpegTsPlayerGst::OnDemuxPadAdded), this);
  bus_ = gst_element_get_bus(pipeline_);
  if (bus_) {
    gst_bus_add_signal_watch_full(bus_, G_PRIORITY_DEFAULT);
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
  if (video_sink_) {
    gst_bin_remove(GST_BIN(pipeline_), video_sink_);
    gst_object_unref(video_sink_);
    video_sink_ = nullptr;
  }
  if (decodebin_) {
    gst_bin_remove(GST_BIN(pipeline_), decodebin_);
    gst_object_unref(decodebin_);
    decodebin_ = nullptr;
  }
  if (video_queue_) {
    gst_bin_remove(GST_BIN(pipeline_), video_queue_);
    gst_object_unref(video_queue_);
    video_queue_ = nullptr;
  }
  if (tsdemux_) {
    gst_bin_remove(GST_BIN(pipeline_), tsdemux_);
    gst_object_unref(tsdemux_);
    tsdemux_ = nullptr;
  }
  if (tsparse_) {
    gst_bin_remove(GST_BIN(pipeline_), tsparse_);
    gst_object_unref(tsparse_);
    tsparse_ = nullptr;
  }
  if (depay_) {
    gst_bin_remove(GST_BIN(pipeline_), depay_);
    gst_object_unref(depay_);
    depay_ = nullptr;
  }
  if (rtpbin_) {
    gst_bin_remove(GST_BIN(pipeline_), rtpbin_);
    gst_object_unref(rtpbin_);
    rtpbin_ = nullptr;
  }
  if (udpsrc_) {
    gst_bin_remove(GST_BIN(pipeline_), udpsrc_);
    gst_object_unref(udpsrc_);
    udpsrc_ = nullptr;
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
