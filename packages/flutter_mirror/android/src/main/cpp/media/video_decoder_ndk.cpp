#include "video_decoder_ndk.h"
#include <assert.h>
#include <map>
#include <string>
#include "util/log.h"
#include "video_decoder_wrapper.h"

const std::string VideoDecoderNdk::kMimeH264 = "video/avc";
const std::string VideoDecoderNdk::kMimeVp8 = "video/x-vnd.on2.vp8";

static const int64_t kDequeueInputTimeoutUs = 1000 * 1000;  // in microseconds
static const int64_t kDequeueOutputTimeoutUs = 100 * 1000;  // in microseconds

namespace {

void SetFmtCsd(AMediaFormat* fmt, const char* name, const std::vector<uint8_t>& csd) {
  if (csd.empty()) {
    return;
  }

  AMediaFormat_setBuffer(fmt, name, csd.data(), csd.size());
}

}  // namespace
VideoDecoderNdk::VideoDecoderNdk(
    AMediaCodec* codec,
    const std::map<std::string, int>& codec_params,
    VideoDecoder::Callback* callback)
    : codec_(codec),
      codec_params_(codec_params),
      callback_(callback),
      running_(false) {
}

VideoDecoderNdk::~VideoDecoderNdk() {
  ALOGV("~VideoDecoderNdk()");
}

bool VideoDecoderNdk::Init(
    const std::string& mime,
    const VideoCsd& csd,
    ANativeWindow* surface) {
  assert(surface != nullptr);

  AMediaFormatPtr fmt(AMediaFormat_new());

  AMediaFormat_setString(fmt.get(), AMEDIAFORMAT_KEY_MIME, mime.c_str());

  // TODO: Do we need to specify valid width and height?
  AMediaFormat_setInt32(fmt.get(), AMEDIAFORMAT_KEY_WIDTH, csd.width);
  AMediaFormat_setInt32(fmt.get(), AMEDIAFORMAT_KEY_HEIGHT, csd.height);

  // codec-specific data
  SetFmtCsd(fmt.get(), "csd-0", csd.csd0);
  SetFmtCsd(fmt.get(), "csd-1", csd.csd1);

  // set codec specific parameters
  for (const auto& kv : codec_params_) {
    AMediaFormat_setInt32(fmt.get(), kv.first.c_str(), kv.second);
    ALOGV("Set codec parameter: %s=%d", kv.first.c_str(), kv.second);
  }

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
  frame_count_ = 0;
  start_time_ = std::chrono::steady_clock::now();

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
    if (!buf) {
      ALOGE("cannot get input buffer. bufIdx:%d", (int)bufIdx);
      return false;
    }

    memcpy(buf, frame, frameSize);
    uint32_t flags = 0;

    // Do not submit multiple input buffers with the same timestamp (unless it is codec-specific data marked as such).
    AMediaCodec_queueInputBuffer(codec_.get(), bufIdx, 0, frameSize, presentationTimeUs, flags);
  }
  return true;
}
void VideoDecoderNdk::OnFrameDecoded() {
  MeasureFrameRate();
}

void VideoDecoderNdk::MeasureFrameRate() {
  // Increment frame count
  ++frame_count_;

  // Calculate FPS every second
  auto now = std::chrono::steady_clock::now();
  auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(now - start_time_).count();

  if (elapsed >= 1000) {
    int fps = frame_count_;

    if (callback_) {
      callback_->OnVideoFrameRate(fps);
    }

    // Reset frame count
    frame_count_ = 0;

    if (elapsed <= 2000) {
      // Normal case: Adjust start_time_ by removing the extra elapsed time
      start_time_ = now - std::chrono::milliseconds(elapsed - 1000);
    } else {
      // Large elapsed time case
      start_time_ = now;
    }
  }
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

    OnFrameDecoded();

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
std::string GetSoftwareDecoderNameForCodecType(VideoCodecType codec_type) {
  switch (codec_type) {
    case VideoCodecType::kH264:
      return "OMX.google.h264.decoder";
    case VideoCodecType::kVp8:
      return "OMX.google.vp8.decoder";
    default:
      // won't reach
      assert(false);
  }
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
    bool use_software_decoder,
    const VideoCsd& csd,
    const std::map<std::string, int>& codec_params,
    ANativeWindow* surface,
    VideoDecoder::Callback* callback) {
  assert(surface);
  assert(callback);

  AMediaCodec* codec = nullptr;

  std::string mime_type = CodecType2Mime(codec_type);

  if (use_software_decoder) {
    std::string name = GetSoftwareDecoderNameForCodecType(codec_type);
    codec = AMediaCodec_createCodecByName(name.c_str());
  } else {
    codec = VideoDecoderWrapper::GetInstance().AMediaCodec_createDecoderByType(mime_type.c_str());
  }

  if (!codec) {
    return {};
  }

  auto decoder = std::make_unique<VideoDecoderNdk>(
      codec,
      codec_params,
      callback);

  if (!decoder->Init(
          mime_type,
          csd,
          surface)) {
    return {};
  }

  return decoder;
}
