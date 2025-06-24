#ifndef COMMON_LOG_H_
#define COMMON_LOG_H_

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