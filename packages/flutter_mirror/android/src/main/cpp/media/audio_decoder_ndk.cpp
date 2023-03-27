#include "media/audio_decoder_ndk.h"
#include <assert.h>
#include "util/log.h"

static const std::string kMimeAac = "audio/mp4a-latm";
static const std::string kMimeOpus = "audio/opus";

static void MakeOpusCsd(
    AMediaFormat* fmt,
    unsigned int sample_rate,
    unsigned int channel_count) {
  assert(fmt);
  assert(sample_rate > 0);
  assert(channel_count > 0);

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
      // Input Sample Rate (Hz),
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
    unsigned profile,
    unsigned sampling_freq_index,
    unsigned channel_configuration) {
  assert(fmt);
  assert(sampling_freq_index < 12u);

  if (sampling_freq_index > 11u) {
    return false;
  }

  uint8_t csd[2];
  csd[0] = (profile << 3) | (sampling_freq_index >> 1);
  csd[1] = ((sampling_freq_index << 7) & 0x80) | (channel_configuration << 3);

  static const int32_t kSamplingFreq[] = {
      96000, 88200, 64000, 48000, 44100, 32000, 24000, 22050,
      16000, 12000, 11025, 8000};

  AMediaFormat_setBuffer(fmt, "csd-0", csd, sizeof(csd));

  return true;
}

AudioDecoderNdk::AudioDecoderNdk(
    AMediaCodec* codec,
    AMediaFormat* format)
    : codec_(codec),
      format_(format) {
  assert(codec);
  assert(format);
}

bool AudioDecoderNdk::Init() {
  assert(codec_);
  assert(format_);

  media_status_t status = AMediaCodec_configure(codec_, format_, nullptr, nullptr, 0);

  if (status != AMEDIA_OK) {
    ALOGE("AMediaCodec_configure() failed. %d", (int)status);
    return false;
  }

  oboe::AudioStreamBuilder builder;

  builder.setChannelCount(2)
      ->setPerformanceMode(oboe::PerformanceMode::LowLatency)
      ->setSampleRate(48000)
      ->setDirection(oboe::Direction::Output)
      //->setSharingMode(oboe::SharingMode::Exclusive)
      ->setFormat(oboe::AudioFormat::I16);

  oboe::Result result = builder.openStream(stream_);
  if (result != oboe::Result::OK) {
    ALOGE("AudioStream::openStream() failed. %s", oboe::convertToText(result));
    return false;
  }

  // requested number of frames that can be filled without blocking
  // TODO: This cannot be set higher than getBufferCapacity().
  int32_t requestedFrames = stream_->getFramesPerBurst() * 10;

  // This can be used to adjust the latency of the buffer by changing the threshold where blocking will occur
  result = stream_->setBufferSizeInFrames(requestedFrames);
  if (result != oboe::Result::OK) {
    ALOGE("AudioStream::setBufferSizeInFrames() failed. %s", oboe::convertToText(result));
    return false;
  }

  return true;
}

bool AudioDecoderNdk::Start() {
  assert(codec_);
  assert(format_);

  media_status_t status = AMediaCodec_start(codec_);

  if (status != AMEDIA_OK) {
    ALOGE("AMediaCodec_start() failed. %d", (int)status);
    return false;
  }

  oboe::Result result = stream_->start();
  if (result != oboe::Result::OK) {
    ALOGE("AudioStream::start() failed. %s", oboe::convertToText(result));
    return false;
  }

  oboe::AudioFormat fmt = stream_->getFormat();

  ALOGI("Audio DeviceId:%d Fmt:%s SampleRate:%d ChannelCount:%d BytesPerFrame:%d BytesPerSample:%d",
        stream_->getDeviceId(),
        oboe::convertToText(fmt),
        stream_->getSampleRate(),
        stream_->getChannelCount(),
        stream_->getBytesPerFrame(),
        stream_->getBytesPerSample());

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
void AudioDecoderNdk::Stop() {
  if (stream_) {
    stream_->close();
  }

  running_ = false;

  if (thread_) {
    ALOGD("Stopping audio decoder thread");
    thread_->join();
  }
}

bool AudioDecoderNdk::Decode(std::shared_ptr<std::vector<uint8_t>> frame, int64_t presentation_time_us) {
  int64_t timeout_us = 10 * 1000;

  ssize_t buf_idx = AMediaCodec_dequeueInputBuffer(codec_, timeout_us);

  if (buf_idx < 0) {
    return false;
  }

  size_t buf_size = 0;
  uint8_t* buf = AMediaCodec_getInputBuffer(codec_, buf_idx, &buf_size);

  memcpy(buf, frame->data(), frame->size());
  uint32_t flags = 0;

  // Do not submit multiple input buffers with the same timestamp (unless it is codec-specific data marked as such).
  media_status_t status = AMediaCodec_queueInputBuffer(codec_, buf_idx, 0, frame->size(), presentation_time_us, flags);
  if (status != AMEDIA_OK) {
    ALOGE("AMediaCodec_queueInputBuffer() fails. %d", (int)status);
  }

  return true;
}

bool AudioDecoderNdk::DeliverDecodedFrame() {
  AMediaCodecBufferInfo info;
  int64_t timeout_us = 100 * 1000;

  ssize_t status = AMediaCodec_dequeueOutputBuffer(codec_, &info, timeout_us);

  if (status >= 0) {
    int buf_idx = status;
    size_t buf_size = 0;
    uint8_t* buf = AMediaCodec_getOutputBuffer(codec_, buf_idx, &buf_size);

    oboe::ResultWithValue<int32_t> result = stream_->write(
        buf,
        4096 / stream_->getBytesPerFrame(),
        1000 * oboe::kNanosPerMillisecond);

    if (!result) {
      ALOGE("AudioStream::write() failed. %s", oboe::convertToText(result.error()));
    }

    AMediaCodec_releaseOutputBuffer(codec_, buf_idx, false);

    return true;
  } else if (status == AMEDIACODEC_INFO_OUTPUT_BUFFERS_CHANGED) {
  } else if (status == AMEDIACODEC_INFO_OUTPUT_FORMAT_CHANGED) {
    AMediaFormat* format = AMediaCodec_getOutputFormat(codec_);
    int32_t sample_rate, channel_count;

    AMediaFormat_getInt32(format, AMEDIAFORMAT_KEY_SAMPLE_RATE, &sample_rate);
    AMediaFormat_getInt32(format, AMEDIAFORMAT_KEY_CHANNEL_COUNT, &channel_count);

    ALOGI("Audio format changed. Sample Rate:%d Channels:%d",
          sample_rate, channel_count);
  } else if (status == AMEDIACODEC_INFO_TRY_AGAIN_LATER) {
  } else {
    // unexpected
  }

  return false;
}

AMediaFormat* CreateAudioFormat(
    const std::string& mime,
    unsigned int sample_rate,
    unsigned int channel_count) {
  assert(sample_rate > 0);
  assert(channel_count > 0);

  AMediaFormat* fmt = AMediaFormat_new();

  AMediaFormat_setString(fmt, AMEDIAFORMAT_KEY_MIME, mime.c_str());
  AMediaFormat_setInt32(fmt, AMEDIAFORMAT_KEY_SAMPLE_RATE, sample_rate);
  AMediaFormat_setInt32(fmt, AMEDIAFORMAT_KEY_CHANNEL_COUNT, channel_count);

  return fmt;
}

AudioDecoderPtr CreateOpusDecoder(
    unsigned int sample_rate,
    unsigned int channel_count) {
  assert(sample_rate > 0);
  assert(channel_count > 0);

  const std::string& mime = kMimeOpus;

  AMediaCodec* codec = AMediaCodec_createDecoderByType(mime.c_str());

  AMediaFormat* fmt = CreateAudioFormat(
      mime,
      sample_rate,
      channel_count);

  MakeOpusCsd(fmt, sample_rate, channel_count);

  return std::make_unique<AudioDecoderNdk>(codec, fmt);
}

AudioDecoderPtr CreateAacDecoder(
    unsigned int sample_rate,
    unsigned int channel_count,
    bool has_adts) {
  assert(sample_rate > 0);
  assert(channel_count > 0);

  const std::string& mime = kMimeAac;

  AMediaCodec* codec = AMediaCodec_createDecoderByType(mime.c_str());

  AMediaFormat* fmt = CreateAudioFormat(
      mime,
      sample_rate,
      channel_count);

  // https://wiki.multimedia.cx/index.php/MPEG-4_Audio
  MakeAacCsd(fmt, 2, 3, 2);

  AMediaFormat_setInt32(
      fmt,
      AMEDIAFORMAT_KEY_IS_ADTS,
      has_adts ? 1 : 0);

  return std::make_unique<AudioDecoderNdk>(codec, fmt);
}
