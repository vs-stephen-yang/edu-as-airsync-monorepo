cmake_minimum_required(VERSION 3.16)

project(multicast_ios)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

message(STATUS "🔧 Building for ${CMAKE_SYSTEM_NAME} - ${CMAKE_OSX_ARCHITECTURES}")

# ======= Crypto++ ============
set(CRYPTOPP_SRC_DIR "${CMAKE_SOURCE_DIR}/../native_libs/cryptopp")
file(GLOB CRYPTOPP_SRC "${CRYPTOPP_SRC_DIR}/*.cpp")

# Remove SIMD files that crash Clang on iOS
list(REMOVE_ITEM CRYPTOPP_SRC
        "${CRYPTOPP_SRC_DIR}/rijndael_simd.cpp"
        "${CRYPTOPP_SRC_DIR}/gf2n_simd.cpp"
        "${CRYPTOPP_SRC_DIR}/gcm_simd.cpp"
        "${CRYPTOPP_SRC_DIR}/crc_simd.cpp"
        "${CRYPTOPP_SRC_DIR}/sha_simd.cpp"
)

add_library(cryptopp STATIC ${CRYPTOPP_SRC})
target_include_directories(cryptopp PUBLIC ${CRYPTOPP_SRC_DIR})
target_compile_definitions(cryptopp PRIVATE CRYPTOPP_DISABLE_ASM)

# ======= uvgRTP ===============
set(UVGRTP_DIR "${CMAKE_SOURCE_DIR}/../native_libs/uvgrtp")

# optional: disable building tests/examples
set(UVGRTP_DISABLE_TESTS ON CACHE BOOL "" FORCE)
set(UVGRTP_DISABLE_EXAMPLES ON CACHE BOOL "" FORCE)
set(UVGRTP_DISABLE_GTEST ON CACHE BOOL "" FORCE)

# ✅ 啟用 SRTP
set(UVGRTP_ENABLE_SRTP ON CACHE BOOL "Enable SRTP")
message(STATUS "[CMake] Enabling UVG_CRYPTO")

# ✅ 加入 uvgRTP（它會建立自己的 target）
add_subdirectory(${UVGRTP_DIR} ${CMAKE_BINARY_DIR}/uvgrtp)

# ✅ 外部補上對 cryptopp 的依賴
target_link_libraries(uvgrtp PRIVATE cryptopp)

# ✅ 外部補上 include 路徑給 uvgRTP
target_include_directories(uvgrtp PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/../native_libs
)

# ✅ 補上 SRTP 與 Crypto flag（因為你不能 patch uvgrtp CMake）
target_compile_definitions(uvgrtp PRIVATE ENABLE_SRTP UVG_CRYPTO)

# ======= GStreamer SDK (for iOS) =======
if(DEFINED ENV{GSTREAMER_SDK_IOS})
    set(GST_FRAMEWORK $ENV{GSTREAMER_SDK_IOS})
    message(STATUS "[CMake] Using GStreamer SDK path from environment: ${GSTREAMER_ROOT}")
else()
    message(FATAL_ERROR "GSTREAMER_SDK_IOS environment variable not set!")
endif()

# Headers (等同於 include/gstreamer-1.0)
include_directories(${GST_FRAMEWORK}/Headers)

# Libraries (libgstreamer-1.0.a 等都在這)
link_directories(${GST_FRAMEWORK}/Libraries)

# 編譯 gst_ios_init.mm 為靜態庫
add_library(gst_ios_init STATIC native_src/gstreamer/gst_ios_init.mm)
target_include_directories(gst_ios_init PUBLIC native_src/gstreamer)

# 重要：連結必要的靜態庫
target_link_libraries(gst_ios_init
    PUBLIC
    "-framework GStreamer"
)

# ======= Common (GStreamer + RTP Receiver core) =========
set(COMMON_DIR "${CMAKE_SOURCE_DIR}/../native_libs/common")
set(COMMON_SRC
    ${COMMON_DIR}/gst_video_pipeline.cpp
    ${COMMON_DIR}/gst_audio_pipeline.cpp
    ${COMMON_DIR}/gst_util.cpp
    ${COMMON_DIR}/rtp_receiver_core.cpp
    ${COMMON_DIR}/ip_pktinfo_detector.cpp
)

add_library(common STATIC ${COMMON_SRC})
target_compile_definitions(common PRIVATE PLATFORM_IOS)

target_include_directories(common 
    PUBLIC
	${COMMON_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../native_libs
	${UVGRTP_DIR}/include
	${GST_FRAMEWORK}/Headers
)

target_link_libraries(common
    PUBLIC
		gst_ios_init
		"-framework GStreamer"
		"-framework VideoToolbox"
		"-framework CoreVideo"
		"-framework CoreMedia"
        gstapp-1.0
        gstreamer-1.0
        gstbase-1.0
        gstvideo-1.0
        gstpbutils-1.0
        gstcontroller-1.0
        gstgl-1.0
        gobject-2.0
        glib-2.0
        intl
        z
)

# ======= UvgRtpBridge.mm (Objective-C++) =========
set(BRIDGE_SRC
    ${CMAKE_SOURCE_DIR}/Classes/MulticastBridge.mm
)

add_library(MulticastBridge STATIC ${BRIDGE_SRC})

# include headers for bridge
target_include_directories(MulticastBridge
    PRIVATE
    ${COMMON_DIR}
    ${CRYPTOPP_SRC_DIR}
    ${UVGRTP_DIR}/include
    ${GST_INCLUDE_DIRS}
)

target_link_libraries(MulticastBridge
	gst_ios_init
	"-framework GStreamer"
	"-framework VideoToolbox"
	"-framework CoreVideo"
	"-framework CoreMedia"
	"-framework AudioToolbox"
    uvgrtp
    cryptopp
    common
    gstapp-1.0
    gstreamer-1.0
    gstbase-1.0
    gstvideo-1.0
    gstpbutils-1.0
    gstcontroller-1.0
    gstgl-1.0
    gobject-2.0
    glib-2.0
    intl
    z
)