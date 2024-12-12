#ifndef FLUTTER_MIRROR_PLUGIN_REPLAY_MIRROR_SESSION_H_
#define FLUTTER_MIRROR_PLUGIN_REPLAY_MIRROR_SESSION_H_

#include <memory>

#include <thread>
#include "cast/cast_mirror_session.h"
#include "cast/media_formats.h"
#include "jni/texture_registry.h"
#include "media/audio_decoder.h"
#include "media/video_decoder.h"
#include "mirror_listener.h"
#include "mirror_session.h"

class ReplayMirrorSession
    : public MirrorSession,
      public MediaSession::Listener {
 public:
  ReplayMirrorSession(
      const std::string& mirror_id,
      MirrorListener& mirror_listener,
      const std::string& videoCodec,
      const std::string& videoPath);

  ~ReplayMirrorSession();

  // implements MirrorSession
  virtual bool StartMirror(MediaSessionPtr media_session) override;

  virtual std::string GetMirrorId() override;
  virtual SurfaceTexture GetTexture() override;
  virtual std::string GetSourceDisplayName() override;

  virtual MirrorType GetMirrorType() override;

  virtual void EnableAudio(bool enable) override;
  virtual void StopMirror() override;

  virtual void Close() override;

  // implements MediaSession::Listener
  virtual void OnVideoFormatChanged(int width, int height) override;
  virtual void OnVideoFrameRate(int fps) override;

 private:
  void VideoReaderThread();

  const std::string mirror_id_;
  MirrorListener& mirror_listener_;

  std::string videoCodec_;
  std::string videoPath_;

  MediaSessionPtr media_session_;

  std::thread video_thread_;
  std::atomic<bool> running_{false};
};
typedef std::shared_ptr<ReplayMirrorSession> ReplayMirrorSessionPtr;

#endif  // FLUTTER_MIRROR_PLUGIN_REPLAY_MIRROR_SESSION_H_
