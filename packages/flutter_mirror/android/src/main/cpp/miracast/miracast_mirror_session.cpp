#include "miracast/miracast_mirror_session.h"
#include <assert.h>
#include "media/audio_decoder.h"
#include "miracast/miracast_receiver.h"
#include "mpeg2ts/Utils.h"
#include "util/log.h"

using namespace std;

MiracastMirrorSession::MiracastMirrorSession(
    const std::string& mirrorId,
    const std::string& device_name,
    MirrorListener& mirror_listener,
    MiracastReceiver& receiver)
    : mirror_id_(mirrorId),
      device_name_(device_name),
      receiver_(receiver),
      mirror_listener_(mirror_listener) {
}

MiracastMirrorSession::~MiracastMirrorSession() {
  ALOGV("~MiracastMirrorSession()");
}

SurfaceTexture MiracastMirrorSession::GetTexture() {
  return media_session_->GetTexture();
}

bool MiracastMirrorSession::StartMirror(
    MediaSessionPtr media_session) {
  ALOGD("MiracastMirrorSession::StartMirror()");

  media_session_ = std::move(media_session);

  AudioFormat audio_format;
  audio_format.sample_rate = 48000;
  audio_format.channel_count = 2;
  audio_format.has_adts = true;

  if (!media_session_->Start(
          this,
          VideoCodecType::kH264,
          AudioCodecType::kAac,
          audio_format)) {
    return false;
  }

  // create a TS parser
  ts_parser_ = std::make_unique<ATSParser>(this);

  return true;
}

void MiracastMirrorSession::StopMirror() {
  ALOGD("MiracastMirrorSession::StopMirror()");

  receiver_.StopMirror(mirror_id_);
}

void MiracastMirrorSession::UpdateAudioFormat(
    const std::string& codecName,
    int sampleRate,
    int channelCount) {
  codec_name_ = codecName;
  sample_rate_ = sampleRate;
  channel_count_ = channelCount;
}

void MiracastMirrorSession::OnVideoFormatChanged(
    int width,
    int height) {
  mirror_listener_.OnMirrorVideoResize(
      this,
      width,
      height);
}

void MiracastMirrorSession::OnVideoFrameRate(int fps) {
  mirror_listener_.OnMirrorVideoFrameRate(this, fps);
}

void MiracastMirrorSession::OnAudioFrame(
    const uint8_t* frame,
    size_t frameSize,
    uint64_t timestamp_us) {
  if (!media_session_) {
    return;
  }

  auto buf = std::make_shared<std::vector<uint8_t>>(
      frame,
      frame + frameSize);

  media_session_->OnAudioFrame(
      buf,
      timestamp_us);
}

void MiracastMirrorSession::OnVideoFrame(
    bool key_frame,
    const uint8_t* frame,
    size_t frameSize,
    uint64_t timestamp_us) {
  if (!media_session_) {
    return;
  }

  auto buf = std::make_shared<std::vector<uint8_t>>(
      frame,
      frame + frameSize);

  media_session_->OnVideoFrame(
      key_frame,
      buf,
      timestamp_us);
}

void MiracastMirrorSession::OnPacketLoss() {
  receiver_.SendIdrRequest(mirror_id_);
}

void MiracastMirrorSession::processRTPData(const uint8_t* data, int length) {
  size_t size = length;
  if (size < 12) {
    // Too short to be a valid RTP header.
    ALOGE("Size:%u Too short to be a valid RTP header.", (unsigned int)size);
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
      ALOGE("Invalid header. Size:%u PaddingLength:%u", (unsigned int)size, (unsigned int)paddingLength);
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

std::string MiracastMirrorSession::GetMirrorId() {
  return mirror_id_;
}

std::string MiracastMirrorSession::GetSourceDisplayName() {
  return device_name_;
}
std::string MiracastMirrorSession::GetSourceDeviceModel() {
  return "";
}

MirrorType MiracastMirrorSession::GetMirrorType() {
  return MirrorType::Miracast;
}

void MiracastMirrorSession::EnableAudio(bool enable) {
  if (media_session_) {
    media_session_->EnableAudio(enable);
  }
}

void MiracastMirrorSession::OnMirrorStop() {
  ALOGD("MiracastMirrorSession::OnMirrorStop()");
  Close();

  mirror_listener_.OnMirrorStop(this);
}

void MiracastMirrorSession::Close() {
  if (media_session_) {
    media_session_->Stop();
  }
}
