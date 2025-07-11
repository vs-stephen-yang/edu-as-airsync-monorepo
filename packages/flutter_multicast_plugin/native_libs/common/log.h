#ifndef COMMON_LOG_H_
#define COMMON_LOG_H_

#ifndef LOG_LEVEL
#define LOG_LEVEL 1 // 預設 DEBUG
#endif

#define LOG_LEVEL_VERBOSE 0
#define LOG_LEVEL_DEBUG 1
#define LOG_LEVEL_INFO 2
#define LOG_LEVEL_WARN 3
#define LOG_LEVEL_ERROR 4
#define LOG_LEVEL_NONE 5

#if defined(__ANDROID__)
#include <android/log.h>
#define LOG_TAG "Common"
#define ALOGV(...) __android_log_print(ANDROID_LOG_VERBOSE, LOG_TAG, __VA_ARGS__)
#define ALOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define ALOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define ALOGW(...) __android_log_print(ANDROID_LOG_WARN, LOG_TAG, __VA_ARGS__)
#define ALOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

#else
// 非 Android 平台（如 iOS）只宣告，不定義
void ALOGV(const char* fmt, ...);
void ALOGD(const char* fmt, ...);
void ALOGI(const char* fmt, ...);
void ALOGW(const char* fmt, ...);
void ALOGE(const char* fmt, ...);
#endif

#endif // COMMON_LOG_H_