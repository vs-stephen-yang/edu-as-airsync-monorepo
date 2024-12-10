#ifndef FLUTTER_MIRROR_PLUGIN_MEDIA_SESSION_DUMP_H_
#define FLUTTER_MIRROR_PLUGIN_MEDIA_SESSION_DUMP_H_

#include <chrono>
#include <map>
#include <memory>
#include <optional>
#include <string>
#include <vector>
#include "media/media_session.h"
#include "media/video_frame_writer.h"

class MediaSessionDump : public MediaSession {
 public:
  MediaSessionDump(MediaSessionPtr media_session, const std::string& path);

  virtual bool Start(
      MediaSession::Listener* listener,
      VideoCodecType video_codec,
      AudioCodecType audio_codec,
      AudioFormat audio_format) override;

  virtual SurfaceTexture GetTexture() override;

  virtual void Stop() override;

  virtual void EnableAudio(bool enable) override;

  virtual void OnAudioFrame(
      std::shared_ptr<std::vector<uint8_t>> frame,
      uint64_t timestamp_us) override;

  virtual void OnVideoFrame(
      bool key_frame,
      std::shared_ptr<std::vector<uint8_t>> frame,
      uint64_t timestamp_us) override;

 private:
  uint64_t ElapsedTime();

  std::chrono::time_point<std::chrono::system_clock> start_time_;

  MediaSessionPtr media_session_;
  std::string path_;

  std::unique_ptr<VideoFrameWriter> writer_;
};

#endif  // #define FLUTTER_MIRROR_PLUGIN_MEDIA_SESSION_DUMP_H_
