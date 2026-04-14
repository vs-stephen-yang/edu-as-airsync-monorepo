aux_source_directory(./ src)

add_library(
  mpeg2ts
  STATIC
  ${src})

target_include_directories(
  mpeg2ts
  PRIVATE
  ../
)
