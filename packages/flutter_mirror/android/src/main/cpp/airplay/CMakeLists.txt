find_package(airplay REQUIRED CONFIG)

add_library(
  flutter_airplay
  STATIC
  ap_mirror_session.cpp
  ap_utils.cpp
  ap_receiver.cpp)

target_include_directories(flutter_airplay
  PRIVATE
  ../
)

target_link_libraries(
  flutter_airplay
  airplay::airplayreceiver)
