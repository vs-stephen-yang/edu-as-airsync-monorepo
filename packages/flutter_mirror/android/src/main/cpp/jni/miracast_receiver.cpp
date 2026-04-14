#include "jni/miracast_receiver.h"
#include <assert.h>
#include "util/jni/scoped_env.h"
#include "util/jni/string.h"
#include "util/log.h"

#define DEFINE_METHOD(NAME, SIG) \
  NAME##MID = env->GetMethodID(cls, #NAME, SIG);

namespace jni {

MiracastReceiver::MiracastReceiver(
    JavaVM* vm,
    JNIEnv* env,
    jobject obj)
    : vm_(vm) {
  obj_ = env->NewGlobalRef(obj);

  InitMethods(env, obj);
}

MiracastReceiver::~MiracastReceiver() {
  jni::ScopedEnv env(vm_);

  env->DeleteGlobalRef(obj_);
}

void MiracastReceiver::StopMirror(const std::string& mirrorId) {
  jni::ScopedEnv env(vm_);

  env->CallVoidMethod(
      obj_,
      stopMirrorMID,
      env->NewStringUTF(mirrorId.c_str()));
}

void MiracastReceiver::sendIdrRequest(const std::string& mirrorId) {
  jni::ScopedEnv env(vm_);

  env->CallVoidMethod(
      obj_,
      sendIdrRequestMID,
      env->NewStringUTF(mirrorId.c_str()));
}

void MiracastReceiver::InitMethods(
    JNIEnv* env,
    jobject obj) {
  jclass cls = env->GetObjectClass(obj);

  // void sendIdrRequest(std::string& mirrorId)
  DEFINE_METHOD(sendIdrRequest, "(Ljava/lang/String;)V");
  // void stopMirror(std::string& mirrorId)
  DEFINE_METHOD(stopMirror, "(Ljava/lang/String;)V");
}

}  // namespace jni
