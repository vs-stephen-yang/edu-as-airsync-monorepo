#ifndef FLUTTER_MIRROR_PLUGIN_VIDEO_DECODER_H_
#define FLUTTER_MIRROR_PLUGIN_VIDEO_DECODER_H_

#include <android/native_window_jni.h>
#include <map>
#include <memory>
#include <string>
#include "media/media_format.h"
#include "media/video_csd.h"

class VideoDecoder {
 public:
  class Callback {
   public:
    virtual ~Callback() = default;

    virtual void OnVideoFormatChanged(
        int width,
        int height) = 0;

    virtual void OnVideoFrameRate(int fps) = 0;
  };

  virtual ~VideoDecoder() = default;

  virtual bool Start() = 0;

  virtual void Stop() = 0;

  virtual bool Decode(
      const uint8_t* frame,
      size_t frame_size,
      uint64_t presentationTimeUs) = 0;
};

typedef std::unique_ptr<VideoDecoder> VideoDecoderPtr;

VideoDecoderPtr CreateVideoDecoder(
    VideoCodecType codec_type,
    bool use_software_decoder,
    const VideoCsd&,
    const std::map<std::string, int>& codec_params,
    ANativeWindow* surface,
    VideoDecoder::Callback* callback);

#endif  // FLUTTER_MIRROR_PLUGIN_VIDEO_DECODER_H_
