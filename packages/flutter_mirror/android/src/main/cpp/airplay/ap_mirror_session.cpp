#include "./airplay/ap_mirror_session.h"
#include <assert.h>
#include "util/log.h"

ApMirrorSession::ApMirrorSession(
    const std::string& mirror_id,
    MirrorListener& mirror_listener,
    ap::AirplayMirrorSessionPtr session)
    : mirror_id_(mirror_id),
      mirror_listener_(mirror_listener),
      session_(session) {
  assert(session);

  session_->RegisterListener(this);
}

ApMirrorSession::~ApMirrorSession() {
  ALOGV("~ApMirrorSession()");
}

bool ApMirrorSession::StartMirror(
    MediaSessionPtr media_session) {
  ALOGI("Starting an Airplay mirror session");

  media_session_ = std::move(media_session);

  AudioFormat audio_format;
  audio_format.sample_rate = 44100;
  audio_format.channel_count = 2;
  audio_format.has_adts = false;

  return media_session_->Start(
      this,
      VideoCodecType::kH264,
      AudioCodecType::kAac,
      audio_format);
}

void ApMirrorSession::StopMirror() {
  session_->Stop();

  if (media_session_) {
    media_session_->Stop();
  }
}

void ApMirrorSession::OnMirrorStop() {
  if (media_session_) {
    media_session_->Stop();
  }

  mirror_listener_.OnMirrorStop(this);
}

void ApMirrorSession::OnVideoFormatChanged(
    int width,
    int height) {
  mirror_listener_.OnMirrorVideoResize(
      this,
      width,
      height);
}

void ApMirrorSession::OnMirrorEvent(
    ap::AirplayMirrorSession::Listener::Event ev) {
  switch (ev) {
    case ap::AirplayMirrorSession::Listener::Event::kMirrorStop:
      OnMirrorStop();
      break;
    default:
      break;
  }
}

void ApMirrorSession::OnAudioFrame(
    std::shared_ptr<std::vector<uint8_t>> frame,
    uint64_t timestamp_us) {
  if (!media_session_) {
    return;
  }

  media_session_->OnAudioFrame(
      frame,
      timestamp_us);
}

void ApMirrorSession::OnVideoFrame(
    bool key_frame,
    std::shared_ptr<std::vector<uint8_t>> frame,
    uint64_t timestamp_us) {
  if (!media_session_) {
    return;
  }

  media_session_->OnVideoFrame(
      key_frame,
      frame,
      timestamp_us);
}

std::string ApMirrorSession::GetMirrorId() {
  return mirror_id_;
}

SurfaceTexture ApMirrorSession::GetTexture() {
  return media_session_->GetTexture();
}
std::string ApMirrorSession::GetSourceDisplayName() {
  return "";
}

MirrorType ApMirrorSession::GetMirrorType() {
  return MirrorType::Airplay;
}

void ApMirrorSession::EnableAudio(bool enable) {
  if (media_session_) {
    media_session_->EnableAudio(enable);
  }
}
