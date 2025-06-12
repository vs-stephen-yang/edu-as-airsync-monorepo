#include "./airplay/ap_mirror_session.h"
#include <assert.h>
#include "util/log.h"

ApMirrorSession::ApMirrorSession(
    const std::string& mirror_id,
    const std::string& device_name,
    const std::string& device_model,
    MirrorListener& mirror_listener,
    ap::AirplayMirrorSessionPtr session)
    : mirror_id_(mirror_id),
      device_name_(device_name),
      device_model_(device_model),
      mirror_listener_(mirror_listener),
      session_(session) {
  assert(session);
  ALOGV("ApMirrorSession()");

  session_->RegisterListener(this);
}

ApMirrorSession::~ApMirrorSession() {
  ALOGV("~ApMirrorSession()");
}

bool ApMirrorSession::StartMirror(
    MediaSessionPtr media_session) {
  ALOGD("ApMirrorSession::StartMirror()");

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
  ALOGD("ApMirrorSession::StopMirror()");

  // Note that StopMirror() is asynchronous.
  // StopMirror() will stop the mirror and trigger OnMirrorStop callback
  session_->StopMirror();
}

void ApMirrorSession::OnMirrorStop() {
  ALOGD("ApMirrorSession::OnMirrorStop()");

  Close();
  mirror_listener_.OnMirrorStop(this);
}

void ApMirrorSession::Close() {
  if (media_session_) {
    media_session_->Stop();
  }
}

void ApMirrorSession::OnVideoFormatChanged(
    int width,
    int height) {
  mirror_listener_.OnMirrorVideoResize(
      this,
      width,
      height);
}

void ApMirrorSession::OnVideoFrameRate(int fps) {
  mirror_listener_.OnMirrorVideoFrameRate(this, fps);
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
  return device_name_;
}

MirrorType ApMirrorSession::GetMirrorType() {
  return MirrorType::Airplay;
}

void ApMirrorSession::EnableAudio(bool enable) {
  if (media_session_) {
    media_session_->EnableAudio(enable);
  }
}
