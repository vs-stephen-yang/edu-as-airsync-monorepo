#include "media/media_session.h"
#include <assert.h>
#include "media/video_csd_util.h"
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
  ALOGD("MediaSession::Start()");

  listener_ = listener;

  // create a surface texture
  texture_ = texture_registry_.CreateSurfaceTexture();
  if (!texture_.wnd) {
    ALOGE("Failed to create surface texture");
    return false;
  }
  video_codec_ = video_codec;

  // create audio decoder
  if (!CreateAudioDecoder(
          audio_codec,
          audio_format)) {
    return false;
  }

  if (!audio_decoder_->Start()) {
    ALOGE("Failed to start audio decoder");
    return false;
  }

  return true;
}

SurfaceTexture MediaSession::GetTexture() {
  return texture_;
}

void MediaSession::Stop() {
  ALOGD("MediaSession::Stop()");

  if (video_decoder_) {
    video_decoder_->Stop();
  }
  texture_registry_.ReleaseSurfaceTexture(texture_);

  if (audio_decoder_) {
    audio_decoder_->Stop();
  }

  ALOGD("MediaSession::Stop() done");
}

bool MediaSession::CreateVideoDecoder(
    VideoCodecType codec_type) {
  ALOGD("MediaSession::CreateVideoDecoder()");
  assert(csd_);

  // create a video decoder that renders to the surface texture
  auto decoder = ::CreateVideoDecoder(
      codec_type,
      false,
      *csd_,
      texture_.wnd,
      this);

  if (!decoder) {
    ALOGE("Failed to create video decoder");
    return false;
  }

  video_decoder_ = std::move(decoder);

  return true;
}

bool MediaSession::CreateAudioDecoder(
    AudioCodecType audio_codec,
    AudioFormat audio_format) {
  ALOGD("MediaSession::CreateAudioDecoder()");

  audio_decoder_ = ::CreateAudioDecoder(
      audio_codec,
      audio_format);

  if (!audio_decoder_) {
    ALOGE("Failed to create audio decoder");
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
  if (key_frame) {
    ALOGD("Received video key frame");
  }

  HandleVideoCsd(
      frame->data(),
      frame->size());

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
  ALOGD("MediaSession::EnableAudio(%d)", enable);

  if (audio_decoder_) {
    audio_decoder_->EnablePlayback(enable);
  }
}

void MediaSession::HandleVideoCsd(
    const uint8_t* frame,
    size_t size) {
  std::optional<VideoCsd> csd = ParseVideoCsd(
      video_codec_,
      std::span(frame, frame + size));

  if (!csd.has_value()) {
    return;
  }

  if (csd_.has_value() &&
      csd->width == csd_->width &&
      csd->height == csd_->height) {
    return;
  }

  ALOGI("The video size has changed to %ux%u",
        csd->width,
        csd->height);

  csd_ = csd;

  ResetVideoDecoder();
}

void MediaSession::ResetVideoDecoder() {
  ALOGI("Reset video decoder");

  if (video_decoder_) {
    video_decoder_->Stop();
  }
  video_decoder_.reset();

  // create video decoder
  if (!CreateVideoDecoder(video_codec_)) {
    return;
  }

  if (!video_decoder_->Start()) {
    ALOGE("Failed to start video decoder");
    return;
  }
}
