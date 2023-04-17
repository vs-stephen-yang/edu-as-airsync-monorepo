#include "googlecast/googlecast_mirror_session.h"
#include <assert.h>
#include <optional>
#include "media/audio_decoder.h"
#include "util/log.h"

using namespace openscreen;

static std::optional<VideoDecoder::CodecType> MapVideoCodec(cast::CastMirrorSession::VideoCodec codec) {
  switch (codec) {
    case cast::CastMirrorSession::VideoCodec::kH264:
      return VideoDecoder::CodecType::kH264;
    case cast::CastMirrorSession::VideoCodec::kVp8:
      return VideoDecoder::CodecType::kVp8;
    default:
      assert(0);
      return {};
  };
}

GooglecastMirrorSession::GooglecastMirrorSession(
    const std::string& mirror_id,
    MirrorListener& mirror_listener,
    jni::TextureRegistry& texture_registry,
    cast::CastMirrorSessionPtr session)
    : mirror_id_(mirror_id),
      mirror_listener_(mirror_listener),
      texture_registry_(texture_registry),
      session_(session) {
  assert(session);

  session_->RegisterListener(this);
}

bool GooglecastMirrorSession::StartMirror() {
  ALOGI("Starting a Googlecast mirror session");

  cast::CastMirrorSession::MediaFormats formats;
  session_->GetMediaFormats(formats);

  CreateVideoDecoder(formats);
  CreateAudioDecoder(formats);

  return true;
}

bool GooglecastMirrorSession::CreateVideoDecoder(
    const cast::CastMirrorSession::MediaFormats& formats) {
  assert(!video_decoder_);

  // create a surface texture
  texture_ = texture_registry_.CreateSurfaceTexture();
  assert(texture_.wnd);

  std::optional<VideoDecoder::CodecType> codec_type = MapVideoCodec(formats.video_codec);
  if (!codec_type) {
    return false;
  }

  // create a video decoder that renders to the surface texture
  auto decoder = ::CreateVideoDecoder(
      *codec_type,
      texture_.wnd,
      this);

  video_decoder_ = std::move(decoder);
  video_decoder_->Start();
  return true;
}

void GooglecastMirrorSession::StopMirror() {
  ALOGI("Stopping the googlecast mirror session");
  session_->Stop();

  if (video_decoder_) {
    video_decoder_->Stop();
  }
  if (audio_decoder_) {
    audio_decoder_->Stop();
  }

  texture_registry_.ReleaseSurfaceTexture(texture_);

  ALOGI("The googlecast mirror session has stopped");
}

bool GooglecastMirrorSession::CreateAudioDecoder(
    const cast::CastMirrorSession::MediaFormats& formats) {
  switch (formats.audio_codec) {
    case cast::CastMirrorSession::AudioCodec::kAac:
      audio_decoder_ = CreateAacDecoder(
          formats.sample_rate,
          formats.channel_count,
          true);  // has_adts
      break;

    case cast::CastMirrorSession::AudioCodec::kOpus:
      audio_decoder_ = CreateOpusDecoder(
          formats.sample_rate,
          formats.channel_count);
      break;
    default:
      assert(0);
      return false;
  }

  audio_decoder_->Init();
  audio_decoder_->Start();

  return true;
}

void GooglecastMirrorSession::OnVideoFormatChanged(
    int width,
    int height) {
  mirror_listener_.OnMirrorVideoResize(
      this,
      width,
      height);
}

void GooglecastMirrorSession::OnMirrorEvent(
    cast::CastMirrorSession::Listener::Event ev) {
  switch (ev) {
    case cast::CastMirrorSession::Listener::Event::kMirrorStop:
      mirror_listener_.OnMirrorStop(this);
      break;
    default:
      break;
  }
}

void GooglecastMirrorSession::OnAudioFrame(
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

void GooglecastMirrorSession::OnVideoFrame(
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

std::string GooglecastMirrorSession::GetMirrorId() {
  return mirror_id_;
}

SurfaceTexture GooglecastMirrorSession::GetTexture() {
  return texture_;
}
std::string GooglecastMirrorSession::GetSourceDisplayName() {
  return "";
}

MirrorType GooglecastMirrorSession::GetMirrorType() {
  return MirrorType::Googlecast;
}
