#ifndef FLUTTER_MIRROR_PLUGIN_AP_MIRROR_SESSION_H_
#define FLUTTER_MIRROR_PLUGIN_AP_MIRROR_SESSION_H_

#include <memory>

#include "airplay/airplay_mirror_session.h"
#include "mirror_session.h"

#include "media/audio_decoder.h"
#include "media/surface_texture.h"
#include "media/video_decoder.h"

#include "jni/texture_registry.h"
#include "mirror_listener.h"

class ApMirrorSession
    : public VideoDecoder::Callback,
      public MirrorSession,
      public ap::AirplayMirrorSession::Listener {
 public:
  ApMirrorSession(
      const std::string& mirror_id,
      MirrorListener& mirror_listener,
      jni::TextureRegistry& texture_registry,
      ap::AirplayMirrorSessionPtr session);

  void StartMirror();

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
  void CreateAudioDecoder();
  void CreateVideoDecoder();

 private:
  std::string mirror_id_;
  MirrorListener& mirror_listener_;

  jni::TextureRegistry& texture_registry_;

  ap::AirplayMirrorSessionPtr session_;

  // video
  std::unique_ptr<VideoDecoder> video_decoder_;
  SurfaceTexture texture_;

  // audio
  std::unique_ptr<AudioDecoder> audio_decoder_;
};

typedef std::unique_ptr<ApMirrorSession> ApMirrorSessionPtr;

#endif  // FLUTTER_MIRROR_PLUGIN_AP_MIRROR_SESSION_H_
