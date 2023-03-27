#include "./airplay/ap_mirror_session.h"
#include <assert.h>
#include "airplay/ap_receiver.h"
#include "media/audio_decoder.h"
#include "media/video_decoder_ndk.h"
#include "util/log.h"

ApMirrorSession::ApMirrorSession(
    const std::string& mirror_id,
    MirrorListener& mirror_listener,
    jni::TextureRegistry& texture_registry,
    ap::AirplayMirrorSessionPtr session)
    : mirror_id_(mirror_id),
      mirror_listener_(mirror_listener),
      texture_registry_(texture_registry),
      session_(session) {
  assert(session);

  session_->RegisterListener(this);
}

void ApMirrorSession::StartMirror() {
  ALOGI("Starting an Airplay mirror session");

  CreateVideoDecoder();
}

void ApMirrorSession::StopMirror() {
  session_->Stop();

  if (video_decoder_) {
    video_decoder_->Stop();
  }
  if (audio_decoder_) {
    audio_decoder_->Stop();
  }

  texture_registry_.ReleaseSurfaceTexture(texture_);
}

void ApMirrorSession::CreateVideoDecoder() {
  // create a surface texture
  texture_ = texture_registry_.CreateSurfaceTexture();
  assert(texture_.wnd);

  // create a video decoder that renders to the surface texture
  auto decoder = std::make_unique<VideoDecoderNdk>(this);

  decoder->Init(
      VideoDecoderNdk::kMimeH264,
      texture_.wnd);

  video_decoder_ = std::move(decoder);
  video_decoder_->Start();
}

void ApMirrorSession::CreateAudioDecoder() {
  if (audio_decoder_) {
    audio_decoder_->Stop();
  }

  audio_decoder_ = CreateAacDecoder(
      44100,
      2,
      false);
  audio_decoder_->Init();
  audio_decoder_->Start();
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
    case ap::AirplayMirrorSession::Listener::Event::kAudioStart:
      CreateAudioDecoder();
      break;
    case ap::AirplayMirrorSession::Listener::Event::kMirrorStop:
      mirror_listener_.OnMirrorStop(this);
      break;
    default:
      break;
  }
}

void ApMirrorSession::OnAudioFrame(
    std::shared_ptr<std::vector<uint8_t>> frame,
    uint64_t timestamp_us) {
  if (!audio_decoder_) {
    return;
  }

  // decode audio frame
  audio_decoder_->Decode(
      frame,
      timestamp_us);
}

void ApMirrorSession::OnVideoFrame(
    bool key_frame,
    std::shared_ptr<std::vector<uint8_t>> frame,
    uint64_t timestamp_us) {
  assert(video_decoder_);

  if (!video_decoder_) {
    return;
  }

  // decode video frame
  video_decoder_->Decode(
      frame->data(),
      frame->size(),
      timestamp_us);
}

std::string ApMirrorSession::GetMirrorId() {
  return mirror_id_;
}

SurfaceTexture ApMirrorSession::GetTexture() {
  return texture_;
}
std::string ApMirrorSession::GetSourceDisplayName() {
  return "";
}

MirrorType ApMirrorSession::GetMirrorType() {
  return MirrorType::Airplay;
}
