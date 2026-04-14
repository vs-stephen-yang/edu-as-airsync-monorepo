#ifndef FLUTTER_MIRROR_PLUGIN_AUDIO_DECODER_NDK_H_
#define FLUTTER_MIRROR_PLUGIN_AUDIO_DECODER_NDK_H_

#include <media/NdkMediaCodec.h>
#include <media/NdkMediaError.h>

#include <atomic>
#include <memory>
#include <thread>
#include <vector>

#include "media/audio_decoder.h"
#include "media/audio_sink_oboe.h"
#include "media/ndk_media_util.h"

class AudioDecoderNdk
    : public AudioDecoder {
 public:
  AudioDecoderNdk(
      AMediaCodecPtr codec,
      AMediaFormatPtr format);

  ~AudioDecoderNdk() override;

  virtual bool Init() override;
  virtual bool Start() override;
  virtual void Stop() override;

  virtual void EnablePlayback(bool enable) override;

  bool Decode(
      const uint8_t* frame,
      size_t frame_size,
      int64_t presentation_time_us) override;

  virtual bool Decode(
      std::shared_ptr<std::vector<uint8_t>> frame,
      int64_t presentationTimeUs) override;

 private:
  bool DeliverDecodedFrame();
  bool StartAudioSink(unsigned int sample_rate, unsigned int channel_count);

  AMediaCodecPtr codec_;
  AMediaFormatPtr format_;

  std::unique_ptr<std::thread> thread_;
  std::atomic_bool running_;

  std::unique_ptr<AudioSinkOboe> audio_sink_;

  std::atomic<bool> enable_playback_;
};

#endif  // FLUTTER_MIRROR_PLUGIN_AUDIO_DECODER_NDK_H_
