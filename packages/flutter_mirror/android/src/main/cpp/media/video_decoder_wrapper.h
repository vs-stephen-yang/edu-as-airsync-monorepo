#ifndef FLUTTER_MIRROR_PLUGIN_VIDEO_DECODER_WRAPPER_H_
#define FLUTTER_MIRROR_PLUGIN_VIDEO_DECODER_WRAPPER_H_

#include <media/NdkMediaCodec.h>

class VideoDecoderWrapper {
 public:
  ~VideoDecoderWrapper();

  static VideoDecoderWrapper& GetInstance() {
   static VideoDecoderWrapper s_wrapper;
   return s_wrapper;
  }

  AMediaCodec* AMediaCodec_createDecoderByType(const char* mime_type);
  media_status_t AMediaCodec_delete(AMediaCodec* codec);

 private:
  VideoDecoderWrapper();

  typedef AMediaCodec* (*AMediaCodec_createDecoderByType_t)(const char* mime_type);
  typedef media_status_t (*AMediaCodec_delete_t)(AMediaCodec* codec);

  AMediaCodec_createDecoderByType_t AMediaCodec_createDecoderByType_ = nullptr;
  AMediaCodec_delete_t AMediaCodec_delete_ = nullptr;
};

#endif //FLUTTER_MIRROR_PLUGIN_VIDEO_DECODER_WRAPPER_H_
