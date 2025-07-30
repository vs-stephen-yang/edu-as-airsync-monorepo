cmake_minimum_required(VERSION 3.10.2)
cmake_policy(SET CMP0079 NEW)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

project(multicast_android)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# 設定 JNI 路徑
set(JNI_LIB_NAME multicast_android)

# ✅ 啟用 SRTP
set(UVGRTP_ENABLE_SRTP ON CACHE BOOL "Enable SRTP")
message(STATUS "[CMake] Enabling UVG_CRYPTO")

# 加入 uvgRTP 子專案（你需要將 uvgRTP clone 到這個資料夾）
set(UVGRTP_DISABLE_TESTS ON)
set(UVGRTP_DISABLE_EXAMPLES ON)
set(UVGRTP_DISABLE_GTEST ON)

# 加入 Crypto++（先建出靜態庫）
set(CRYPTOPP_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../../native_libs/cryptopp")
file(GLOB CRYPTOPP_SRC CONFIGURE_DEPENDS "${CRYPTOPP_SRC_DIR}/*.cpp")

# 過濾掉會導致 Clang crash 的 SIMD 文件
list(REMOVE_ITEM CRYPTOPP_SRC
        "${CRYPTOPP_SRC_DIR}/rijndael_simd.cpp"
        "${CRYPTOPP_SRC_DIR}/gf2n_simd.cpp"
        "${CRYPTOPP_SRC_DIR}/gcm_simd.cpp"
        "${CRYPTOPP_SRC_DIR}/crc_simd.cpp"
        "${CRYPTOPP_SRC_DIR}/sha_simd.cpp"
)

# 確保 ANDROID_NDK 有被定義
if(NOT DEFINED ANDROID_NDK)
    message(FATAL_ERROR "ANDROID_NDK is not set. Please ensure the Android NDK path is available.")
endif()

# 手動加入 cpufeatures
set(CPUFEATURES_SRC "${ANDROID_NDK}/sources/android/cpufeatures/cpu-features.c")
if(EXISTS ${CPUFEATURES_SRC})
    add_library(cpufeatures STATIC ${CPUFEATURES_SRC})
else()
    message(FATAL_ERROR "cpu-features.c not found in NDK path: ${CPUFEATURES_SRC}")
endif()


add_library(cryptopp STATIC ${CRYPTOPP_SRC})
target_include_directories(cryptopp PUBLIC ${CRYPTOPP_SRC_DIR})

# NDK root（Android Studio 自動設好 ANDROID_NDK 變數）
set(ANDROID_CPufeatures_INCLUDE_DIR "${ANDROID_NDK}/sources/android/cpufeatures")

# Crypto++ include path，加上 NDK cpufeatures 路徑
target_include_directories(cryptopp PUBLIC
        ${CRYPTOPP_SRC_DIR}
        ${ANDROID_CPufeatures_INCLUDE_DIR}
)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../../../../native_libs/uvgrtp ${CMAKE_CURRENT_BINARY_DIR}/uvgrtp_build)

target_include_directories(uvgrtp PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/../../../../native_libs
)

# ✅ 對 uvgRTP 開啟 Crypto++ 支援
target_compile_definitions(uvgrtp PRIVATE ENABLE_SRTP UVG_CRYPTO)

target_link_libraries(uvgrtp PRIVATE cryptopp)

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
        app
        coreelements
        videoparsersbad
        libav
        videoconvertscale
        opengl
        playback
        audioconvert
        opus
        opensles
        autodetect
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

set(COMMON_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../../native_libs/common")

set(COMMON_SRC
        ${COMMON_DIR}/rtp_receiver_core.cpp
        ${COMMON_DIR}/ip_pktinfo_detector.cpp
        ${COMMON_DIR}/gst_video_pipeline.cpp
        ${COMMON_DIR}/gst_audio_pipeline.cpp
        ${COMMON_DIR}/gst_util.cpp
        ${COMMON_DIR}/jni_context.cpp
)

# 加入 JNI 的 source
add_library(${JNI_LIB_NAME} SHARED
        multicast_sender.cpp
        multicast_receiver.cpp

        ${COMMON_SRC}
)

# 加入 include path
target_include_directories(${JNI_LIB_NAME}
        PRIVATE
        ${GSTREAMER_INCLUDE_DIRS}
        ${CRYPTOPP_SRC_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/../../../../native_libs/uvgrtp/include
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${COMMON_DIR}
)

add_definitions(-DCRYPTOPP_DISABLE_ASM)

# 對接 Android NDK 的 log 與 JNI
find_library(log-lib log)
find_library(android-lib android)
find_library(jnigraphics-lib jnigraphics)
find_library(media-ndk-lib mediandk)

target_link_libraries(${JNI_LIB_NAME}
        uvgrtp
        cryptopp
        cpufeatures

        GStreamerMobile

        ${log-lib}
        ${android-lib}
        ${jnigraphics-lib}
        ${media-ndk-lib}
)
