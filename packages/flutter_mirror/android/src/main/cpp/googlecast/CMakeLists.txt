find_package(googlecast REQUIRED CONFIG)

add_library(
  flutter_googlecast
  STATIC
  googlecast_mirror_session.cpp
  googlecast_utils.cpp
  googlecast_receiver.cpp)

target_include_directories(
  flutter_googlecast
  PRIVATE
  ../
)

target_link_libraries(
  flutter_googlecast
  googlecast::cast)
