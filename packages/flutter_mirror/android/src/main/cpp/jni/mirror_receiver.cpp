#include "jni/mirror_receiver.h"
#include <assert.h>
#include "jni/service_info_proxy.h"
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

bool MirrorReceiver::OnServiceRegister(
    const ServiceInfo& info) {
  jni::ScopedEnv env(vm_);

  jni::ServiceInfoProxy jinfo(*env, info);

  jboolean result = env->CallBooleanMethod(
      obj_,
      onServiceRegister,
      jinfo.get());

  return result == JNI_TRUE;
}

bool MirrorReceiver::OnServiceUnregister(
    const std::string& service_name) {
  jni::ScopedEnv env(vm_);

  jboolean result = env->CallBooleanMethod(
      obj_,
      onServiceUnregister,
      env->NewStringUTF(service_name.c_str()));

  return result == JNI_TRUE;
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
    int64_t texture_id,
    const std::string& device_name,
    const std::string& mirror_type) {
  jni::ScopedEnv env(vm_);

  env->CallVoidMethod(
      obj_,
      onMirrorStart,
      env->NewStringUTF(mirror_id.c_str()),
      texture_id,
      env->NewStringUTF(device_name.c_str()),
      env->NewStringUTF(mirror_type.c_str()));
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

void MirrorReceiver::OnMirrorVideoFrameRate(
    const std::string& mirror_id,
    int fps) {
  jni::ScopedEnv env(vm_);

  env->CallVoidMethod(
      obj_,
      onMirrorVideoFrameRate,
      env->NewStringUTF(mirror_id.c_str()),
      fps);
}

void MirrorReceiver::OnCredentialsRequest(
    int year,
    int month,
    int day) {
  jni::ScopedEnv env(vm_);

  env->CallVoidMethod(
      obj_,
      onCredentialsRequest,
      year,
      month,
      day);
}

void MirrorReceiver::InitMethods(
    JNIEnv* env,
    jobject obj) {
  jclass cls = env->GetObjectClass(obj);

  // Methods of MirrorReceiver Java class

  // void onServiceRegister(ServiceInfo info)
  DEFINE_METHOD(onServiceRegister, "(Lcom/viewsonic/flutter_mirror/ServiceInfo;)Z");

  // void onServiceUnregister(String info)
  DEFINE_METHOD(onServiceUnregister, "(Ljava/lang/String;)Z");

  // void OnMirrorAuth(String pin, int timeoutSec)
  DEFINE_METHOD(onMirrorAuth, "(Ljava/lang/String;I)V");
  // void onMirrorStart(String mirrorId, long textureId, String deviceName, String mirrorType)
  DEFINE_METHOD(onMirrorStart, "(Ljava/lang/String;JLjava/lang/String;Ljava/lang/String;)V");
  // void onMirrorStop(String mirrorId)
  DEFINE_METHOD(onMirrorStop, "(Ljava/lang/String;)V");

  // void onMirrorVideoResize(int mirrorId, int width, int height)
  DEFINE_METHOD(onMirrorVideoResize, "(Ljava/lang/String;II)V");

  // void onMirrorVideoFrameRate(int mirrorId, int fps)
  DEFINE_METHOD(onMirrorVideoFrameRate, "(Ljava/lang/String;I)V");

  // void onCredentialsRequest(int year, int month, int day)
  DEFINE_METHOD(onCredentialsRequest, "(III)V");
}

}  // namespace jni
