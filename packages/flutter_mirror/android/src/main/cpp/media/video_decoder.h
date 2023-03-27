#ifndef FLUTTER_MIRROR_PLUGIN_VIDEO_DECODER_H_
#define FLUTTER_MIRROR_PLUGIN_VIDEO_DECODER_H_

#include <memory>

class VideoDecoder {
 public:
  enum class CodecType {
    kH264,
    kVp8
  };

  class Callback {
   public:
    virtual ~Callback() = default;

    virtual void OnVideoFormatChanged(
        int width,
        int height) = 0;
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
    VideoDecoder::CodecType codec_type,
    ANativeWindow* surface);

#endif  // FLUTTER_MIRROR_PLUGIN_VIDEO_DECODER_H_
