cmake_minimum_required(VERSION 3.16)

project(multicast_macos)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

message(STATUS "🔧 Building for ${CMAKE_SYSTEM_NAME} - ${CMAKE_OSX_ARCHITECTURES}")

# ======= Crypto++ ============
set(CRYPTOPP_SRC_DIR "${CMAKE_SOURCE_DIR}/../native_libs/cryptopp")
file(GLOB CRYPTOPP_SRC "${CRYPTOPP_SRC_DIR}/*.cpp")

add_library(cryptopp STATIC ${CRYPTOPP_SRC})
target_include_directories(cryptopp PUBLIC ${CRYPTOPP_SRC_DIR})

target_compile_definitions(cryptopp PRIVATE
    CRYPTOPP_DISABLE_ASM
    CRYPTOPP_DISABLE_AVX
    CRYPTOPP_DISABLE_AVX2
    CRYPTOPP_DISABLE_SSE4
)

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

# ======= Common (GStreamer + RTP Receiver core) =========
set(COMMON_DIR "${CMAKE_SOURCE_DIR}/../native_libs/common")
set(COMMON_SRC
    ${COMMON_DIR}/gst_video_pipeline.cpp
    ${COMMON_DIR}/gst_audio_pipeline.cpp
    ${COMMON_DIR}/gst_util.cpp
    ${COMMON_DIR}/rtp_receiver_core.cpp
    ${COMMON_DIR}/ip_pktinfo_detector.cpp
    ${COMMON_DIR}/h264_util.cpp
)

add_library(common STATIC ${COMMON_SRC})
target_compile_definitions(common PRIVATE PLATFORM_MACOS)
target_compile_definitions(common PRIVATE LOG_LEVEL=${LOG_LEVEL})

target_include_directories(common 
    PUBLIC
	${COMMON_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../native_libs
	${UVGRTP_DIR}/include
	${CMAKE_CURRENT_SOURCE_DIR}/gstreamer-headers
)

target_link_libraries(common
    PUBLIC
	"-framework VideoToolbox"
	"-framework CoreVideo"
	"-framework CoreMedia"
)