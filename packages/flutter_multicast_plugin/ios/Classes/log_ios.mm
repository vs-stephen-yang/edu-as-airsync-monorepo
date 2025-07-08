#include "log.h"
#import <Foundation/Foundation.h>
#include <cstdarg>

static void log_ns(const char *level, const char *fmt, va_list args) {
    char buffer[1024];
    vsnprintf(buffer, sizeof(buffer), fmt, args);
    NSLog(@"[%s] %s", level, buffer);
}

void ALOGV(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    log_ns("V", fmt, args);
    va_end(args);
}
void ALOGD(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    log_ns("D", fmt, args);
    va_end(args);
}
void ALOGI(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    log_ns("I", fmt, args);
    va_end(args);
}
void ALOGW(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    log_ns("W", fmt, args);
    va_end(args);
}
void ALOGE(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    log_ns("E", fmt, args);
    va_end(args);
}