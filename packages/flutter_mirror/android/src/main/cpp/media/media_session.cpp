#include "media/media_session.h"
#include <assert.h>
#include "util/log.h"

MediaSession::MediaSession(
    jni::TextureRegistry& texture_registry)
    : texture_registry_(texture_registry) {
}

MediaSession::~MediaSession() {
  ALOGV("~MediaSession()");
}

bool MediaSession::Start(
    MediaSession::Listener* listener,
    VideoCodecType video_codec,
    AudioCodecType audio_codec,
    AudioFormat audio_format) {
  assert(listener);

  listener_ = listener;

  // create video decoder
  if (!CreateVideoDecoder(video_codec)) {
    return false;
  }

  // create audio decoder
  if (!CreateAudioDecoder(
          audio_codec,
          audio_format)) {
    return false;
  }

  if (!video_decoder_->Start()) {
    return false;
  }

  if (!audio_decoder_->Start()) {
    return false;
  }

  return true;
}

SurfaceTexture MediaSession::GetTexture() {
  return texture_;
}

void MediaSession::Stop() {
  if (video_decoder_) {
    video_decoder_->Stop();
  }
  texture_registry_.ReleaseSurfaceTexture(texture_);

  if (audio_decoder_) {
    audio_decoder_->Stop();
  }
}

bool MediaSession::CreateVideoDecoder(
    VideoCodecType codec_type) {
  // create a surface texture
  texture_ = texture_registry_.CreateSurfaceTexture();
  if (!texture_.wnd) {
    return false;
  }

  // create a video decoder that renders to the surface texture
  auto decoder = ::CreateVideoDecoder(
      codec_type,
      texture_.wnd,
      this);

  if (!decoder) {
    return false;
  }

  video_decoder_ = std::move(decoder);

  return true;
}

bool MediaSession::CreateAudioDecoder(
    AudioCodecType audio_codec,
    AudioFormat audio_format) {
  audio_decoder_ = ::CreateAudioDecoder(
      audio_codec,
      audio_format);

  if (!audio_decoder_) {
    return false;
  }

  return audio_decoder_->Init();
}

void MediaSession::OnVideoFormatChanged(
    int width,
    int height) {
  listener_->OnVideoFormatChanged(
      width,
      height);
}

void MediaSession::OnAudioFrame(
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

void MediaSession::OnVideoFrame(
    bool key_frame,
    std::shared_ptr<std::vector<uint8_t>> frame,
    uint64_t timestamp_us) {
  if (!video_decoder_) {
    return;
  }

  // decode video frame
  video_decoder_->Decode(
      frame->data(),
      frame->size(),
      timestamp_us);
}

void MediaSession::EnableAudio(bool enable) {
  if (audio_decoder_) {
    audio_decoder_->EnablePlayback(enable);
  }
}
