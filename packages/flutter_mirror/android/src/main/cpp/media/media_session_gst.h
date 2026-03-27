#ifndef FLUTTER_MIRROR_PLUGIN_MEDIA_SESSION_GST_H_
#define FLUTTER_MIRROR_PLUGIN_MEDIA_SESSION_GST_H_

#include <chrono>
#include <map>
#include <memory>
#include <mutex>
#include <optional>
#include <string>

#include <gst/app/gstappsrc.h>
#include <gst/gst.h>

#include "jni/texture_registry.h"
#include "media/media_session.h"
#include "media/video_csd.h"
#include "media/video_decoder.h"

class MediaSessionGst
    : public MediaSession,
      public VideoDecoder::Callback {
 public:
  MediaSessionGst(
      jni::TextureRegistry& texture_registry,
      const std::map<std::string, int>& additional_codec_params);

  ~MediaSessionGst() override;

  bool Start(
      MediaSession::Listener* listener,
      VideoCodecType video_codec,
      AudioCodecType audio_codec,
      AudioFormat audio_format) override;

  SurfaceTexture GetTexture() override;

  void Stop() override;

  void EnableAudio(bool enable) override;

  void OnAudioFrame(
      std::shared_ptr<std::vector<uint8_t>> frame,
      uint64_t timestamp_us) override;

  void OnVideoFrame(
      bool key_frame,
      std::shared_ptr<std::vector<uint8_t>> frame,
      uint64_t timestamp_us) override;

 private:
  bool CreatePipeline();
  bool CreateAudioBranch();
  void TeardownPipeline();

  bool PushAudioBuffer(
      const uint8_t* data,
      size_t size,
      uint64_t timestamp_us);

  bool EnsureVideoDecoderLocked(
      const uint8_t* frame,
      size_t size,
      bool key_frame);
  void ResetVideoDecoderLocked();

  void UpdateAudioClock(uint64_t timestamp_us);
  std::optional<int64_t> GetVideoLeadUs(uint64_t video_pts_us);

  void OnVideoFormatChanged(
      int width,
      int height) override;
  void OnVideoFrameRate(int fps) override;

 private:
  MediaSession::Listener* listener_ = nullptr;

  jni::TextureRegistry& texture_registry_;
  const std::map<std::string, int>& additional_codec_params_;

  SurfaceTexture texture_;
  VideoCodecType video_codec_ = VideoCodecType::kH264;
  AudioCodecType audio_codec_ = AudioCodecType::kAac;
  AudioFormat audio_format_;

  GstElement* pipeline_ = nullptr;
  GstElement* audio_appsrc_ = nullptr;
  GstElement* audio_parser_ = nullptr;
  GstElement* audio_decoder_elem_ = nullptr;
  GstElement* audio_convert_ = nullptr;
  GstElement* audio_resample_ = nullptr;
  GstElement* audio_volume_ = nullptr;
  GstElement* audio_sink_ = nullptr;

  std::mutex video_decoder_mutex_;
  std::unique_ptr<VideoDecoder> video_decoder_;
  std::optional<VideoCsd> csd_;
  bool decoder_use_software_ = false;
  bool video_decoder_failed_ = false;
  bool awaiting_key_frame_ = true;

  std::mutex audio_clock_mutex_;
  bool have_audio_clock_ = false;
  uint64_t last_audio_pts_us_ = 0;
  std::chrono::steady_clock::time_point last_audio_clock_at_;
  bool audio_enabled_ = true;
  uint64_t audio_frame_count_ = 0;
  uint64_t audio_push_fail_count_ = 0;
  uint64_t video_drop_count_ = 0;
};

#endif  // FLUTTER_MIRROR_PLUGIN_MEDIA_SESSION_GST_H_
