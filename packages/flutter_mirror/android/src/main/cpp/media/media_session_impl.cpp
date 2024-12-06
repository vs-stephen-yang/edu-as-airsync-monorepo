#include "media/media_session_impl.h"
#include <assert.h>
#include "media/video_csd_util.h"
#include "util/log.h"

MediaSessionImpl::MediaSessionImpl(
    jni::TextureRegistry& texture_registry,
    const std::map<std::string, int>& additional_codec_params)
    : texture_registry_(texture_registry),
      additional_codec_params_(additional_codec_params) {
}

MediaSessionImpl::~MediaSessionImpl() {
  ALOGV("~MediaSessionImpl()");
}

bool MediaSessionImpl::Start(
    MediaSessionImpl::Listener* listener,
    VideoCodecType video_codec,
    AudioCodecType audio_codec,
    AudioFormat audio_format) {
  assert(listener);
  ALOGD("MediaSessionImpl::Start()");

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

SurfaceTexture MediaSessionImpl::GetTexture() {
  return texture_;
}

void MediaSessionImpl::Stop() {
  ALOGD("MediaSessionImpl::Stop()");

  if (video_decoder_) {
    video_decoder_->Stop();
  }
  texture_registry_.ReleaseSurfaceTexture(texture_);

  if (audio_decoder_) {
    audio_decoder_->Stop();
  }

  ALOGD("MediaSessionImpl::Stop() done");
}

bool MediaSessionImpl::InitVideoDecoder(
    VideoCodecType codec_type,
    bool use_software_decoder) {
  ALOGD("MediaSessionImpl::InitVideoDecoder()");
  assert(csd_);

  // create a video decoder that renders to the surface texture
  auto decoder = ::CreateVideoDecoder(
      codec_type,
      use_software_decoder,
      *csd_,
      additional_codec_params_,
      texture_.wnd,
      this);

  if (!decoder) {
    ALOGE("Failed to create video decoder");
    return false;
  }

  if (!decoder->Start()) {
    ALOGE("Failed to start video decoder");
    decoder->Stop();
    return false;
  }

  video_decoder_ = std::move(decoder);

  return true;
}

bool MediaSessionImpl::CreateAudioDecoder(
    AudioCodecType audio_codec,
    AudioFormat audio_format) {
  ALOGD("MediaSessionImpl::CreateAudioDecoder()");

  audio_decoder_ = ::CreateAudioDecoder(
      audio_codec,
      audio_format);

  if (!audio_decoder_) {
    ALOGE("Failed to create audio decoder");
    return false;
  }

  return audio_decoder_->Init();
}

void MediaSessionImpl::OnVideoFormatChanged(
    int width,
    int height) {
  listener_->OnVideoFormatChanged(
      width,
      height);
}

void MediaSessionImpl::OnAudioFrame(
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

void MediaSessionImpl::OnVideoFrame(
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

void MediaSessionImpl::EnableAudio(bool enable) {
  ALOGD("MediaSessionImpl::EnableAudio(%d)", enable);

  if (audio_decoder_) {
    audio_decoder_->EnablePlayback(enable);
  }
}

void MediaSessionImpl::HandleVideoCsd(
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

bool MediaSessionImpl::InitHardwareVideoDecoder() {
  return InitVideoDecoder(video_codec_, false);
}

bool MediaSessionImpl::InitSoftwareVideoDecoder() {
  return InitVideoDecoder(video_codec_, true);
}

void MediaSessionImpl::ResetVideoDecoder() {
  ALOGI("Reset video decoder");

  if (video_decoder_) {
    video_decoder_->Stop();
  }
  video_decoder_.reset();

  // initialize hardware video decoder
  if (InitHardwareVideoDecoder()) {
    return;
  }
  ALOGW("Falling back to software decoding");

  // initialize software video decoder
  if (InitSoftwareVideoDecoder()) {
    return;
  }

  ALOGE("Failed to initialize video decoder");
  // TODO:
  return;
}
