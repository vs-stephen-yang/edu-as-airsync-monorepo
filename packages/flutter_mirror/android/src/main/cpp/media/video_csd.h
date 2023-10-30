#ifndef FLUTTER_MIRROR_PLUGIN_VIDEO_CSD_H_
#define FLUTTER_MIRROR_PLUGIN_VIDEO_CSD_H_

#include <vector>

class VideoCsd {
 public:
  VideoCsd(
      unsigned int width,
      unsigned int height)
      : width(width),
        height(height) {
  }

  unsigned int width = 0;
  unsigned int height = 0;
};

#endif  // FLUTTER_MIRROR_PLUGIN_VIDEO_CSD_H_
