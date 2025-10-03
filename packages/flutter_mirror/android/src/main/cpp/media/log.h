#include <android/log.h>
#define LOG_TAG "Media"
#define ALOGV(...) __android_log_print(ANDROID_LOG_VERBOSE, LOG_TAG, __VA_ARGS__)
#define ALOGD(...) __android_log_print(ANDROID_LOG_WARN, LOG_TAG, __VA_ARGS__)
#define ALOGI(...) __android_log_print(ANDROID_LOG_WARN, LOG_TAG, __VA_ARGS__)
#define ALOGW(...) __android_log_print(ANDROID_LOG_WARN, LOG_TAG, __VA_ARGS__)
#define ALOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

static void android_log_function(GstDebugCategory* category,
                                 GstDebugLevel level,
                                 const gchar* file,
                                 const gchar* function,
                                 gint line,
                                 GObject* object,
                                 GstDebugMessage* message,
                                 gpointer user_data) {
  android_LogPriority priority = ANDROID_LOG_DEBUG;
  const char* level_str = "DEBUG";

  switch (level) {
    case GST_LEVEL_ERROR:
      priority = ANDROID_LOG_ERROR;
      level_str = "ERROR";
      break;
    case GST_LEVEL_WARNING:
      priority = ANDROID_LOG_WARN;
      level_str = "WARN";
      break;
    case GST_LEVEL_INFO:
      priority = ANDROID_LOG_INFO;
      level_str = "INFO";
      break;
    case GST_LEVEL_DEBUG:
      priority = ANDROID_LOG_DEBUG;
      level_str = "DEBUG";
      break;
    case GST_LEVEL_LOG:
      priority = ANDROID_LOG_VERBOSE;
      level_str = "LOG";
      break;
    default:
      priority = ANDROID_LOG_VERBOSE;
      level_str = "TRACE";
      break;
  }

  const gchar* category_name = gst_debug_category_get_name(category);
  const gchar* msg = gst_debug_message_get(message);

  __android_log_print(priority, "GST_DEBUG", "[%s] %s", category_name, msg);
}