#ifndef FLUTTER_MIRROR_PLUGIN_MEDIA_SESSION_H_
#define FLUTTER_MIRROR_PLUGIN_MEDIA_SESSION_H_

#include <map>
#include <memory>
#include <optional>
#include <string>
#include "jni/texture_registry.h"
#include "media/audio_decoder.h"
#include "media/video_csd.h"
#include "media/video_decoder.h"

class MediaSession {
 public:
  class Listener {
   public:
    virtual ~Listener() = default;

    virtual void OnVideoFormatChanged(
        int width,
        int height) = 0;

    virtual void OnVideoFrameRate(int fps) = 0;
  };

  virtual ~MediaSession() = default;

  virtual bool Start(
      MediaSession::Listener* listener,
      VideoCodecType video_codec,
      AudioCodecType audio_codec,
      AudioFormat audio_format) = 0;

  virtual SurfaceTexture GetTexture() = 0;

  virtual void Stop() = 0;

  virtual void EnableAudio(bool enable) = 0;

  virtual void OnAudioFrame(
      std::shared_ptr<std::vector<uint8_t>> frame,
      uint64_t timestamp_us) = 0;

  virtual void OnVideoFrame(
      bool key_frame,
      std::shared_ptr<std::vector<uint8_t>> frame,
      uint64_t timestamp_us) = 0;
};

typedef std::unique_ptr<MediaSession> MediaSessionPtr;
#endif  // FLUTTER_MIRROR_PLUGIN_MEDIA_SESSION_H_
