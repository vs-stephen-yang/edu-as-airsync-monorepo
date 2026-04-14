#ifndef FLUTTER_MIRROR_PLUGIN_GOOGLECAST_MIRROR_SESSION_H_
#define FLUTTER_MIRROR_PLUGIN_GOOGLECAST_MIRROR_SESSION_H_

#include <memory>

#include "cast/cast_mirror_session.h"
#include "cast/media_formats.h"
#include "jni/texture_registry.h"
#include "media/audio_decoder.h"
#include "media/video_decoder.h"
#include "mirror_listener.h"
#include "mirror_session.h"

class GooglecastMirrorSession
    : public MirrorSession,
      public MediaSession::Listener,
      public openscreen::cast::CastMirrorSession::Listener {
 public:
  GooglecastMirrorSession(
      const std::string& mirror_id,
      const std::string& device_name,
      MirrorListener& mirror_listener,
      openscreen::cast::CastMirrorSessionPtr session,
      const openscreen::cast::MediaFormats& formats);

  ~GooglecastMirrorSession();

  // implements MirrorSession
  virtual bool StartMirror(
      MediaSessionPtr media_session) override;

  virtual std::string GetMirrorId() override;
  virtual SurfaceTexture GetTexture() override;
  virtual std::string GetSourceDisplayName() override;
  virtual std::string GetSourceDeviceModel() override;

  virtual MirrorType GetMirrorType() override;

  virtual void EnableAudio(bool enable) override;
  virtual void StopMirror() override;

  virtual void Close() override;

  // implements MediaSession::Listener
  virtual void OnVideoFormatChanged(
      int width,
      int height) override;

  virtual void OnVideoFrameRate(int fps) override;

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
  void OnMirrorStop();

  const std::string mirror_id_;
  std::string device_name_;

  MirrorListener& mirror_listener_;

  openscreen::cast::CastMirrorSessionPtr session_;

  MediaSessionPtr media_session_;
  openscreen::cast::MediaFormats formats_;
};
typedef std::shared_ptr<GooglecastMirrorSession> GooglecastMirrorSessionPtr;

#endif  // FLUTTER_MIRROR_PLUGIN_GOOGLECAST_MIRROR_SESSION_H_
