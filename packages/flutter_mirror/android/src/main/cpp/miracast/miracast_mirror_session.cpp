#include "miracast/miracast_mirror_session.h"
#include <assert.h>
#include "media/audio_decoder.h"
#include "media/video_decoder_ndk.h"
#include "miracast/miracast_receiver.h"
#include "mpeg2ts/Utils.h"
#include "util/log.h"

using namespace std;

MiracastMirrorSession::MiracastMirrorSession(
    int id,
    jni::TextureRegistry& texture_registry,
    MiracastReceiver& receiver)
    : id_(id),
      texture_registry_(texture_registry),
      receiver_(receiver) {
}

int MiracastMirrorSession::Id() const {
  return id_;
}

SurfaceTexture MiracastMirrorSession::GetTexture() const {
  return texture_;
}

bool MiracastMirrorSession::StartMirror() {
  ALOGI("Starting the mirror session");

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

  // create a TS parser
  ts_parser_ = std::make_unique<ATSParser>(this);

  return true;
}

void MiracastMirrorSession::StopMirror() {
  ALOGI("Stopping the mirror session");

  if (video_decoder_) {
    video_decoder_->Stop();
  }
  if (audio_decoder_) {
    audio_decoder_->Stop();
  }

  texture_registry_.ReleaseSurfaceTexture(texture_);

  ALOGI("The mirror session #%d has stopped", id_);
}

void MiracastMirrorSession::UpdateAudioFormat(
    const std::string& codecName,
    int sampleRate,
    int channelCount) {
  codec_name_ = codecName;
  sample_rate_ = sampleRate;
  channel_count_ = channelCount;
}

void MiracastMirrorSession::CreateAudioDecoder() {
  if (audio_decoder_) {
    audio_decoder_->Stop();
  }

  if (codec_name_ != "AAC") {
    ALOGE("Unsupported codec %s", codec_name_.c_str());
    return;
  }

  audio_decoder_ = CreateAacDecoder(
      sample_rate_,
      channel_count_,
      true);

  audio_decoder_->Init();
  audio_decoder_->Start();
}

void MiracastMirrorSession::OnVideoFormatChanged(
    int width,
    int height) {
  receiver_.OnVideoFormatChanged(
      *this,
      width,
      height);
}

void MiracastMirrorSession::OnAudioFrame(
    const uint8_t* frame,
    size_t frameSize,
    uint64_t timestamp_us) {
  if (!audio_decoder_) {
    CreateAudioDecoder();
    return;
  }
  // decode audio frame
  audio_decoder_->Decode(
      frame,
      frameSize,
      timestamp_us);
}

void MiracastMirrorSession::OnAudioFrame(
    std::shared_ptr<std::vector<uint8_t>> frame,
    uint64_t timestamp_us) {
  OnAudioFrame(frame->data(),
               frame->size(),
               timestamp_us);
}

void MiracastMirrorSession::OnVideoFrame(
    bool key_frame,
    const uint8_t* frame,
    size_t frameSize,
    uint64_t timestamp_us) {
  if (!video_decoder_) {
    return;
  }

  // decode video frame
  video_decoder_->Decode(
      frame,
      frameSize,
      timestamp_us);
}

void MiracastMirrorSession::OnVideoFrame(
    bool key_frame,
    std::shared_ptr<std::vector<uint8_t>> frame,
    uint64_t timestamp_us) {
  OnVideoFrame(key_frame,
               frame->data(),
               frame->size(),
               timestamp_us);
}

void MiracastMirrorSession::OnPacketLoss() {
  receiver_.SendIdrRequest(id_);
}

void MiracastMirrorSession::processRTPData(const uint8_t* data, int length) {
  size_t size = length;
  if (size < 12) {
    // Too short to be a valid RTP header.
    ALOGE("Size:%d Too short to be a valid RTP header.", size);
    return;
  }

  if ((data[0] >> 6) != 2) {
    // Unsupported version.
    ALOGE("Unsupported version.");
    return;
  }

  if (data[0] & 0x20) {
    // Padding present.

    size_t paddingLength = data[size - 1];

    if (paddingLength + 12 > size) {
      // If we removed this much padding we'd end up with something
      // that's too short to be a valid RTP header.
      ALOGE("Invalid header. Size:%d PaddingLength:%d", size, paddingLength);
      return;
    }

    size -= paddingLength;
  }

  int numCSRCs = data[0] & 0x0f;

  size_t payloadOffset = 12 + 4 * numCSRCs;

  if (size < payloadOffset) {
    // Not enough data to fit the basic header and all the CSRC entries.
    ALOGE("Invalid header. Not enough data to fit the basic header and all the CSRC entries.");
    return;
  }

  if (data[0] & 0x10) {
    // Header eXtension present.

    if (size < payloadOffset + 4) {
      // Not enough data to fit the basic header, all CSRC entries
      // and the first 4 bytes of the extension header.
      ALOGE("Invalid header. Not enough data to fit basic header, CSRC entries, and extension header.");
      return;
    }

    const uint8_t* extensionData = &data[payloadOffset];
    size_t extensionLength = 4 * (extensionData[2] << 8 | extensionData[3]);

    if (size < payloadOffset + 4 + extensionLength) {
      ALOGE("Invalid header. Not enough data to fit extensionLength.");
      return;
    }

    payloadOffset += 4 + extensionLength;
  }

  uint32_t srcId = U32_AT(&data[8]);
  uint32_t rtpTime = U32_AT(&data[4]);
  uint16_t seqNo = U16_AT(&data[2]);

  // ALOGV("%lld, offset, 0x%08llx, size,%d, RTP siseqNo, %d, SSRC, 0x%08x, rtpTime, %lld",
  //       num_packets_received_, packets_offset_, length, seqNo, srcId, rtpTime);
  packets_offset_ += length;
  ++num_packets_received_;

  for (; payloadOffset + kTSPacketSize <= size; payloadOffset += kTSPacketSize) {
    ts_parser_->feedTSPacket((void*)(data + payloadOffset), kTSPacketSize);
  }
};
