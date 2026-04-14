#ifndef FLUTTER_MIRROR_PLUGIN_VIDEO_CSD_UTIL_H_
#define FLUTTER_MIRROR_PLUGIN_VIDEO_CSD_UTIL_H_

#include <optional>
#include <span>
#include "media/media_format.h"
#include "media/video_csd.h"

std::optional<VideoCsd> ParseH264VideoCsd(
    std::span<const uint8_t> frame);

std::optional<VideoCsd> ParseVideoCsd(
    VideoCodecType codec_type,
    std::span<const uint8_t> frame);
#endif  // FLUTTER_MIRROR_PLUGIN_VIDEO_CSD_UTIL_H_
