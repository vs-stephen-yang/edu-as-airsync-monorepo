#ifndef FLUTTER_MIRROR_PLUGIN_AUDIO_DECODER_H_
#define FLUTTER_MIRROR_PLUGIN_AUDIO_DECODER_H_

#include <memory>
#include <vector>

#include "media/media_format.h"

class AudioDecoder {
 public:
  virtual ~AudioDecoder() = default;

  virtual bool Init() = 0;

  virtual bool Start() = 0;
  virtual void Stop() = 0;

  virtual void EnablePlayback(bool enable) = 0;

  virtual bool Decode(
      const uint8_t* frame,
      size_t frameSize,
      int64_t presentationTimeUs) = 0;

  virtual bool Decode(
      std::shared_ptr<std::vector<uint8_t>> frame,
      int64_t presentationTimeUs) = 0;
};
typedef std::unique_ptr<AudioDecoder> AudioDecoderPtr;

AudioDecoderPtr CreateAudioDecoder(
    AudioCodecType codec_type,
    AudioFormat format);

AudioDecoderPtr CreateOpusDecoder(
    unsigned int sample_rate,
    unsigned int channel_count);

AudioDecoderPtr CreateAacDecoder(
    unsigned int sample_rate,
    unsigned int channel_count,
    bool has_adts);

#endif  // FLUTTER_MIRROR_PLUGIN_AUDIO_DECODER_H_
