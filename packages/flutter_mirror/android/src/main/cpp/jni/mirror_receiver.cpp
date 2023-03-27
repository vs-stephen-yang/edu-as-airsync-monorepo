#include "jni/mirror_receiver.h"
#include <assert.h>
#include "util/jni/scoped_env.h"
#include "util/jni/string.h"
#include "util/log.h"

#define DEFINE_METHOD(NAME, SIG) \
  NAME = env->GetMethodID(cls, #NAME, SIG);

namespace jni {

MirrorReceiver::MirrorReceiver(
    JavaVM* vm,
    JNIEnv* env,
    jobject obj)
    : vm_(vm) {
  obj_ = env->NewGlobalRef(obj);

  InitMethods(env, obj);
}

MirrorReceiver::~MirrorReceiver() {
  jni::ScopedEnv env(vm_);

  env->DeleteGlobalRef(obj_);
}

void MirrorReceiver::OnMirrorAuth(
    const std::string& pin,
    unsigned int timeout_sec) {
  jni::ScopedEnv env(vm_);

  env->CallVoidMethod(
      obj_,
      onMirrorAuth,
      env->NewStringUTF(pin.c_str()),
      (jint)timeout_sec);
}

// when a mirror session starts
void MirrorReceiver::OnMirrorStart(
    const std::string& mirror_id,
    int64_t texture_id) {
  jni::ScopedEnv env(vm_);

  env->CallVoidMethod(
      obj_,
      onMirrorStart,
      env->NewStringUTF(mirror_id.c_str()),
      texture_id);
}

// when a mirror session stops
void MirrorReceiver::OnMirrorStop(
    const std::string& mirror_id) {
  jni::ScopedEnv env(vm_);

  env->CallVoidMethod(
      obj_,
      onMirrorStop,
      env->NewStringUTF(mirror_id.c_str()));
}

// when the size of the texture changes
void MirrorReceiver::OnMirrorVideoResize(
    const std::string& mirror_id,
    int width,
    int height) {
  jni::ScopedEnv env(vm_);

  env->CallVoidMethod(
      obj_,
      onMirrorVideoResize,
      env->NewStringUTF(mirror_id.c_str()),
      width,
      height);
}

void MirrorReceiver::InitMethods(
    JNIEnv* env,
    jobject obj) {
  jclass cls = env->GetObjectClass(obj);

  // Methods of MirrorReceiver Java class

  // void OnMirrorAuth(String pin, int timeoutSec)
  DEFINE_METHOD(onMirrorAuth, "(Ljava/lang/String;I)V");
  // void onMirrorStart(String mirrorId, long textureId)
  DEFINE_METHOD(onMirrorStart, "(Ljava/lang/String;J)V");
  // void onMirrorStop(String mirrorId)
  DEFINE_METHOD(onMirrorStop, "(Ljava/lang/String;)V");

  // void onMirrorVideoResize(int mirrorId, int width, int height)
  DEFINE_METHOD(onMirrorVideoResize, "(Ljava/lang/String;II)V");
}

}  // namespace jni
