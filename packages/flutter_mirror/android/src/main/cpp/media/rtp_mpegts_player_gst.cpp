#include "rtp_mpegts_player_gst.h"

#include <cstring>
#include <future>
#include "log.h"

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

  // *** 讓 video_sink 提供 clock ***
  // 不手動設定 use_clock，而是設定 sink 的 provide-clock 屬性
  if (video_sink_) {
    g_object_set(video_sink_, "provide-clock", TRUE, NULL);
    ALOGI("Set video_sink provide-clock=TRUE");
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
  ALOGI("Connecting video pad");

  // *** 初始狀態 ***
  EnterKeyframeWait();
  pts_offset_.store(GST_CLOCK_TIME_NONE);  // *** 重置 PTS offset ***
  ResetBacklogTracker();

  ALOGI("ConnectVideoPad: waiting_for_keyframe set to TRUE");

  // 先取得 queue sink pad
  GstPad* queue_sink = gst_element_get_static_pad(queue_, "sink");
  if (!queue_sink) {
    ALOGE("Failed to get queue sink pad");
    TeardownPipeline();
    return;
  }

  // *** 添加 probe（在連接之前）***
  // 在 queue sink 添加 probe 用於 keyframe 檢測和丟幀邏輯
  gst_pad_add_probe(queue_sink,
                    static_cast<GstPadProbeType>(GST_PAD_PROBE_TYPE_BUFFER |
                                                 GST_PAD_PROBE_TYPE_EVENT_DOWNSTREAM),
                    OnQueueSinkProbe,
                    this,
                    nullptr);

  // 連接 demux pad 到 queue
  GstPadLinkReturn link_ret = gst_pad_link(pad, queue_sink);
  gst_object_unref(queue_sink);

  if (link_ret != GST_PAD_LINK_OK) {
    ALOGE("Failed to link demux to queue: %d", link_ret);
    TeardownPipeline();
    return;
  }

  // 連接後續元素
  // Pipeline: queue → h264parse → capsfilter → decoder → sink
  bool link_ok = gst_element_link_many(queue_, h264parse_, capsfilter_, decoder_, video_sink_, NULL);
  if (!link_ok) {
    ALOGE("gst_element_link_many failed");
    TeardownPipeline();
    return;
  }

  // *** 在 decoder 輸入加 probe 檢查 PTS 是否正確調整 ***
  GstPad* decoder_sink = gst_element_get_static_pad(decoder_, "sink");
  if (decoder_sink) {
    gst_pad_add_probe(decoder_sink,
                      GST_PAD_PROBE_TYPE_BUFFER,
                      OnDecoderInput,
                      this,
                      nullptr);
    gst_object_unref(decoder_sink);
  }

  // *** 在 decoder 輸出加 probe 監控 ***
  GstPad* decoder_src = gst_element_get_static_pad(decoder_, "src");
  if (decoder_src) {
    gst_pad_add_probe(decoder_src,
                      static_cast<GstPadProbeType>(
                          GST_PAD_PROBE_TYPE_BUFFER |
                          GST_PAD_PROBE_TYPE_EVENT_DOWNSTREAM |
                          GST_PAD_PROBE_TYPE_EVENT_UPSTREAM  // QoS events
                          ),
                      OnDecoderOutput,
                      this,
                      nullptr);
    gst_object_unref(decoder_src);
  }

  // *** 在 sink 輸入加 probe 監控 ***
  GstPad* sink_pad = gst_element_get_static_pad(video_sink_, "sink");
  if (sink_pad) {
    gst_pad_add_probe(sink_pad,
                      GST_PAD_PROBE_TYPE_BUFFER,
                      OnSinkInput,
                      this,
                      nullptr);
    gst_object_unref(sink_pad);
  }

  // 同步所有元素狀態
  gst_element_sync_state_with_parent(queue_);
  gst_element_sync_state_with_parent(h264parse_);
  gst_element_sync_state_with_parent(capsfilter_);
  gst_element_sync_state_with_parent(decoder_);
  gst_element_sync_state_with_parent(video_sink_);

  ALOGI("Video pad connected, waiting for first keyframe");

  GstStateChangeReturn pipe_state_ret = gst_element_set_state(pipeline_, GST_STATE_PLAYING);
  if (pipe_state_ret == GST_STATE_CHANGE_FAILURE) {
    TeardownPipeline();
    return;
  }
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

void RtpMpegTsPlayerGst::ResetBacklogTracker() {
  backlog_first_pts_.store(GST_CLOCK_TIME_NONE);
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

GstPadProbeReturn RtpMpegTsPlayerGst::OnQueueSinkProbe(GstPad* pad, GstPadProbeInfo* info, gpointer user_data) {
  RtpMpegTsPlayerGst* self = static_cast<RtpMpegTsPlayerGst*>(user_data);
  if (!self) {
    return GST_PAD_PROBE_OK;
  }

  const GstPadProbeType type = GST_PAD_PROBE_INFO_TYPE(info);

  if (type & GST_PAD_PROBE_TYPE_EVENT_DOWNSTREAM) {
    GstEvent* event = GST_PAD_PROBE_INFO_EVENT(info);
    if (!event) {
      return GST_PAD_PROBE_OK;
    }
    switch (GST_EVENT_TYPE(event)) {
      case GST_EVENT_FLUSH_START:
        ALOGW("Queue sink: FLUSH_START (external flush, letting GStreamer handle)");
        self->ResetBacklogTracker();
        break;
      case GST_EVENT_FLUSH_STOP:
        ALOGW("Queue sink: FLUSH_STOP (external flush, letting GStreamer handle)");
        self->ResetBacklogTracker();
        break;
      case GST_EVENT_SEGMENT:
        self->ResetBacklogTracker();
        break;
      default:
        break;
    }
    return GST_PAD_PROBE_OK;
  }

  if (!(type & GST_PAD_PROBE_TYPE_BUFFER)) {
    return GST_PAD_PROBE_OK;
  }

  GstBuffer* buffer = gst_pad_probe_info_get_buffer(info);
  if (!buffer) {
    return GST_PAD_PROBE_OK;
  }

  bool is_keyframe = !GST_BUFFER_FLAG_IS_SET(buffer, GST_BUFFER_FLAG_DELTA_UNIT);
  bool waiting = self->waiting_for_keyframe_.load();

  // *** 第一個 keyframe：記錄 PTS offset ***
  if (waiting && is_keyframe && GST_BUFFER_PTS(buffer) != GST_CLOCK_TIME_NONE) {
    GstClockTime first_pts = GST_BUFFER_PTS(buffer);
    if (self->pts_offset_.load() == GST_CLOCK_TIME_NONE) {
      self->pts_offset_.store(first_pts);
      ALOGI("=== PTS OFFSET RECORDED ===");
      ALOGI("  First keyframe PTS: %" GST_TIME_FORMAT, GST_TIME_ARGS(first_pts));
    }
  }

  GstClockTime pts = GST_BUFFER_PTS(buffer);

  // *** 智能丟棄策略 ***
  guint current_level = 0;
  guint max_level = 0;
  g_object_get(self->queue_,
               "current-level-buffers", &current_level,
               "max-size-buffers", &max_level,
               NULL);

  float fill_percent = (max_level > 0) ? (100.0f * current_level / max_level) : 0.0f;

  if (fill_percent > 70.0f) {
    if (is_keyframe) {
      static int keyframe_preserved_count = 0;
      if (++keyframe_preserved_count % 5 == 0) {
        ALOGW("Queue %.1f%% full - PRESERVING keyframe", fill_percent);
      }
    } else {
      static int drop_count = 0;
      if (++drop_count % 10 == 0) {
        ALOGW("Queue %.1f%% full - DROPPING delta unit (dropped %d)", fill_percent, drop_count);
      }
      return GST_PAD_PROBE_DROP;
    }
  }

  static int frame_count = 0;
  if (++frame_count % 30 == 0) {
    ALOGI("Queue status: %u/%u buffers (%.1f%% full), keyframe=%d",
          current_level, max_level, fill_percent, is_keyframe);
  }

  // 等待第一個 keyframe
  if (waiting) {
    if (GST_BUFFER_FLAG_IS_SET(buffer, GST_BUFFER_FLAG_DELTA_UNIT)) {
      return GST_PAD_PROBE_DROP;
    }

    ALOGI("*** GOT KEYFRAME - Starting playback ***");
    ALOGI("  Keyframe PTS: %" GST_TIME_FORMAT, GST_TIME_ARGS(pts));

    self->ExitKeyframeWait();
    self->ResetBacklogTracker();

    return GST_PAD_PROBE_OK;
  }

  // Keyframe 重置 backlog
  if (is_keyframe) {
    self->ResetBacklogTracker();
    return GST_PAD_PROBE_OK;
  }

  // Backlog 檢查
  if (pts == GST_CLOCK_TIME_NONE) {
    return GST_PAD_PROBE_OK;
  }

  GstClockTime first_pts = self->backlog_first_pts_.load();
  if (first_pts == GST_CLOCK_TIME_NONE) {
    self->backlog_first_pts_.store(pts);
    return GST_PAD_PROBE_OK;
  }

  if (pts > first_pts) {
    GstClockTime backlog = pts - first_pts;

    if (backlog > 500 * GST_MSECOND) {
      static int warning_count = 0;
      if (++warning_count % 30 == 0) {
        ALOGW("High backlog: %" GST_TIME_FORMAT " (this is OK, decoder will catch up)",
              GST_TIME_ARGS(backlog));
      }
    }
  }

  return GST_PAD_PROBE_OK;
}

GstPadProbeReturn RtpMpegTsPlayerGst::OnDecoderInput(GstPad* pad, GstPadProbeInfo* info, gpointer user_data) {
  RtpMpegTsPlayerGst* self = static_cast<RtpMpegTsPlayerGst*>(user_data);
  if (!self) {
    return GST_PAD_PROBE_OK;
  }

  GstBuffer* buffer = GST_PAD_PROBE_INFO_BUFFER(info);
  if (!buffer) {
    return GST_PAD_PROBE_OK;
  }

  // *** [TRACE] 檢查第一個進入 decoder 的 buffer PTS 和 running_time ***
  static bool first_decoder_input_logged = false;
  if (!first_decoder_input_logged && GST_BUFFER_PTS(buffer) != GST_CLOCK_TIME_NONE) {
    first_decoder_input_logged = true;
    bool is_keyframe = !GST_BUFFER_FLAG_IS_SET(buffer, GST_BUFFER_FLAG_DELTA_UNIT);

    // 計算 running_time
    GstClockTime base_time = gst_element_get_base_time(GST_ELEMENT(gst_pad_get_parent(pad)));
    GstClock* clock = gst_element_get_clock(GST_ELEMENT(gst_pad_get_parent(pad)));
    GstClockTime now = clock ? gst_clock_get_time(clock) : GST_CLOCK_TIME_NONE;
    GstClockTime running_time = (now != GST_CLOCK_TIME_NONE && base_time != GST_CLOCK_TIME_NONE)
                                    ? now - base_time
                                    : GST_CLOCK_TIME_NONE;

    ALOGI("  [TRACE] First buffer entering decoder: PTS=%" GST_TIME_FORMAT ", is_keyframe=%d",
          GST_TIME_ARGS(GST_BUFFER_PTS(buffer)), is_keyframe);
    ALOGI("  [TRACE] Decoder input: base_time=%" GST_TIME_FORMAT ", now=%" GST_TIME_FORMAT ", running_time=%" GST_TIME_FORMAT,
          GST_TIME_ARGS(base_time), GST_TIME_ARGS(now), GST_TIME_ARGS(running_time));

    if (clock) {
      gst_object_unref(clock);
    }
  }

  // 調試日誌（每 30 幀記錄一次）
  static int decoder_input_count = 0;
  if (++decoder_input_count % 30 == 0) {
    ALOGI("Decoder input PTS: %" GST_TIME_FORMAT,
          GST_TIME_ARGS(GST_BUFFER_PTS(buffer)));
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

GstPadProbeReturn RtpMpegTsPlayerGst::OnDecoderOutput(GstPad* pad, GstPadProbeInfo* info, gpointer user_data) {
  RtpMpegTsPlayerGst* self = static_cast<RtpMpegTsPlayerGst*>(user_data);
  if (!self) {
    return GST_PAD_PROBE_OK;
  }

  // *** 監控 QoS events ***
  if (GST_PAD_PROBE_INFO_TYPE(info) & GST_PAD_PROBE_TYPE_EVENT_UPSTREAM) {
    GstEvent* event = GST_PAD_PROBE_INFO_EVENT(info);

    if (GST_EVENT_TYPE(event) == GST_EVENT_QOS) {
      GstQOSType type;
      gdouble proportion;
      GstClockTimeDiff diff;
      GstClockTime timestamp;

      gst_event_parse_qos(event, &type, &proportion, &diff, &timestamp);

      static int qos_log_count = 0;
      if (++qos_log_count % 30 == 0) {
        ALOGW(">>> QoS event: proportion=%.2f, diff=%" GST_STIME_FORMAT,
              proportion, GST_STIME_ARGS(diff));
      }
    }
  }

  // *** 監控 CAPS ***
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

        gchar* caps_str = gst_caps_to_string(caps);
        ALOGI("=== Decoder output CAPS: %s ===", caps_str);
        g_free(caps_str);

        ALOGI("video size: %d x %d", width, height);
        self->NotifyVideoResolution(width, height);
      }
    }
  }

  // *** 監控 Buffers - 計算 FPS ***
  if (GST_PAD_PROBE_INFO_TYPE(info) & GST_PAD_PROBE_TYPE_BUFFER) {
    GstBuffer* buffer = gst_pad_probe_info_get_buffer(info);
    if (buffer) {
      static int decoded_count = 0;
      static GstClockTime last_log_time = 0;
      static GstClockTime first_buffer_time = 0;

      GstClockTime now = g_get_monotonic_time() * 1000;

      if (first_buffer_time == 0) {
        first_buffer_time = now;
        ALOGI("*** FIRST DECODED FRAME OUTPUT ***");
        if (GST_BUFFER_PTS(buffer) != GST_CLOCK_TIME_NONE) {
          ALOGI("  First output buffer PTS: %" GST_TIME_FORMAT, GST_TIME_ARGS(GST_BUFFER_PTS(buffer)));
        }
      }

      decoded_count++;

      if (last_log_time == 0) {
        last_log_time = now;
      } else if (now - last_log_time > GST_SECOND) {
        double fps = decoded_count * GST_SECOND / (double)(now - last_log_time);
        ALOGI(">>> Decoder output: %.2f fps", fps);
        decoded_count = 0;
        last_log_time = now;
      }
    }
  }

  return GST_PAD_PROBE_OK;
}

GstPadProbeReturn RtpMpegTsPlayerGst::OnSinkInput(GstPad* pad, GstPadProbeInfo* info, gpointer user_data) {
  RtpMpegTsPlayerGst* self = static_cast<RtpMpegTsPlayerGst*>(user_data);

  GstBuffer* buffer = gst_pad_probe_info_get_buffer(info);
  if (buffer) {
    static int sink_count = 0;
    static GstClockTime last_log = 0;

    sink_count++;
    GstClockTime now = g_get_monotonic_time() * 1000;

    static int logged_buffers = 0;
    if (logged_buffers == 0 && GST_BUFFER_PTS(buffer) != GST_CLOCK_TIME_NONE) {
      ALOGI("*** FIRST FRAME REACHED SINK ***");
      ALOGI("  PTS: %" GST_TIME_FORMAT, GST_TIME_ARGS(GST_BUFFER_PTS(buffer)));
      logged_buffers++;
    }

    if (last_log == 0) {
      last_log = now;
    } else if (now - last_log > GST_SECOND) {
      double fps = sink_count * GST_SECOND / (double)(now - last_log);
      ALOGI(">>> Sink: %.2f fps", fps);
      sink_count = 0;
      last_log = now;
    }
  }

  return GST_PAD_PROBE_OK;
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

  ResetBacklogTracker();
  waiting_for_keyframe_.store(true);  // *** 初始設為 true ***

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
  decoder_ = gst_element_factory_make("amcviddec-omxgoogleh264decoder", "decoder");
  video_sink_ = gst_element_factory_make("glimagesink", "glimagesink");

  // *** 禁用 decoder 的 QoS，避免在 base_time 重置期間 drop frames ***
  if (decoder_) {
    g_object_set(decoder_, "qos", FALSE, NULL);

    // 驗證設定是否生效
    gboolean qos_enabled = TRUE;
    g_object_get(decoder_, "qos", &qos_enabled, NULL);
    ALOGI("Decoder: qos set to FALSE, verified qos=%s", qos_enabled ? "TRUE" : "FALSE");
  }

  if (!udpsrc_ || !rtpbin_ || !depay_ || !tsparse || !tsdemux_ ||
      !queue_ || !h264parse_ || !capsfilter_ || !decoder_ || !video_sink_) {
    ALOGE("Failed to create elements -> teardown");
    TeardownPipeline();
    return;
  }

  // *** RTPbin - 低延遲配置 ***
  g_object_set(rtpbin_,
               "latency", 50,  // 降低到 50ms
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

  // *** Video Sink - 啟用 sync 以保持 A/V 同步 ***
  if (video_sink_) {
    g_object_set(video_sink_,
                 "sync", TRUE,  // *** 啟用 sync，配合 clock provider 設定 ***
                 "async", FALSE,
                 "enable-last-sample", FALSE,
                 "force-aspect-ratio", FALSE,
                 "qos", TRUE,
                 "max-lateness", (gint64)-1,  // *** -1 = 永不 drop late buffers ***
                 "throttle-time", (guint64)0,
                 NULL);
    ALOGI("Video sink: sync=TRUE, qos=TRUE, max-lateness=-1, using video_sink as clock provider");

    AttachOverlay();
  }

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
  gst_debug_set_threshold_for_name("amcviddec-omxgoogleh264decoder", GST_LEVEL_INFO);
  gst_debug_set_threshold_for_name("h264parse", GST_LEVEL_INFO);
  gst_debug_set_threshold_for_name("queue", GST_LEVEL_INFO);
  gst_debug_set_threshold_for_name("glimagesink", GST_LEVEL_INFO);

  g_object_set(udpsrc_,
               "socket", socket_,
               "buffer-size", 4194304,
               NULL);

  gst_bin_add_many(GST_BIN(pipeline_), udpsrc_, rtpbin_, depay_, tsparse,
                   tsdemux_, queue_, h264parse_, capsfilter_, decoder_, NULL);

  if (!gst_bin_add(GST_BIN(pipeline_), video_sink_)) {
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

void RtpMpegTsPlayerGst::EnterKeyframeWait() {
  waiting_for_keyframe_.store(true);
}

void RtpMpegTsPlayerGst::ExitKeyframeWait() {
  waiting_for_keyframe_.store(false);
}

void RtpMpegTsPlayerGst::TeardownPipeline() {
  if (bus_) {
    gst_bus_remove_signal_watch(bus_);
    gst_object_unref(bus_);
    bus_ = nullptr;
  }
  ResetBacklogTracker();
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
  decoder_ = nullptr;
  video_sink_ = nullptr;
  udpsrc_ = nullptr;
  rtpbin_ = nullptr;
  depay_ = nullptr;
  capsfilter_ = nullptr;
  tsdemux_ = nullptr;
  volume_ = nullptr;
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

void RtpMpegTsPlayerGst::OnQueueOverrun(GstElement* queue, gpointer user_data) {
  // Queue 滿了，但不會自動丟棄，因為我們在 probe 中已經處理了
  static int overrun_count = 0;
  if (++overrun_count % 10 == 0) {
    ALOGW("Queue OVERRUN #%d - probe should be dropping delta units", overrun_count);
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
