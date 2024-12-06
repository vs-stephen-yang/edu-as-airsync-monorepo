#ifndef FLUTTER_MIRROR_PLUGIN_MEDIA_SESSION_IMPL_H_
#define FLUTTER_MIRROR_PLUGIN_MEDIA_SESSION_IMPL_H_

#include <map>
#include <memory>
#include <optional>
#include <string>
#include "jni/texture_registry.h"
#include "media/audio_decoder.h"
#include "media/video_csd.h"
#include "media/video_decoder.h"
#include "media/media_session.h"

class MediaSessionImpl
    : public MediaSession,
      public VideoDecoder::Callback {
 public:
  MediaSessionImpl(
      jni::TextureRegistry& texture_registry,
      const std::map<std::string, int>& additional_codec_params);

  ~MediaSessionImpl();

  bool Start(
      MediaSession::Listener* listener,
      VideoCodecType video_codec,
      AudioCodecType audio_codec,
      AudioFormat audio_format);

  SurfaceTexture GetTexture();

  void Stop();

  void EnableAudio(bool enable);

  void OnAudioFrame(
      std::shared_ptr<std::vector<uint8_t>> frame,
      uint64_t timestamp_us);

  void OnVideoFrame(
      bool key_frame,
      std::shared_ptr<std::vector<uint8_t>> frame,
      uint64_t timestamp_us);

 private:
  bool InitVideoDecoder(
      VideoCodecType codec_type,
      bool use_software_decoder);

  bool CreateAudioDecoder(
      AudioCodecType audio_codec,
      AudioFormat audio_format);

  void OnVideoFormatChanged(
      int width,
      int height);

 private:
  void HandleVideoCsd(
      const uint8_t* frame,
      size_t size);

  void ResetVideoDecoder();

  bool InitHardwareVideoDecoder();
  bool InitSoftwareVideoDecoder();

  MediaSessionImpl::Listener* listener_ = nullptr;

  jni::TextureRegistry& texture_registry_;
  const std::map<std::string, int>& additional_codec_params_;

  // video
  std::unique_ptr<VideoDecoder> video_decoder_;
  SurfaceTexture texture_;
  VideoCodecType video_codec_;
  std::optional<VideoCsd> csd_;  // codec-specific data

  // audio
  std::unique_ptr<AudioDecoder> audio_decoder_;
};

#endif  // FLUTTER_MIRROR_PLUGIN_MEDIA_SESSION_IMPL_H_
