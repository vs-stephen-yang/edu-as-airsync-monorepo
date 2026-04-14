#include "media/media_session_dump.h"
#include <chrono>
#include "util/log.h"

MediaSessionDump::MediaSessionDump(MediaSessionPtr media_session, const std::string& path)
    : media_session_(std::move(media_session)),
      path_(path) {
  writer_ = std::make_unique<VideoFrameWriter>(path);
}

bool MediaSessionDump::Start(
    MediaSession::Listener* listener,
    VideoCodecType video_codec,
    AudioCodecType audio_codec,
    AudioFormat audio_format) {
  ALOGD("Start dump media to %s", path_.c_str());

  start_time_ = std::chrono::system_clock::now();

  return media_session_->Start(listener, video_codec, audio_codec, audio_format);
}

SurfaceTexture MediaSessionDump::GetTexture() {
  return media_session_->GetTexture();
}

void MediaSessionDump::Stop() {
  media_session_->Stop();
}

void MediaSessionDump::EnableAudio(bool enable) {
  media_session_->EnableAudio(enable);
}

void MediaSessionDump::OnAudioFrame(
    std::shared_ptr<std::vector<uint8_t>> frame,
    uint64_t timestamp_us) {
  // media_session_->OnAudioFrame(frame, timestamp_us);
}

uint64_t MediaSessionDump::ElapsedTime() {
  // Get the current time
  auto current_time = std::chrono::system_clock::now();

  // Calculate the elapsed time in microseconds
  auto elapsed_microseconds = std::chrono::duration_cast<std::chrono::microseconds>(
      current_time - start_time_);

  return static_cast<uint64_t>(elapsed_microseconds.count());
}

void MediaSessionDump::OnVideoFrame(
    bool key_frame,
    std::shared_ptr<std::vector<uint8_t>> frame,
    uint64_t timestamp_us) {
  writer_->writeFrame(*frame, ElapsedTime());

  // media_session_->OnVideoFrame(key_frame, frame, timestamp_us);
}
