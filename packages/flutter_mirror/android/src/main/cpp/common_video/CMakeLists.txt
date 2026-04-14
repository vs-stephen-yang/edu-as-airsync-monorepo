
add_library(
  common_video
  STATIC
  h264/h264_bitstream_parser.cc
  h264/h264_common.cc
  h264/pps_parser.cc
  h264/sps_parser.cc
  bitstream_reader.cc)

target_include_directories(
  common_video
  PRIVATE
  ../
)
