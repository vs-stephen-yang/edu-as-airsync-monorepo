// RTP MPEG-TS player using GStreamer for Android.
// One statement per line and braces for all blocks per user request.

#pragma once

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

 private:
  static void OnBusMessage(GstBus* bus, GstMessage* message, gpointer user_data);
  static void OnDemuxPadAdded(GstElement* demux, GstPad* pad, gpointer user_data);
  static void OnDecodebinPadAdded(GstElement* decodebin, GstPad* pad, gpointer user_data);
  static void OnRtpbinPadAdded(GstElement* rtpbin, GstPad* new_pad, gpointer user_data);
  static GstPadProbeReturn OnCapsProbe(GstPad* pad, GstPadProbeInfo* info, gpointer user_data);
  static GstCaps* OnRequestPtMap(GstElement* rtpbin, guint session, guint pt, gpointer user_data);
  void ConnectAudioPad(GstPad* pad);
  void ConnectVideoPad(GstPad* pad);
  void NotifyVideoResolution(int width, int height);

  void HandleBusMessage(GstMessage* message);
  void EnsurePipeline();
  void TeardownPipeline();
  void AttachOverlay();
  GSocket* CreateBoundSocket(uint16_t requested_port);
  void RunMainLoop();
  void ReleaseWindowHandle();

 private:
  mutable std::mutex mutex_;
  ANativeWindow* native_window_;
  guintptr overlay_handle_;

  GMainContext* context_;
  GMainLoop* loop_;
  std::thread loop_thread_;

  GstElement* pipeline_;
  GstElement* udpsrc_;
  GstElement* rtpbin_;
  GstElement* depay_;
  GstElement* tsparse_;
  GstElement* tsdemux_;
  GstElement* video_queue_;
  GstElement* decodebin_;
  GstElement* video_sink_;
  GstBus* bus_;

  GSocket* socket_;
  uint16_t bound_port_;
  bool playing_;

  GstPad* rtpbin_rtp_sink_pad_;

  jobject java_instance_ = nullptr;

  std::atomic<bool> is_paused_{false};
};
