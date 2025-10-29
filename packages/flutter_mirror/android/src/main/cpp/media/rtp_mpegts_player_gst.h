// RTP MPEG-TS player using GStreamer for Android.
// One statement per line and braces for all blocks per user request.

#pragma once

#include <atomic>
#include <cstdint>
#include <map>
#include <memory>
#include <mutex>
#include <optional>
#include <thread>

#include <android/native_window.h>
#include <android/native_window_jni.h>
#include <jni.h>

#include <gio/gio.h>
#include <gst/app/gstappsink.h>
#include <gst/gst.h>

#include "media/media_format.h"
#include "media/video_csd.h"
#include "media/video_decoder.h"

class RtpMpegTsPlayerGst final : public VideoDecoder::Callback {
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

  static void OnNewJitterBuffer(GstElement* rtpbin, GstElement* jitterbuffer, guint session, guint ssrc, gpointer user_data);
  static void OnQueueOverrun(GstElement* queue, gpointer user_data);
  static GstFlowReturn OnNewSampleCallback(GstAppSink* sink, gpointer user_data);
  GstFlowReturn OnNewSample(GstAppSink* sink);

  void ConnectAudioPad(GstPad* pad);
  void ConnectVideoPad(GstPad* pad);
  void NotifyVideoResolution(int width, int height);
  void NotifyPacketLost();

  void HandleBusMessage(GstMessage* message);
  void EnsurePipeline();
  void TeardownPipeline();
  GSocket* CreateBoundSocket(uint16_t requested_port);
  void RunMainLoop();
  void ReleaseWindowHandle();
  bool EnsureVideoDecoderLocked(const uint8_t* frame, size_t size, bool key_frame);
  void DispatchFrameToDecoder(const uint8_t* frame, size_t size, GstClockTime pts, bool key_frame);
  void ResetVideoDecoderLocked();
  GstFlowReturn HandleNewSample(GstSample* sample);

  // VideoDecoder::Callback
  void OnVideoFormatChanged(int width, int height) override;
  void OnVideoFrameRate(int fps) override;

 private:
  mutable std::mutex mutex_;
  ANativeWindow* native_window_ = nullptr;

  GMainContext* context_ = nullptr;
  GMainLoop* loop_ = nullptr;
  std::thread loop_thread_;

  GstElement* pipeline_ = nullptr;
  GstElement* udpsrc_ = nullptr;
  GstElement* rtpbin_ = nullptr;
  GstElement* depay_ = nullptr;
  GstElement* tsdemux_ = nullptr;
  GstElement* h264parse_ = nullptr;
  GstElement* capsfilter_ = nullptr;
  GstElement* video_appsink_ = nullptr;
  GstElement* queue_ = nullptr;
  GstElement* volume_ = nullptr;
  GstBus* bus_ = nullptr;

  GSocket* socket_ = nullptr;
  uint16_t bound_port_ = 0;
  bool playing_ = false;

  GstPad* rtpbin_rtp_sink_pad_ = nullptr;

  jobject java_instance_ = nullptr;

  std::atomic<bool> is_paused_{false};
  std::atomic<bool> queue_restore_pending_{false};

  // Per-instance statistics (instead of static)
  int overrun_count_ = 0;
  int queue_output_count_ = 0;

  VideoDecoderPtr video_decoder_;
  std::optional<VideoCsd> video_csd_;
  std::map<std::string, int> video_decoder_params_;
  bool decoder_use_software_ = false;
  bool video_decoder_failed_ = false;
  bool awaiting_key_frame_ = true;
};
