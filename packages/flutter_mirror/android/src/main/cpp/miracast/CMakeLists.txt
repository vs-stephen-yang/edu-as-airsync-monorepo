aux_source_directory(./ src)

add_library(
  flutter_miracast
  STATIC
  ${src})

target_include_directories(
  flutter_miracast
  PRIVATE
  ../
)

target_link_libraries(
  flutter_miracast
  mpeg2ts)
