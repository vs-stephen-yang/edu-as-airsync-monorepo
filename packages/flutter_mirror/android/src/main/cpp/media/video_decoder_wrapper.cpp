#include "video_decoder_wrapper.h"
#include <dlfcn.h>
#include "util/log.h"

#define LIB_MEDIACODECTRACKER_NAME "libmedia_codec_tracker.so"

VideoDecoderWrapper::VideoDecoderWrapper() {
    void* handle = dlopen(LIB_MEDIACODECTRACKER_NAME, RTLD_NOW);
    if (handle != nullptr) {
        AMediaCodec_createDecoderByType_ = (AMediaCodec_createDecoderByType_t)dlsym(handle, "AMediaCodec_createDecoderByType_proxy");
        AMediaCodec_delete_ = (AMediaCodec_delete_t)dlsym(handle, "AMediaCodec_delete_proxy");
    }
    if (AMediaCodec_createDecoderByType_ == nullptr || AMediaCodec_delete_ == nullptr){
        AMediaCodec_createDecoderByType_ = ::AMediaCodec_createDecoderByType;
        AMediaCodec_delete_ = ::AMediaCodec_delete;
        ALOGV("failed to get target address in %s", LIB_MEDIACODECTRACKER_NAME);
    }
}

VideoDecoderWrapper::~VideoDecoderWrapper() {
}

AMediaCodec* VideoDecoderWrapper::AMediaCodec_createDecoderByType(const char* mime_type) {
    return AMediaCodec_createDecoderByType_(mime_type);
}

media_status_t VideoDecoderWrapper::AMediaCodec_delete(AMediaCodec* codec) {
    return AMediaCodec_delete_(codec);
}
