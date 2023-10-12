#include "media/media_session.h"
#include <assert.h>
#include "common_video/h264/h264_bitstream_parser.h"
#include "util/log.h"

namespace {

struct VideoSize {
  unsigned int width;
  unsigned int height;
};

std::optional<VideoSize> ParseH264VideoSize(
    std::span<const uint8_t> frame) {
  webrtc::H264BitstreamParser parser;

  parser.ParseBitstream(frame);

  if (!parser.sps_.has_value()) {
    return std::nullopt;
  }

  return VideoSize{
      parser.sps_->width,
      parser.sps_->height};
}

std::optional<VideoSize> ParseVideoSize(
    VideoCodecType codec_type,
    std::span<const uint8_t> frame) {
  switch (codec_type) {
    case VideoCodecType::kH264:
      return ParseH264VideoSize(frame);

    default:
      return std::nullopt;
  }
}

}  // namespace
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

  // create video decoder
  video_codec_ = video_codec;
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
    ALOGE("Failed to start video decoder");
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

  // create a video decoder that renders to the surface texture
  auto decoder = ::CreateVideoDecoder(
      codec_type,
      width_,
      height_,
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

  if (!video_decoder_) {
    return;
  }

  HandleVideoSizeChange(
      frame->data(),
      frame->size());

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

void MediaSession::HandleVideoSizeChange(
    const uint8_t* frame,
    size_t size) {
  std::optional<VideoSize> video_size = ParseVideoSize(
      video_codec_,
      std::span(frame, frame + size));

  if (!video_size.has_value()) {
    return;
  }

  if (video_size->width == width_ &&
      video_size->height == height_) {
    return;
  }

  ALOGI("Video size has changed. %ux%u->%ux%u",
        width_,
        height_,
        video_size->width,
        video_size->height);

  // Resolution has changed. Reset decoder
  width_ = video_size->width;
  height_ = video_size->height;

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
