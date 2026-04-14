#include "googlecast/googlecast_mirror_session.h"
#include <assert.h>
#include <optional>
#include "cast/media_formats.h"
#include "util/log.h"

using namespace openscreen;

static std::optional<VideoCodecType> MapVideoCodec(cast::MediaFormats::VideoCodec codec) {
  switch (codec) {
    case cast::MediaFormats::VideoCodec::kH264:
      return VideoCodecType::kH264;
    case cast::MediaFormats::VideoCodec::kVp8:
      return VideoCodecType::kVp8;
    default:
      assert(0);
      return {};
  };
}

static std::optional<AudioCodecType> MapAudioCodec(
    cast::MediaFormats::AudioCodec codec) {
  switch (codec) {
    case cast::MediaFormats::AudioCodec::kAac:
      return AudioCodecType::kAac;
    case cast::MediaFormats::AudioCodec::kOpus:
      return AudioCodecType::kOpus;
    default:
      assert(0);
      return {};
  };
}

GooglecastMirrorSession::GooglecastMirrorSession(
    const std::string& mirror_id,
    const std::string& device_name,
    MirrorListener& mirror_listener,
    cast::CastMirrorSessionPtr session,
    const openscreen::cast::MediaFormats& formats)
    : mirror_id_(mirror_id),
      device_name_(device_name),
      mirror_listener_(mirror_listener),
      session_(session),
      formats_(formats) {
  assert(session);
  ALOGV("GooglecastMirrorSession()");

  session_->RegisterListener(this);
}

GooglecastMirrorSession::~GooglecastMirrorSession() {
  ALOGV("~GooglecastMirrorSession()");
}

bool GooglecastMirrorSession::StartMirror(
    MediaSessionPtr media_session) {
  ALOGD("GooglecastMirrorSession::StartMirror()");

  std::optional<VideoCodecType> video_codec = MapVideoCodec(formats_.video_codec);
  std::optional<AudioCodecType> audio_codec = MapAudioCodec(formats_.audio_codec);

  if (!video_codec ||
      !audio_codec) {
    return false;
  }
  AudioFormat audio_format;
  audio_format.sample_rate = formats_.sample_rate;
  audio_format.channel_count = formats_.channel_count;
  audio_format.has_adts = true;

  media_session_ = std::move(media_session);

  return media_session_->Start(
      this,
      *video_codec,
      *audio_codec,
      audio_format);
}

void GooglecastMirrorSession::EnableAudio(bool enable) {
  if (media_session_) {
    media_session_->EnableAudio(enable);
  }
}

void GooglecastMirrorSession::StopMirror() {
  ALOGD("GooglecastMirrorSession::StopMirror()");

  // Note that StopMirror() is asynchronous.
  // StopMirror() will stop the mirror and trigger OnMirrorStop callback
  session_->StopMirror();
}

void GooglecastMirrorSession::OnMirrorStop() {
  ALOGD("GooglecastMirrorSession::OnMirrorStop()");
  Close();

  mirror_listener_.OnMirrorStop(this);
}

void GooglecastMirrorSession::Close() {
  if (media_session_) {
    media_session_->Stop();
  }
}

void GooglecastMirrorSession::OnVideoFormatChanged(
    int width,
    int height) {
  mirror_listener_.OnMirrorVideoResize(
      this,
      width,
      height);
}

void GooglecastMirrorSession::OnVideoFrameRate(int fps) {
  mirror_listener_.OnMirrorVideoFrameRate(this, fps);
}

void GooglecastMirrorSession::OnMirrorEvent(
    cast::CastMirrorSession::Listener::Event ev) {
  switch (ev) {
    case cast::CastMirrorSession::Listener::Event::kMirrorStop:
      OnMirrorStop();
      break;
    default:
      break;
  }
}

void GooglecastMirrorSession::OnAudioFrame(
    std::shared_ptr<std::vector<uint8_t>> frame,
    uint64_t timestamp_us) {
  if (!media_session_) {
    return;
  }

  media_session_->OnAudioFrame(
      frame,
      timestamp_us);
}

void GooglecastMirrorSession::OnVideoFrame(
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

std::string GooglecastMirrorSession::GetMirrorId() {
  return mirror_id_;
}

SurfaceTexture GooglecastMirrorSession::GetTexture() {
  return media_session_->GetTexture();
}
std::string GooglecastMirrorSession::GetSourceDisplayName() {
  return device_name_;
}

std::string GooglecastMirrorSession::GetSourceDeviceModel() {
  return "";
}

MirrorType GooglecastMirrorSession::GetMirrorType() {
  return MirrorType::Googlecast;
}
