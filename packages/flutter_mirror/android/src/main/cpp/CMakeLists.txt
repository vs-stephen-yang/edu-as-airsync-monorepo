# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.18.1)

# Declares and names the project.
project("flutter_mirror")

# C++ 20
set(CMAKE_CXX_STANDARD 20)

find_package(oboe REQUIRED CONFIG)

add_subdirectory(mpeg2ts)

add_subdirectory(airplay)
add_subdirectory(googlecast)
add_subdirectory(miracast)
add_subdirectory(common_video)

aux_source_directory(./ src)
aux_source_directory(./util/jni util_jni_src)
aux_source_directory(./media media_src)
aux_source_directory(./util util_src)
aux_source_directory(./jni jni_src)
aux_source_directory(./replay replay_src)

add_library(
  flutter_mirror
  SHARED
  ${src}
  ${media_src}
  ${replay_src}
  ${util_src}
  ${util_jni_src}
  ${jni_src})

target_include_directories(
  flutter_mirror
  PRIVATE
  ./
)

# Searches for a specified prebuilt library and stores the path as a
# variable. Because CMake includes system libraries in the search path by
# default, you only need to specify the name of the public NDK library
# you want to add. CMake verifies that the library exists before
# completing its build.
find_library( # Sets the name of the path variable.
  log-lib

  # Specifies the name of the NDK library that
  # you want CMake to locate.
  log)

# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.
target_link_libraries( # Specifies the target library.
  flutter_mirror
  oboe::oboe
  android
  mediandk
  common_video
  flutter_airplay
  flutter_googlecast
  flutter_miracast
  ${log-lib})
