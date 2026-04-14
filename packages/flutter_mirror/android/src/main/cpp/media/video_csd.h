#ifndef FLUTTER_MIRROR_PLUGIN_VIDEO_CSD_H_
#define FLUTTER_MIRROR_PLUGIN_VIDEO_CSD_H_

#include <vector>

class VideoCsd {
 public:
  VideoCsd(
      unsigned int width,
      unsigned int height,
      std::vector<uint8_t> csd0 = {},
      std::vector<uint8_t> csd1 = {})
      : width(width),
        height(height),
        csd0(csd0),
        csd1(csd1) {
  }

  unsigned int width = 0;
  unsigned int height = 0;

  std::vector<uint8_t> csd0;
  std::vector<uint8_t> csd1;
};

#endif  // FLUTTER_MIRROR_PLUGIN_VIDEO_CSD_H_
