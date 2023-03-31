#ifndef FLUTTER_MIRROR_PLUGIN_AUDIO_DECODER_NDK_H_
#define FLUTTER_MIRROR_PLUGIN_AUDIO_DECODER_NDK_H_

#include <media/NdkMediaCodec.h>
#include <media/NdkMediaError.h>

#include <memory>
#include <thread>
#include <vector>

#include "media/audio_decoder.h"
#include "media/audio_sink_oboe.h"

class AudioDecoderNdk
    : public AudioDecoder {
 public:
  AudioDecoderNdk(
      AMediaCodec* codec,
      AMediaFormat* format);

  virtual bool Init() override;
  virtual bool Start() override;
  virtual void Stop() override;

  bool Decode(
      const uint8_t* frame,
      size_t frame_size,
      int64_t presentation_time_us) override;

  virtual bool Decode(
      std::shared_ptr<std::vector<uint8_t>> frame,
      int64_t presentationTimeUs) override;

 private:
  bool DeliverDecodedFrame();

  AMediaCodec* codec_ = nullptr;
  AMediaFormat* format_ = nullptr;

  std::unique_ptr<std::thread> thread_ = nullptr;
  volatile bool running_ = false;

  std::unique_ptr<AudioSinkOboe> audio_sink_;
};

#endif  // FLUTTER_MIRROR_PLUGIN_AUDIO_DECODER_NDK_H_
