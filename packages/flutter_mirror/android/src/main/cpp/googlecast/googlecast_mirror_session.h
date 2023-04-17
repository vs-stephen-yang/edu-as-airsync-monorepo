#ifndef FLUTTER_MIRROR_PLUGIN_GOOGLECAST_MIRROR_SESSION_H_
#define FLUTTER_MIRROR_PLUGIN_GOOGLECAST_MIRROR_SESSION_H_

#include <memory>

#include "cast/cast_mirror_session.h"
#include "jni/texture_registry.h"
#include "media/audio_decoder.h"
#include "media/video_decoder.h"
#include "mirror_listener.h"
#include "mirror_session.h"

class GooglecastMirrorSession
    : public VideoDecoder::Callback,
      public MirrorSession,
      public openscreen::cast::CastMirrorSession::Listener {
 public:
  GooglecastMirrorSession(
      const std::string& mirror_id,
      MirrorListener& mirror_listener,
      jni::TextureRegistry& texture_registry,
      openscreen::cast::CastMirrorSessionPtr session);

  bool StartMirror();

  // implements MirrorSession
  virtual std::string GetMirrorId() override;
  virtual SurfaceTexture GetTexture() override;
  virtual std::string GetSourceDisplayName() override;

  virtual MirrorType GetMirrorType() override;

  virtual void EnableAudio(bool enable) override;
  virtual void StopMirror() override;

  // implements VideoDecoder::Callback
  virtual void OnVideoFormatChanged(
      int width,
      int height) override;

  // implements CastMirrorSession::Listener
  virtual void OnMirrorEvent(
      openscreen::cast::CastMirrorSession::Listener::Event ev) override;

  virtual void OnAudioFrame(
      std::shared_ptr<std::vector<uint8_t>> frame,
      uint64_t timestamp_us) override;

  virtual void OnVideoFrame(
      bool key_frame,
      std::shared_ptr<std::vector<uint8_t>> frame,
      uint64_t timestamp_us) override;

 private:
  bool CreateVideoDecoder(
      const openscreen::cast::CastMirrorSession::MediaFormats& formats);
  bool CreateAudioDecoder(
      const openscreen::cast::CastMirrorSession::MediaFormats& formats);

 private:
  const std::string mirror_id_;
  MirrorListener& mirror_listener_;

  jni::TextureRegistry& texture_registry_;

  openscreen::cast::CastMirrorSessionPtr session_;

  // video
  std::unique_ptr<VideoDecoder> video_decoder_;
  SurfaceTexture texture_;

  // audio
  std::unique_ptr<AudioDecoder> audio_decoder_;
};
typedef std::unique_ptr<GooglecastMirrorSession> GooglecastMirrorSessionPtr;

#endif  // FLUTTER_MIRROR_PLUGIN_GOOGLECAST_MIRROR_SESSION_H_
