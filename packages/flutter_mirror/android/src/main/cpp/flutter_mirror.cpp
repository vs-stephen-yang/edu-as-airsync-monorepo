#include <assert.h>
#include <jni.h>
#include <memory>
#include <string>

#include "airplay/ap_receiver.h"
#include "jni/mirror_receiver.h"
#include "jni/texture_registry.h"
#include "mirror_receiver.h"
#include "util/jni/scoped_env.h"
#include "util/jni/string.h"
#include "util/log.h"

#define CAST(instance) \
  reinterpret_cast<MirrorReceiver*>(instance);

JavaVM* g_vm = nullptr;

extern "C" {

JNIEXPORT jint JNICALL
JNI_OnLoad(JavaVM* vm, void* reserved) {
  ALOGV("JNI_OnLoad()");

  g_vm = vm;
  return JNI_VERSION_1_4;
}

JNIEXPORT jlong JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_createInstanceNative(
    JNIEnv* env,
    jobject thiz,
    jobject jtexture_registry) {
  assert(g_vm);
  ALOGV("createInstanceNative()");

  auto mirror_receiver = std::make_unique<jni::MirrorReceiver>(
      g_vm,
      env,
      thiz);

  auto texture_registry = std::make_unique<jni::TextureRegistry>(
      g_vm,
      env,
      jtexture_registry);

  MirrorReceiver* receiver = new MirrorReceiver(
      std::move(mirror_receiver),
      std::move(texture_registry));

  return reinterpret_cast<long>(receiver);
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_startAirplayNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jstring jname) {
  assert(instance != 0);
  ALOGV("startAirplayNative()");

  MirrorReceiver* receiver = CAST(instance);

  jni::String str(env);

  ap::AirplayReceiver::Config config;

  config.name = str.ToUtf8(jname);
  config.enable_auth = true;
  config.pin_expiry_sec = 30;

  receiver->StartAirplay(config);
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_stopMirrorNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jstring jmirror_id) {
  assert(instance != 0);
  ALOGV("stopMirrorNative()");

  MirrorReceiver* receiver = CAST(instance);

  jni::String str(env);
  receiver->StopMirror(
      str.ToUtf8(jmirror_id));
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_destroyInstanceNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance) {
  assert(instance != 0);
  ALOGV("destroyInstanceNative()");

  MirrorReceiver* receiver = CAST(instance);
  delete receiver;
}
}
