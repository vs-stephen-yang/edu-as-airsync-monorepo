#include "media/media_session_dump.h"
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

void MediaSessionDump::OnVideoFrame(
    bool key_frame,
    std::shared_ptr<std::vector<uint8_t>> frame,
    uint64_t timestamp_us) {
  writer_->writeFrame(*frame, timestamp_us);

  // media_session_->OnVideoFrame(key_frame, frame, timestamp_us);
}
