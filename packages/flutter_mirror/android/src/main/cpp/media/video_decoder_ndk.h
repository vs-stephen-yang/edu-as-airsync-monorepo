#ifndef FLUTTER_MIRROR_PLUGIN_VIDEO_DECODER_NDK_H_
#define FLUTTER_MIRROR_PLUGIN_VIDEO_DECODER_NDK_H_

#include <media/NdkMediaCodec.h>
#include <media/NdkMediaError.h>

#include "media/ndk_media_util.h"
#include "media/video_decoder.h"

#include <atomic>
#include <thread>
#include "media/video_csd.h"

class VideoDecoderNdk
    : public VideoDecoder {
 public:
  static const std::string kMimeH264;
  static const std::string kMimeVp8;

  VideoDecoderNdk(
      VideoDecoder::Callback* callback);

  ~VideoDecoderNdk();

  bool Init(
      const std::string& mime,
      const VideoCsd& csd,
      ANativeWindow* surface);

  virtual bool Start();
  virtual void Stop();

  virtual bool Decode(
      const uint8_t* frame,
      size_t frame_size,
      uint64_t presentationTimeUs);

 private:
  bool DeliverDecodedFrame();

  AMediaCodecPtr codec_;

  std::unique_ptr<std::thread> thread_;

  std::atomic_bool running_;

  Callback* callback_ = nullptr;
};

#endif  // FLUTTER_MIRROR_PLUGIN_VIDEO_DECODER_NDK_H_
