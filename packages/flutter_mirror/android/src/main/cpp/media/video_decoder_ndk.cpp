#include "video_decoder_ndk.h"
#include <assert.h>
#include "util/log.h"

const std::string VideoDecoderNdk::kMimeH264 = "video/avc";
const std::string VideoDecoderNdk::kMimeVp8 = "video/x-vnd.on2.vp8";

static const int64_t kDequeueInputTimeoutUs = 1000 * 1000;  // in microseconds
static const int64_t kDequeueOutputTimeoutUs = 100 * 1000;  // in microseconds

VideoDecoderNdk::VideoDecoderNdk(
    VideoDecoder::Callback* callback)
    : callback_(callback),
      running_(false) {
}

VideoDecoderNdk::~VideoDecoderNdk() {
  ALOGV("~VideoDecoderNdk()");
}

bool VideoDecoderNdk::Init(
    const std::string& mime,
    ANativeWindow* surface) {
  assert(surface != nullptr);

  codec_.reset(
      AMediaCodec_createDecoderByType(mime.c_str()));
  assert(codec_);

  AMediaFormatPtr fmt(AMediaFormat_new());

  AMediaFormat_setString(fmt.get(), AMEDIAFORMAT_KEY_MIME, mime.c_str());

  // TODO: Do we need to specify valid width and height?
  AMediaFormat_setInt32(fmt.get(), AMEDIAFORMAT_KEY_WIDTH, 100);
  AMediaFormat_setInt32(fmt.get(), AMEDIAFORMAT_KEY_HEIGHT, 100);

  media_status_t status = AMediaCodec_configure(
      codec_.get(),
      fmt.get(),
      surface,
      nullptr /* crypto */,
      0);

  if (status != AMEDIA_OK) {
    ALOGE("AMediaCodec_configure() failed. %d", (int)status);
    return false;
  }

  return true;
}

bool VideoDecoderNdk::Start() {
  ALOGD("VideoDecoderNdk::Start()");

  media_status_t status = AMediaCodec_start(codec_.get());

  if (status != AMEDIA_OK) {
    ALOGE("AMediaCodec_start() failed. %d", (int)status);
    return false;
  }

  running_ = true;

  thread_ = std::make_unique<std::thread>(
      [this]() {
        ALOGD("Video decoder thread is starting");

        while (running_) {
          DeliverDecodedFrame();
        }

        ALOGD("Video decoder thread is exiting");
      });

  return true;
}

void VideoDecoderNdk::Stop() {
  ALOGD("VideoDecoderNdk::Stop()");

  running_ = false;

  if (thread_) {
    ALOGD("Stopping video decoder thread");
    thread_->join();
  }

  if (codec_) {
    AMediaCodec_stop(codec_.get());
  }
}

bool VideoDecoderNdk::Decode(const uint8_t* frame, size_t frameSize, uint64_t presentationTimeUs) {
  ssize_t bufIdx = AMediaCodec_dequeueInputBuffer(
      codec_.get(),
      kDequeueInputTimeoutUs);

  if (bufIdx >= 0) {
    size_t buf_size = 0;
    uint8_t* buf = AMediaCodec_getInputBuffer(codec_.get(), bufIdx, &buf_size);

    memcpy(buf, frame, frameSize);
    uint32_t flags = 0;

    // Do not submit multiple input buffers with the same timestamp (unless it is codec-specific data marked as such).
    AMediaCodec_queueInputBuffer(codec_.get(), bufIdx, 0, frameSize, presentationTimeUs, flags);
  }
  return true;
}

bool VideoDecoderNdk::DeliverDecodedFrame() {
  AMediaCodecBufferInfo info;

  ssize_t status = AMediaCodec_dequeueOutputBuffer(
      codec_.get(),
      &info,
      kDequeueOutputTimeoutUs);

  if (status >= 0) {
    int buf_idx = status;
    size_t buf_size = 0;
    uint8_t* buf = AMediaCodec_getOutputBuffer(codec_.get(), buf_idx, &buf_size);

    // render each output buffer on the surface
    AMediaCodec_releaseOutputBuffer(codec_.get(), buf_idx, true);

    return true;
  } else if (status == AMEDIACODEC_INFO_OUTPUT_BUFFERS_CHANGED) {
  } else if (status == AMEDIACODEC_INFO_OUTPUT_FORMAT_CHANGED) {
    AMediaFormat* format = AMediaCodec_getOutputFormat(codec_.get());

    int32_t width, height, color, stride;

    AMediaFormat_getInt32(format, AMEDIAFORMAT_KEY_WIDTH, &width);
    AMediaFormat_getInt32(format, AMEDIAFORMAT_KEY_HEIGHT, &height);
    AMediaFormat_getInt32(format, AMEDIAFORMAT_KEY_COLOR_FORMAT, &color);
    AMediaFormat_getInt32(format, AMEDIAFORMAT_KEY_STRIDE, &stride);

    if (callback_) {
      callback_->OnVideoFormatChanged(width, height);
    }

    ALOGI("Video format changed: %dx%d stride:%d ColorFormat:%d",
          width, height,
          stride, color);

  } else if (status == AMEDIACODEC_INFO_TRY_AGAIN_LATER) {
  } else {
    // unexpected
  }

  return false;
}

std::string CodecType2Mime(VideoCodecType codec_type) {
  switch (codec_type) {
    case VideoCodecType::kH264:
      return VideoDecoderNdk::kMimeH264;
    case VideoCodecType::kVp8:
      return VideoDecoderNdk::kMimeVp8;
    default:
      // won't reach
      assert(false);
  }
}

VideoDecoderPtr CreateVideoDecoder(
    VideoCodecType codec_type,
    ANativeWindow* surface,
    VideoDecoder::Callback* callback) {
  assert(surface);
  assert(callback);

  auto decoder = std::make_unique<VideoDecoderNdk>(callback);

  if (!decoder->Init(
          CodecType2Mime(codec_type),
          surface)) {
    return {};
  }

  return decoder;
}
