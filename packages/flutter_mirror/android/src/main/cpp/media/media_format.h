#ifndef FLUTTER_MIRROR_PLUGIN_MEDIA_FORMAT_H_
#define FLUTTER_MIRROR_PLUGIN_MEDIA_FORMAT_H_

enum class VideoCodecType {
  kH264,
  kVp8,
};

enum class AudioCodecType {
  kAac,
  kOpus,
};

struct AudioFormat {
  unsigned int sample_rate = 0;
  unsigned int channel_count = 0;

  // AAC
  bool has_adts = false;
};

#endif  // FLUTTER_MIRROR_PLUGIN_MEDIA_FORMAT_H_
