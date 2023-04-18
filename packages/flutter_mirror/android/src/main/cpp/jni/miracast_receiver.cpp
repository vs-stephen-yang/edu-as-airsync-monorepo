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


void MiracastReceiver::sendIdrRequest(int mirrorId) {
  jni::ScopedEnv env(vm_);

  env->CallVoidMethod(
      obj_,
      sendIdrRequestMID,
      mirrorId);
}

void MiracastReceiver::InitMethods(
    JNIEnv* env,
    jobject obj) {
  jclass cls = env->GetObjectClass(obj);

  // void sendIdrRequest(int mirrorId)
  DEFINE_METHOD(sendIdrRequest, "(I)V");
}

}  // namespace jni
