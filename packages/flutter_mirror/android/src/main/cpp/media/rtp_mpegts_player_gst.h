// RTP MPEG-TS player using GStreamer for Android.
// One statement per line and braces for all blocks per user request.

#pragma once

#include <atomic>
#include <cstdint>
#include <mutex>
#include <thread>

#include <android/native_window.h>
#include <android/native_window_jni.h>
#include <jni.h>

#include <gio/gio.h>
#include <gst/gst.h>
#include <gst/video/videooverlay.h>

class RtpMpegTsPlayerGst final {
 public:
  RtpMpegTsPlayerGst();
  ~RtpMpegTsPlayerGst();

  bool Start();
  void Stop();
  uint16_t GetPort() const;
  void SetSurface(JNIEnv* env, jobject surface);

  void SetJavaInstance(JNIEnv* env, jobject thiz);
  void Pause();
  void Restart(JNIEnv* env, jobject surface);
  void SetMute(bool mute);

 private:
  static void OnBusMessage(GstBus* bus, GstMessage* message, gpointer user_data);
  static void OnDemuxPadAdded(GstElement* demux, GstPad* pad, gpointer user_data);
  static void OnRtpbinPadAdded(GstElement* rtpbin, GstPad* new_pad, gpointer user_data);
  static GstPadProbeReturn OnCapsProbe(GstPad* pad, GstPadProbeInfo* info, gpointer user_data);
  static GstCaps* OnRequestPtMap(GstElement* rtpbin, guint session, guint pt, gpointer user_data);
  static GstPadProbeReturn OnDepayEvent(GstPad* pad, GstPadProbeInfo* info, gpointer user_data);
  static GstPadProbeReturn OnQueueSinkProbe(GstPad* pad, GstPadProbeInfo* info, gpointer user_data);
  static GstPadProbeReturn OnDecoderInput(GstPad* pad, GstPadProbeInfo* info, gpointer user_data);

  static void OnNewJitterBuffer(GstElement* rtpbin, GstElement* jitterbuffer, guint session, guint ssrc, gpointer user_data);
  static void OnQueueOverrun(GstElement* queue, gpointer user_data);
  static GstPadProbeReturn OnDecoderOutput(GstPad* pad, GstPadProbeInfo* info, gpointer user_data);
  static GstPadProbeReturn OnSinkInput(GstPad* pad, GstPadProbeInfo* info, gpointer user_data);

  void ConnectAudioPad(GstPad* pad);
  void ConnectVideoPad(GstPad* pad);
  void NotifyVideoResolution(int width, int height);
  void NotifyPacketLost();
  void ResetBacklogTracker();

  void HandleBusMessage(GstMessage* message);
  void EnsurePipeline();
  void TeardownPipeline();
  void AttachOverlay();
  GSocket* CreateBoundSocket(uint16_t requested_port);
  void RunMainLoop();
  void ReleaseWindowHandle();

  void EnterKeyframeWait();
  void ExitKeyframeWait();

 private:
  mutable std::mutex mutex_;
  ANativeWindow* native_window_ = nullptr;
  guintptr overlay_handle_ = 0;

  GMainContext* context_ = nullptr;
  GMainLoop* loop_ = nullptr;
  std::thread loop_thread_;

  GstElement* pipeline_ = nullptr;
  GstElement* udpsrc_ = nullptr;
  GstElement* rtpbin_ = nullptr;
  GstElement* depay_ = nullptr;
  GstElement* tsdemux_ = nullptr;
  GstElement* video_sink_ = nullptr;
  GstElement* h264parse_ = nullptr;
  GstElement* capsfilter_ = nullptr;
  GstElement* decoder_ = nullptr;
  GstElement* queue_ = nullptr;
  GstElement* volume_ = nullptr;
  GstBus* bus_ = nullptr;

  GSocket* socket_ = nullptr;
  uint16_t bound_port_ = 0;
  bool playing_ = false;

  GstPad* rtpbin_rtp_sink_pad_ = nullptr;

  jobject java_instance_ = nullptr;

  std::atomic<bool> is_paused_{false};
  std::atomic<GstClockTime> backlog_first_pts_{GST_CLOCK_TIME_NONE};
  GstClockTime backlog_threshold_ns_ = 1000 * GST_MSECOND;
  std::atomic<bool> waiting_for_keyframe_{true};
  std::atomic<bool> queue_restore_pending_{false};
  std::atomic<GstClockTime> pts_offset_{GST_CLOCK_TIME_NONE};  // PTS offset to reset to 0

  // Per-instance statistics (instead of static)
  int keyframe_preserved_count_ = 0;
  int drop_count_ = 0;
  int frame_count_ = 0;
  int warning_count_ = 0;
  bool first_decoder_input_logged_ = false;
  int decoder_input_count_ = 0;
  int qos_log_count_ = 0;
  int decoded_count_ = 0;
  GstClockTime last_log_time_ = 0;
  GstClockTime first_buffer_time_ = 0;
  int sink_count_ = 0;
  GstClockTime last_log_ = 0;
  int logged_buffers_ = 0;
  int overrun_count_ = 0;
};
