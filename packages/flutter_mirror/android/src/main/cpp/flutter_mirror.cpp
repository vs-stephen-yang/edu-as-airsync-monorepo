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
#include "util/jni/map_utils.h"
#include "util/jni/scoped_env.h"
#include "util/jni/string.h"
#include "util/log.h"

#define MIRROR(instance) \
  reinterpret_cast<MirrorReceiver*>(instance);

#define MIRACAST(instance) \
  reinterpret_cast<MiracastReceiver*>(instance);

struct AirplaySecurity {
  static const std::string kNone;
  static const std::string kOnscreenCode;
  static const std::string kPassword;
};

// the values must be same with the ones defined in lib\airplay_config.dart
const std::string AirplaySecurity::kNone("none");
const std::string AirplaySecurity::kOnscreenCode("onscreenCode");
const std::string AirplaySecurity::kPassword("password");

const unsigned int kAirplayPinExpirySec = 40;

JavaVM* g_vm = nullptr;

extern "C" {

JNIEXPORT jint JNICALL
JNI_OnLoad(JavaVM* vm, void* reserved) {
  ALOGV("JNI_OnLoad()");

  g_vm = vm;

  MirrorReceiver::InitializeOnce();

  return JNI_VERSION_1_4;
}

JNIEXPORT jlong JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_createInstanceNative(
    JNIEnv* env,
    jobject thiz,
    jobject jtexture_registry,
    jobject additional_codec_params) {
  assert(g_vm);
  ALOGV("MirrorReceiver_createInstanceNative()");

  std::map<std::string, int> codec_params;
  if (additional_codec_params != nullptr) {
    codec_params = jni::MapUtils::toStdMap(env, additional_codec_params);
  }

  auto proxy = std::make_unique<jni::MirrorReceiver>(
      g_vm,
      env,
      thiz);

  auto texture_registry = std::make_unique<jni::TextureRegistry>(
      g_vm,
      env,
      jtexture_registry);

  MirrorReceiver* receiver = new MirrorReceiver(
      std::move(proxy),
      std::move(texture_registry),
      std::move(codec_params));

  return reinterpret_cast<long>(receiver);
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_enableDumpNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jstring jdump_path) {
  assert(instance != 0);
  ALOGV("MirrorReceiver_enableDumpNative()");
  MirrorReceiver* receiver = MIRROR(instance);

  jni::String str(env);

  std::string dump_path = str.ToUtf8(jdump_path);

  receiver->EnableDump(dump_path);
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_startMirrorReplayNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jstring jmirror_id,
    jstring jvideo_codec,
    jstring jvideo_path) {
  assert(instance != 0);
  ALOGV("MirrorReceiver_startMirrorReplayNative()");
  MirrorReceiver* receiver = MIRROR(instance);

  jni::String str(env);

  std::string mirror_id = str.ToUtf8(jmirror_id);
  std::string video_codec = str.ToUtf8(jvideo_codec);
  std::string video_path = str.ToUtf8(jvideo_path);

  receiver->StartMirrorReplay(mirror_id, video_codec, video_path);
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_startAirplayNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jstring jname,
    jstring jdevice_id,
    jstring jsecurity,
    jobject jairPlayResolutionMap){
  assert(instance != 0);
  ALOGV("MirrorReceiver_startAirplayNative()");

  MirrorReceiver* receiver = MIRROR(instance);

  jni::String str(env);

  ap::AirplayReceiver::Config config;

  std::string security = str.ToUtf8(jsecurity);

  config.name = str.ToUtf8(jname);
  config.device_id = str.ToUtf8(jdevice_id);
  config.enable_auth = (security == AirplaySecurity::kOnscreenCode);
  config.pin_expiry_sec = kAirplayPinExpirySec;
  config.use_external_dnssd = true;

  auto resolutionMap = jni::MapUtils::toStdMapOfPair(env, jairPlayResolutionMap);
  config.airplay_resolution_map = std::move(resolutionMap);

  receiver->StartAirplay(config);
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_stopAirplayNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance) {
  assert(instance != 0);
  ALOGV("MirrorReceiver_stopAirplayNative()");

  MirrorReceiver* receiver = MIRROR(instance);

  receiver->StopAirplay();
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_startGooglecastNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jstring jname,
    jstring junique_id,
    jobject credentials) {
  assert(instance != 0);
  ALOGV("MirrorReceiver_startGooglecastNative()");

  MirrorReceiver* receiver = MIRROR(instance);

  jni::String str(env);
  jni::Credentials creds(env, credentials);

  openscreen::cast::CastReceiver::Config config;

  config.friendly_name = str.ToUtf8(jname);
  config.unique_id = str.ToUtf8(junique_id);
  config.model_name = "IFP";
  config.credentials = creds.FromJObject();
  config.use_external_dnssd = true;

  receiver->StartGooglecast(config);
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_stopGooglecastNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance) {
  assert(instance != 0);
  ALOGV("MirrorReceiver_stopGooglecastNative()");

  MirrorReceiver* receiver = MIRROR(instance);

  receiver->StopGooglecast();
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_updateGooglecastCredentialNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jobject credentials) {
  assert(instance != 0);
  assert(credentials != nullptr);
  ALOGV("MirrorReceiver_updateGooglecastCredentialNative()");

  MirrorReceiver* receiver = MIRROR(instance);

  jni::Credentials creds(env, credentials);

  receiver->UpdateGooglecastCredentials(
      creds.FromJObject());
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_enableAudioNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jstring jmirror_id,
    jboolean enable) {
  assert(instance != 0);
  ALOGV("MirrorReceiver_enableAudioNative()");

  MirrorReceiver* receiver = MIRROR(instance);

  jni::String str(env);

  receiver->EnableAudio(
      str.ToUtf8(jmirror_id),
      enable == JNI_TRUE);
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_stopMirrorNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jstring jmirror_id) {
  assert(instance != 0);
  ALOGV("MirrorReceiver_stopMirrorNative()");

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

JNIEXPORT jboolean JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_isAirplayServiceRunningNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance) {
  assert(instance != 0);
  ALOGV("MirrorReceiver_isAirplayServiceRunningNative()");

  MirrorReceiver* receiver = MIRROR(instance);
  bool is_running = receiver->IsAirplayServiceRunning();

  return is_running ? JNI_TRUE : JNI_FALSE;
}

JNIEXPORT jboolean JNICALL
Java_com_viewsonic_flutter_1mirror_MirrorReceiver_isGooglecastServiceRunningNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance) {
  assert(instance != 0);
  ALOGV("MirrorReceiver_isGooglecastServiceRunningNative()");

  MirrorReceiver* receiver = MIRROR(instance);
  bool is_running = receiver->IsGooglecastServiceRunning();

  return is_running ? JNI_TRUE : JNI_FALSE;
}

// MiracastReceiver
JNIEXPORT jlong JNICALL
Java_com_viewsonic_flutter_1mirror_MiracastReceiver_createInstanceNative(
    JNIEnv* env,
    jobject thiz,
    jlong mirror_listener_instance) {
  assert(g_vm);
  assert(mirror_listener_instance);
  ALOGV("MiracastReceiver_createInstanceNative()");

  auto proxy = std::make_unique<jni::MiracastReceiver>(
      g_vm,
      env,
      thiz);

  MirrorListener* mirror_listener =
      reinterpret_cast<MirrorListener*>(mirror_listener_instance);

  MiracastReceiver* receiver = new MiracastReceiver(
      std::move(proxy),
      *mirror_listener);

  return reinterpret_cast<long>(receiver);
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MiracastReceiver_onSessionBeginNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jstring jmirror_id,
    jstring jdevice_name) {
  assert(instance != 0);
  ALOGV("MiracastReceiver_onSessionBeginNative()");

  MiracastReceiver* receiver = MIRACAST(instance);
  jni::String str(env);
  receiver->OnMirrorStart(
      str.ToUtf8(jmirror_id),
      str.ToUtf8(jdevice_name));
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MiracastReceiver_onSessionEndNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jstring jmirror_id) {
  assert(instance != 0);
  ALOGV("MiracastReceiver_onSessionEndNative()");

  MiracastReceiver* receiver = MIRACAST(instance);
  jni::String str(env);
  receiver->OnMirrorStop(str.ToUtf8(jmirror_id));
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MiracastReceiver_onPacketNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jstring jmirror_id,
    jbyteArray data,
    jint size) {
  assert(instance != 0);

  MiracastReceiver* receiver = MIRACAST(instance);

  jni::ScopedByteArrayBuffer ba(env, data);
  jni::String str(env);
  receiver->OnPacket(
      str.ToUtf8(jmirror_id),
      reinterpret_cast<uint8_t*>(ba.Data()),
      size);
}

JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1mirror_MiracastReceiver_onAudioFormatUpdateNative(
    JNIEnv* env,
    jobject thiz,
    jlong instance,
    jstring jmirror_id,
    jstring codecName,
    jint sampleRate,
    jint channelCount) {
  assert(instance != 0);
  ALOGV("MiracastReceiver_onAudioFormatUpdateNative()");

  MiracastReceiver* receiver = MIRACAST(instance);

  jni::String str(env);

  receiver->OnAudioFormatUpdate(
      str.ToUtf8(jmirror_id),
      str.ToUtf8(codecName),
      sampleRate,
      channelCount);
}
}
