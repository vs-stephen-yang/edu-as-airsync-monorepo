#include "media/audio_decoder_ndk.h"
#include <assert.h>
#include <algorithm>
#include "util/log.h"

static const std::string kMimeAac = "audio/mp4a-latm";
static const std::string kMimeOpus = "audio/opus";

static const int64_t kDequeueInputTimeoutUs = 10 * 1000;    // in microseconds
static const int64_t kDequeueOutputTimeoutUs = 100 * 1000;  // in microseconds

// https://wiki.multimedia.cx/index.php/MPEG-4_Audio
static const unsigned int kAacLc = 2;  // AAC LC (Low Complexity)

// keep these values in sync with AudioFormat.java
// https://developer.android.com/reference/android/media/AudioFormat#ENCODING_PCM_16BIT
#define ENCODING_PCM_16BIT 2
#define ENCODING_PCM_8BIT 3

static void MakeOpusCsd(
    AMediaFormat* fmt,
    unsigned int sample_rate,
    unsigned int channel_count) {
  assert(fmt);
  assert(sample_rate > 0);
  assert(channel_count > 0);

  // Opus Identification Header
  // https://www.rfc-editor.org/rfc/rfc7845#section-5.1
  uint8_t csd0[] = {
      // O,p,u,s
      0x4f, 0x70, 0x75, 0x73,
      // H,e,a,d
      0x48, 0x65, 0x61, 0x64,
      // Version
      0x01,
      // Channel Count
      (uint8_t)channel_count,
      // Pre skip
      0x00, 0x00,
      // Input Sample Rate (Hz), little endian
      0x28, 0xa0, 0x00, 0x00,
      // Output Gain (Q7.8 in dB)
      0x00, 0x00,
      // Mapping Family
      0x00};

  uint8_t csd1[8] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
  uint8_t csd2[8] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

  uint32_t& sample_rate_in_csd0 = *((uint32_t*)&csd0[12]);
  sample_rate_in_csd0 = sample_rate;

  AMediaFormat_setBuffer(fmt, "csd-0", csd0, sizeof(csd0));
  AMediaFormat_setBuffer(fmt, "csd-1", csd1, sizeof(csd1));
  AMediaFormat_setBuffer(fmt, "csd-2", csd2, sizeof(csd2));
}

static bool MakeAacCsd(
    AMediaFormat* fmt,
    unsigned int profile,
    unsigned int sampling_freq,
    unsigned int channel_configuration) {
  assert(fmt);

  static const int32_t kSamplingFreq[] = {
      96000, 88200, 64000, 48000, 44100, 32000, 24000, 22050,
      16000, 12000, 11025, 8000};

  auto freq_itr = std::find(
      std::begin(kSamplingFreq),
      std::end(kSamplingFreq),
      sampling_freq);

  if (freq_itr == std::end(kSamplingFreq)) {
    return false;
  }

  unsigned int sampling_freq_index = std::distance(
      std::begin(kSamplingFreq),
      freq_itr);

  uint8_t csd[2];
  csd[0] = (profile << 3) | (sampling_freq_index >> 1);
  csd[1] = ((sampling_freq_index << 7) & 0x80) | (channel_configuration << 3);

  AMediaFormat_setBuffer(fmt, "csd-0", csd, sizeof(csd));

  return true;
}

AudioDecoderNdk::AudioDecoderNdk(
    AMediaCodecPtr codec,
    AMediaFormatPtr format)
    : codec_(std::move(codec)),
      format_(std::move(format)),
      running_(false),
      enable_playback_(false) {
  assert(codec_);
  assert(format_);
}

AudioDecoderNdk::~AudioDecoderNdk() {
  ALOGV("~AudioDecoderNdk()");
}

bool AudioDecoderNdk::Init() {
  assert(codec_);
  assert(format_);

  media_status_t status = AMediaCodec_configure(
      codec_.get(),
      format_.get(),
      nullptr,
      nullptr,
      0);

  if (status != AMEDIA_OK) {
    ALOGE("AMediaCodec_configure() failed. %d", (int)status);
    return false;
  }

  return true;
}

bool AudioDecoderNdk::Start() {
  assert(codec_);
  assert(format_);

  media_status_t status = AMediaCodec_start(codec_.get());

  if (status != AMEDIA_OK) {
    ALOGE("AMediaCodec_start() failed. %d", (int)status);
    return false;
  }

  running_ = true;
  thread_ = std::make_unique<std::thread>([this]() {
    ALOGD("Audio decoder thread starts");

    while (running_) {
      DeliverDecodedFrame();
    }

    ALOGD("Audio decoder thread is exiting");
  });

  return true;
}
void AudioDecoderNdk::EnablePlayback(bool enable) {
  enable_playback_ = enable;
}

void AudioDecoderNdk::Stop() {
  running_ = false;

  if (thread_) {
    ALOGD("Stopping audio decoder thread");
    thread_->join();
  }

  if (codec_) {
    AMediaCodec_stop(codec_.get());
  }

  if (audio_sink_) {
    audio_sink_->Stop();
  }
}

bool AudioDecoderNdk::Decode(std::shared_ptr<std::vector<uint8_t>> frame, int64_t presentation_time_us) {
  return Decode(frame->data(), frame->size(), presentation_time_us);
}

bool AudioDecoderNdk::Decode(
    const uint8_t* frame,
    size_t frame_size,
    int64_t presentation_time_us) {
  ssize_t buf_idx = AMediaCodec_dequeueInputBuffer(
      codec_.get(),
      kDequeueInputTimeoutUs);

  if (buf_idx < 0) {
    return false;
  }

  size_t buf_size = 0;
  uint8_t* buf = AMediaCodec_getInputBuffer(codec_.get(), buf_idx, &buf_size);
  if (!buf) {
    ALOGE("cannot get input buffer. buf_idx:%d", (int)buf_idx);
    return false;
  }

  memcpy(buf, frame, frame_size);
  uint32_t flags = 0;

  // Do not submit multiple input buffers with the same timestamp (unless it is codec-specific data marked as such).
  media_status_t status = AMediaCodec_queueInputBuffer(codec_.get(), buf_idx, 0, frame_size, presentation_time_us, flags);
  if (status != AMEDIA_OK) {
    ALOGE("AMediaCodec_queueInputBuffer() fails. %d", (int)status);
  }

  return true;
}

bool AudioDecoderNdk::DeliverDecodedFrame() {
  AMediaCodecBufferInfo info;

  ssize_t status = AMediaCodec_dequeueOutputBuffer(
      codec_.get(),
      &info,
      kDequeueOutputTimeoutUs);

  if (status >= 0) {
    int buf_idx = status;
    size_t buf_size = 0;
    uint8_t* buf = AMediaCodec_getOutputBuffer(codec_.get(), buf_idx, &buf_size);

    if (info.size > 0 &&
        buf) {
      if (audio_sink_ &&
          enable_playback_) {
        audio_sink_->Write(
            buf + info.offset,  // offset: The start-offset of the data in the buffer
            info.size);         // The amount of data (in bytes) in the buffer
      }
    }

    AMediaCodec_releaseOutputBuffer(codec_.get(), buf_idx, false);

    return true;
  } else if (status == AMEDIACODEC_INFO_OUTPUT_BUFFERS_CHANGED) {
  } else if (status == AMEDIACODEC_INFO_OUTPUT_FORMAT_CHANGED) {
    AMediaFormat* format = AMediaCodec_getOutputFormat(codec_.get());
    int32_t sample_rate, channel_count;

    AMediaFormat_getInt32(format, AMEDIAFORMAT_KEY_SAMPLE_RATE, &sample_rate);
    AMediaFormat_getInt32(format, AMEDIAFORMAT_KEY_CHANNEL_COUNT, &channel_count);

    // TODO: handle PCM format other than 16 bit per sample
    // int32_t sample_format = ENCODING_PCM_16BIT;
    // AMediaFormat_getInt32(format, AMEDIAFORMAT_KEY_PCM_ENCODING, &sample_format);

    ALOGI("Audio format changed. Sample Rate:%d Channels:%d",
          sample_rate, channel_count);

    if (!StartAudioSink(sample_rate, channel_count)) {
      ALOGE("Failed to start audio sink");
    }
  } else if (status == AMEDIACODEC_INFO_TRY_AGAIN_LATER) {
  } else {
    // unexpected
  }

  return false;
}

bool AudioDecoderNdk::StartAudioSink(
    unsigned int sample_rate,
    unsigned int channel_count) {
  assert(sample_rate > 0);
  assert(channel_count > 0);

  auto audio_sink = std::make_unique<AudioSinkOboe>();

  if (!audio_sink->Init(sample_rate, channel_count)) {
    return false;
  }

  if (!audio_sink->Start()) {
    return false;
  }

  audio_sink_ = std::move(audio_sink);
  return true;
}

AMediaFormatPtr CreateAudioFormat(
    const std::string& mime,
    unsigned int sample_rate,
    unsigned int channel_count) {
  assert(sample_rate > 0);
  assert(channel_count > 0);

  AMediaFormatPtr fmt(AMediaFormat_new());

  AMediaFormat_setString(fmt.get(), AMEDIAFORMAT_KEY_MIME, mime.c_str());
  AMediaFormat_setInt32(fmt.get(), AMEDIAFORMAT_KEY_SAMPLE_RATE, sample_rate);
  AMediaFormat_setInt32(fmt.get(), AMEDIAFORMAT_KEY_CHANNEL_COUNT, channel_count);

  return fmt;
}

AudioDecoderPtr CreateAudioDecoder(
    AudioCodecType codec_type,
    AudioFormat format) {
  switch (codec_type) {
    case AudioCodecType::kAac:
      return CreateAacDecoder(
          format.sample_rate,
          format.channel_count,
          format.has_adts);

    case AudioCodecType::kOpus:
      return CreateOpusDecoder(
          format.sample_rate,
          format.channel_count);

    default:
      assert(0);
      return {};
  }
}

AudioDecoderPtr CreateOpusDecoder(
    unsigned int sample_rate,
    unsigned int channel_count) {
  assert(sample_rate > 0);
  assert(channel_count > 0);

  const std::string& mime = kMimeOpus;

  AMediaCodecPtr codec(
      AMediaCodec_createDecoderByType(mime.c_str()));

  AMediaFormatPtr fmt = CreateAudioFormat(
      mime,
      sample_rate,
      channel_count);

  MakeOpusCsd(
      fmt.get(),
      sample_rate,
      channel_count);

  return std::make_unique<AudioDecoderNdk>(
      std::move(codec),
      std::move(fmt));
}

AudioDecoderPtr CreateAacDecoder(
    unsigned int sample_rate,
    unsigned int channel_count,
    bool has_adts) {
  assert(sample_rate > 0);
  assert(channel_count > 0);

  const std::string& mime = kMimeAac;

  AMediaCodecPtr codec(
      AMediaCodec_createDecoderByType(mime.c_str()));

  AMediaFormatPtr fmt = CreateAudioFormat(
      mime,
      sample_rate,
      channel_count);

  MakeAacCsd(
      fmt.get(),
      kAacLc,  // AAC LC (Low Complexity)
      sample_rate,
      channel_count);

  AMediaFormat_setInt32(
      fmt.get(),
      AMEDIAFORMAT_KEY_IS_ADTS,
      has_adts ? 1 : 0);

  return std::make_unique<AudioDecoderNdk>(
      std::move(codec),
      std::move(fmt));
}
