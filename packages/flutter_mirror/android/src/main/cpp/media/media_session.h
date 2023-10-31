#ifndef FLUTTER_MIRROR_PLUGIN_MEDIA_SESSION_H_
#define FLUTTER_MIRROR_PLUGIN_MEDIA_SESSION_H_

#include <memory>
#include <optional>
#include "jni/texture_registry.h"
#include "media/audio_decoder.h"
#include "media/video_csd.h"
#include "media/video_decoder.h"

class MediaSession
    : public VideoDecoder::Callback {
 public:
  class Listener {
   public:
    virtual ~Listener() = default;

    virtual void OnVideoFormatChanged(
        int width,
        int height) = 0;
  };

  MediaSession(
      jni::TextureRegistry& texture_registry);

  ~MediaSession();

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

  MediaSession::Listener* listener_ = nullptr;

  jni::TextureRegistry& texture_registry_;

  // video
  std::unique_ptr<VideoDecoder> video_decoder_;
  SurfaceTexture texture_;
  VideoCodecType video_codec_;
  std::optional<VideoCsd> csd_;  // codec-specific data

  // audio
  std::unique_ptr<AudioDecoder> audio_decoder_;
};

typedef std::unique_ptr<MediaSession> MediaSessionPtr;
#endif  // FLUTTER_MIRROR_PLUGIN_MEDIA_SESSION_H_
