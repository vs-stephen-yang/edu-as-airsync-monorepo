#include "media/audio_sink_oboe.h"
#include <assert.h>
#include "util/log.h"

const int32_t kUnderrunThreshold = 10;

AudioSinkOboe::~AudioSinkOboe() {
  ALOGV("~AudioSinkOboe()");
}

bool AudioSinkOboe::Init(
    unsigned int sample_rate,
    unsigned int channel_count) {
  oboe::AudioStreamBuilder builder;

  builder.setChannelCount(channel_count)
      ->setPerformanceMode(oboe::PerformanceMode::LowLatency)
      ->setSampleRate(sample_rate)
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
  int32_t requested_frames = stream_->getFramesPerBurst() * 10;

  // This can be used to adjust the latency of the buffer by changing the threshold where blocking will occur
  result = stream_->setBufferSizeInFrames(requested_frames);
  if (result != oboe::Result::OK) {
    ALOGE("AudioStream::setBufferSizeInFrames() failed. %s", oboe::convertToText(result));
    return false;
  }

  return true;
}

bool AudioSinkOboe::Start() {
  assert(stream_);

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
  return true;
}

void AudioSinkOboe::Stop() {
  if (stream_) {
    stream_->close();
  }
}

bool AudioSinkOboe::HandleUnderrun() {
  if (!stream_->isXRunCountSupported()) {
    return true;
  }

  oboe::ResultWithValue<int32_t> underrun = stream_->getXRunCount();
  if (!underrun) {
    return true;
  }

  int32_t deltaUnderrun = underrun.value() - lastUnderrun_;
  if (deltaUnderrun < kUnderrunThreshold) {
    return true;
  }
  lastUnderrun_ = underrun.value();

  ALOGW("Restarting audio playback due to underrun %d", deltaUnderrun);

  // restart
  oboe::Result result = stream_->stop();
  if (result != oboe::Result::OK) {
    ALOGE("Failed to stop audio stream. %s", oboe::convertToText(result));
    return false;
  }

  result = stream_->start();
  if (result != oboe::Result::OK) {
    ALOGE("Failed to start audio stream. %s", oboe::convertToText(result));
    return false;
  }
  return true;
}

bool AudioSinkOboe::Write(const uint8_t* buf, size_t size) {
  assert(stream_);

  if (!HandleUnderrun()) {
    return false;
  }

  oboe::ResultWithValue<int32_t> result = stream_->write(
      buf,
      size / stream_->getBytesPerFrame(),
      1000 * oboe::kNanosPerMillisecond);

  if (!result) {
    ALOGE("AudioStream::write() failed. %s", oboe::convertToText(result.error()));
    return false;
  }

  return true;
}
