#include "media/video_csd_util.h"
#include "common_video/h264/h264_bitstream_parser.h"

namespace {
static const unsigned int kDefaultWidth = 1920;
static const unsigned int kDefaultHeight = 1080;

std::vector<uint8_t> AddNaluStartCodePrefix(const std::vector<uint8_t>& data) {
  static const std::vector<uint8_t> start_code = {0x00, 0x00, 0x00, 0x01};

  std::vector<uint8_t> ret;
  ret.reserve(start_code.size() + data.size());

  ret.insert(ret.end(), start_code.begin(), start_code.end());
  ret.insert(ret.end(), data.begin(), data.end());

  return ret;
}

}  // namespace

std::optional<VideoCsd> ParseH264VideoCsd(
    std::span<const uint8_t> frame) {
  webrtc::H264BitstreamParser parser;

  parser.ParseBitstream(frame);

  if (!parser.sps_.has_value() ||
      !parser.pps_.has_value()) {
    return std::nullopt;
  }

  // https://developer.android.com/reference/android/media/MediaCodec#CSD
  std::vector<uint8_t> csd0 = AddNaluStartCodePrefix(parser.raw_sps_);
  std::vector<uint8_t> csd1 = AddNaluStartCodePrefix(parser.raw_pps_);

  return VideoCsd{
      parser.sps_->width,
      parser.sps_->height,
      csd0,
      csd1,
  };
}

std::optional<VideoCsd> ParseVp8VideoCsd(
    std::span<const uint8_t> frame) {
  // TODO:
  return VideoCsd{
      kDefaultWidth,
      kDefaultHeight,
  };
}

std::optional<VideoCsd> ParseVideoCsd(
    VideoCodecType codec_type,
    std::span<const uint8_t> frame) {
  switch (codec_type) {
    case VideoCodecType::kH264:
      return ParseH264VideoCsd(frame);

    case VideoCodecType::kVp8:
      return ParseVp8VideoCsd(frame);

    default:
      return std::nullopt;
  }
}
