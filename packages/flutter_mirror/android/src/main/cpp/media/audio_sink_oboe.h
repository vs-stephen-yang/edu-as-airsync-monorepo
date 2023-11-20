#ifndef FLUTTER_MIRROR_PLUGIN_AUDIO_SINK_OBOE_H_
#define FLUTTER_MIRROR_PLUGIN_AUDIO_SINK_OBOE_H_

#include <oboe/Oboe.h>

class AudioSinkOboe {
 public:
  ~AudioSinkOboe();

  bool Init(
      unsigned int sample_rate,
      unsigned int channel_count);

  bool Start();
  void Stop();

  bool Write(const uint8_t* buf, size_t size);

 private:
  bool HandleUnderrun();

  int32_t lastUnderrun_ = 0;
  std::shared_ptr<oboe::AudioStream> stream_;
};

#endif  // FLUTTER_MIRROR_PLUGIN_AUDIO_SINK_OBOE_H_
