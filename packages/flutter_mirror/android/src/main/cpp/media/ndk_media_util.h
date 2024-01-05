#ifndef FLUTTER_MIRROR_PLUGIN_NDK_MEDIA_UTIL_H_
#define FLUTTER_MIRROR_PLUGIN_NDK_MEDIA_UTIL_H_

#include <memory>

#include <media/NdkMediaCodec.h>

#include "video_decoder_wrapper.h"

struct AMediaFormat_Deleter {
  void operator()(AMediaFormat* fmt) {
    AMediaFormat_delete(fmt);
  }
};

using AMediaFormatPtr = std::unique_ptr<AMediaFormat, AMediaFormat_Deleter>;

struct AMediaCodec_Deleter {
  void operator()(AMediaCodec* codec) {
    VideoDecoderWrapper::GetInstance().AMediaCodec_delete(codec);
  }
};

using AMediaCodecPtr = std::unique_ptr<AMediaCodec, AMediaCodec_Deleter>;

#endif  // FLUTTER_MIRROR_PLUGIN_NDK_MEDIA_UTIL_H_
