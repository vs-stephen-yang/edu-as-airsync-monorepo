#ifndef FLUTTER_MIRROR_PLUGIN_JNI_MIRROR_RECEIVER_H_
#define FLUTTER_MIRROR_PLUGIN_JNI_MIRROR_RECEIVER_H_

#include <jni.h>
#include <memory>
#include "service_info.h"

namespace jni {

class MirrorReceiver {
 public:
  MirrorReceiver(
      JavaVM* vm,
      JNIEnv* env,
      jobject obj);

  ~MirrorReceiver();

  bool OnServiceRegister(
      const ServiceInfo& info);

  bool OnServiceUnregister(
      const std::string& service_name);

  // when requesting auth
  void OnMirrorAuth(
      const std::string& pin,
      unsigned int timeout_sec);

  // when a mirror session starts
  void OnMirrorStart(
      const std::string& mirror_id,
      int64_t texture_id,
      const std::string& device_name,
      const std::string& mirror_type);

  // when a mirror session stops
  void OnMirrorStop(
      const std::string& mirror_id);

  // when the size of the texture changes
  void OnMirrorVideoResize(
      const std::string& mirror_id,
      int width,
      int height);

  void OnMirrorVideoFrameRate(
      const std::string& mirror_id,
      int fps);

  void OnCredentialsRequest(
      int year,
      int month,
      int day);

 private:
  void InitMethods(
      JNIEnv* env,
      jobject obj);

 private:
  jobject obj_ = nullptr;
  JavaVM* vm_ = nullptr;

  // Methods of MirrorReceiver Java class
  jmethodID onServiceRegister = nullptr;
  jmethodID onServiceUnregister = nullptr;
  jmethodID onMirrorAuth = nullptr;
  jmethodID onMirrorStart = nullptr;
  jmethodID onMirrorStop = nullptr;

  jmethodID onMirrorVideoResize = nullptr;
  jmethodID onMirrorVideoFrameRate = nullptr;

  jmethodID onCredentialsRequest = nullptr;
};

typedef std::unique_ptr<MirrorReceiver> MirrorReceiverPtr;

}  // namespace jni

#endif  // FLUTTER_MIRROR_PLUGIN_JNI_MIRROR_RECEIVER_H_
