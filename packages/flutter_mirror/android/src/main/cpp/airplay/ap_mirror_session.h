#ifndef FLUTTER_MIRROR_PLUGIN_AP_MIRROR_SESSION_H_
#define FLUTTER_MIRROR_PLUGIN_AP_MIRROR_SESSION_H_

#include <memory>

#include "airplay/airplay_mirror_session.h"
#include "media/media_session.h"
#include "media/surface_texture.h"
#include "mirror_listener.h"
#include "mirror_session.h"

class ApMirrorSession
    : public MirrorSession,
      public MediaSession::Listener,
      public ap::AirplayMirrorSession::Listener {
 public:
  ApMirrorSession(
      const std::string& mirror_id,
      const std::string& device_name,
      MirrorListener& mirror_listener,
      ap::AirplayMirrorSessionPtr session);

  ~ApMirrorSession();

  // implements MirrorSession
  virtual bool StartMirror(
      MediaSessionPtr media_session) override;

  virtual std::string GetMirrorId() override;
  virtual SurfaceTexture GetTexture() override;
  virtual std::string GetSourceDisplayName() override;

  virtual MirrorType GetMirrorType() override;

  virtual void EnableAudio(bool enable) override;
  virtual void StopMirror() override;

  virtual void Close() override;

  // implements MediaSession::Listener
  virtual void OnVideoFormatChanged(
      int width,
      int height) override;

  virtual void OnVideoFrameRate(int fps) override;

  // implements AirplayMirrorSession::Listener
  virtual void OnMirrorEvent(
      ap::AirplayMirrorSession::Listener::Event ev) override;

  virtual void OnAudioFrame(
      std::shared_ptr<std::vector<uint8_t>> frame,
      uint64_t timestamp_us) override;

  virtual void OnVideoFrame(
      bool key_frame,
      std::shared_ptr<std::vector<uint8_t>> frame,
      uint64_t timestamp_us) override;

 private:
  void OnMirrorStop();

 private:
  std::string mirror_id_;
  std::string device_name_;

  MirrorListener& mirror_listener_;

  ap::AirplayMirrorSessionPtr session_;

  MediaSessionPtr media_session_;
};

typedef std::shared_ptr<ApMirrorSession> ApMirrorSessionPtr;

#endif  // FLUTTER_MIRROR_PLUGIN_AP_MIRROR_SESSION_H_
