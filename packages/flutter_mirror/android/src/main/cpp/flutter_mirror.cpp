#include <assert.h>
#include <jni.h>
#include <memory>
#include <string>

#include "airplay/ap_receiver.h"
#include "googlecast/googlecast_receiver.h"
#include "miracast/miracast_receiver.h"

#include "mirror_receiver.h"

#include "jni/credentials.h"
#include "jni/miracast_receiver.h"
#include "jni/mirror_receiver.h"
#include "jni/texture_registry.h"

#include "util/jni/byte_array.h"
#include "util/jni/scoped_env.h"
#include "util/jni/string.h"
#include "util/log.h"

#define MIRROR(instance) \
  reinterpret_cast<MirrorReceiver*>(instance);

#define MIRACAST(instance) \
  reinterpret_cast<MiracastReceiver*>(instance);

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

  MirrorReceiver* receiver = MIRROR(instance);

  jni::String str(env);

  ap::AirplayReceiver::Config config;

  config.name = str.ToUtf8(jname);
  config.enable_auth = true;
  config.pin_expiry_sec = 30;

  receiver->StartAirplay(config);
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_startGooglecastNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jstring jname,
    jobject credentials) {
  assert(instance != 0);
  ALOGV("startGooglecastNative()");

  MirrorReceiver* receiver = MIRROR(instance);

  jni::String str(env);
  jni::Credentials creds(env, credentials);

  openscreen::cast::CastReceiver::Config config;

  config.friendly_name = str.ToUtf8(jname);
  config.unique_id = "id";
  config.model_name = "IFP";
  config.credentials = creds.FromJObject();

  receiver->StartGooglecast(config);
}
JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_updateGooglecastCredentialNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jobject credentials) {
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_stopMirrorNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jstring jmirror_id) {
  assert(instance != 0);
  ALOGV("stopMirrorNative()");

  MirrorReceiver* receiver = MIRROR(instance);

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

  MirrorReceiver* receiver = MIRROR(instance);
  delete receiver;
}

// MiracastReceiver
JNIEXPORT jlong JNICALL
Java_com_viewsonic_flutter_1mirror_MiracastReceiver_createInstanceNative(
    JNIEnv* env,
    jobject thiz,
    jobject jtexture_registry) {
  assert(g_vm);
  ALOGV("MiracastReceiver_createInstanceNative()");

  auto miracast_receiver = std::make_unique<jni::MiracastReceiver>(
      g_vm,
      env,
      thiz);

  auto texture_registry = std::make_unique<jni::TextureRegistry>(
      g_vm,
      env,
      jtexture_registry);

  MiracastReceiver* receiver = new MiracastReceiver(
      std::move(miracast_receiver),
      std::move(texture_registry));

  return reinterpret_cast<long>(receiver);
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MiracastReceiver_onSessionBeginNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jint sessionId) {
  assert(instance != 0);
  ALOGV("MiracastReceiver_onMirrorStartNative()");

  MiracastReceiver* receiver = MIRACAST(instance);
  receiver->OnMirrorStart(sessionId);
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MiracastReceiver_onSessionEndNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jint sessionId) {
  assert(instance != 0);
  ALOGV("MiracastReceiver_onMirrorStopNative()");

  MiracastReceiver* receiver = MIRACAST(instance);
  receiver->OnMirrorStop(sessionId);
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MiracastReceiver_onPacketNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jint sessionId,
    jbyteArray data,
    jint size) {
  assert(instance != 0);

  MiracastReceiver* receiver = MIRACAST(instance);

  jni::ScopedByteArrayBuffer ba(env, data);

  receiver->OnPacket(
      sessionId,
      reinterpret_cast<uint8_t*>(ba.Data()),
      size);
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MiracastReceiver_onAudioFormatUpdateNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jint sessionId,
    jstring codecName,
    jint sampleRate,
    jint channelCount) {
  assert(instance != 0);
  ALOGV("MiracastReceiver_onAudioFormatUpdateNative()");

  MiracastReceiver* receiver = MIRACAST(instance);

  jni::String str(env);

  receiver->OnAudioFormatUpdate(
      sessionId,
      str.ToUtf8(codecName),
      sampleRate,
      channelCount);
}
}
