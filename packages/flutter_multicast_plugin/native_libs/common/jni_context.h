#ifndef JNI_CONTEXT_H
#define JNI_CONTEXT_H

#ifdef __ANDROID__

#include <jni.h>

extern JavaVM* java_vm;
extern jobject g_plugin_instance;

void set_jni_context(JavaVM* vm, jobject plugin_instance);

#endif // __ANDROID__

#endif // JNI_CONTEXT_H