#ifdef __ANDROID__

#include "jni_context.h"

JavaVM* g_java_vm = nullptr;
jobject g_plugin_instance = nullptr;

void set_jni_context(JavaVM* vm, jobject plugin_instance) {
    g_java_vm = vm;
    g_plugin_instance = plugin_instance;
}

#endif // __ANDROID__