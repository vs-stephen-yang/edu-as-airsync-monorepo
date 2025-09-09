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

# --- 🎥 GStreamer Android SDK -----------------------
if(DEFINED ENV{GSTREAMER_SDK_ANDROID})
  set(GSTREAMER_ROOT $ENV{GSTREAMER_SDK_ANDROID})
  message(STATUS "[CMake] Using GStreamer SDK path from environment: ${GSTREAMER_ROOT}")
else()
  message(FATAL_ERROR "GSTREAMER_SDK_ANDROID environment variable not set!")
endif()

if (${ANDROID_ABI} STREQUAL "arm64-v8a")
  set(GSTREAMER_TARGET_ARCH "arm64")
elseif (${ANDROID_ABI} STREQUAL "armeabi-v7a")
  set(GSTREAMER_TARGET_ARCH "armv7")
elseif (${ANDROID_ABI} STREQUAL "x86_64")
  set(GSTREAMER_TARGET_ARCH "x86_64")
elseif (${ANDROID_ABI} STREQUAL "x86")
  set(GSTREAMER_TARGET_ARCH "x86")
else()
  message(FATAL_ERROR "Unsupported ANDROID_ABI: ${ANDROID_ABI}")
endif()

set(GStreamer_ROOT_DIR "${GSTREAMER_ROOT}/${GSTREAMER_TARGET_ARCH}")
set(GStreamer_NDK_BUILD_PATH "${GStreamer_ROOT_DIR}/share/gst-android/ndk-build")
message(STATUS "GStreamer_NDK_BUILD_PATH=${GStreamer_NDK_BUILD_PATH}")

link_directories(${GSTREAMER_ROOT}/${GSTREAMER_TARGET_ARCH}/lib)
set(CMAKE_MODULE_PATH "${GSTREAMER_ROOT}/${GSTREAMER_TARGET_ARCH}/share/cmake" ${CMAKE_MODULE_PATH})
set(GStreamer_USE_STATIC_LIBS ON)
set(GStreamer_EXTRA_DEPS gstreamer-app-1.0 gstreamer-video-1.0)

set(GStreamer_JAVA_SRC_DIR "../main/java")

find_package(GStreamerMobile REQUIRED COMPONENTS
        udp
        coreelements
        rtp
        rtpmanager
        mpegtsdemux
        libav
        audioconvert
        audioresample
        autodetect
        audioparsers
        opensles
)

target_link_libraries(GStreamerMobile PRIVATE
        orc-0.4
        ffi
        gmodule-2.0
        gobject-2.0
        glib-2.0
        intl
        pcre2-8
        iconv
        z
)

set(GStreamer_INCLUDE_DIRS
        ${GStreamer_ROOT_DIR}/include
        ${GStreamer_ROOT_DIR}/include/gstreamer-1.0
        ${GStreamer_ROOT_DIR}/include/glib-2.0
        ${GStreamer_ROOT_DIR}/lib/glib-2.0/include
)

include_directories(${GStreamer_INCLUDE_DIRS})

add_library(orc-0.4 STATIC IMPORTED)
set_target_properties(orc-0.4 PROPERTIES
        IMPORTED_LOCATION "${GSTREAMER_ROOT}/${GSTREAMER_TARGET_ARCH}/lib/liborc-0.4.a"
        INTERFACE_INCLUDE_DIRECTORIES "${GSTREAMER_ROOT}/${GSTREAMER_TARGET_ARCH}/include/orc-0.4"
)

add_library(ffi STATIC IMPORTED)
set_target_properties(ffi PROPERTIES
        IMPORTED_LOCATION "${GSTREAMER_ROOT}/${GSTREAMER_TARGET_ARCH}/lib/libffi.a"
        INTERFACE_INCLUDE_DIRECTORIES "${GSTREAMER_ROOT}/${GSTREAMER_TARGET_ARCH}/include"
)

add_library(gmodule-2.0 STATIC IMPORTED)
set_target_properties(gmodule-2.0 PROPERTIES
        IMPORTED_LOCATION "${GSTREAMER_ROOT}/${GSTREAMER_TARGET_ARCH}/lib/libgmodule-2.0.a"
        INTERFACE_INCLUDE_DIRECTORIES "${GSTREAMER_ROOT}/${GSTREAMER_TARGET_ARCH}/include/glib-2.0"
)

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
  ${GSTREAMER_INCLUDE_DIRS}
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
  GStreamerMobile
  oboe::oboe
  android
  mediandk
  common_video
  flutter_airplay
  flutter_googlecast
  flutter_miracast
  ${log-lib})
