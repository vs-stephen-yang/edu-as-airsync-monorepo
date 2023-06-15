#ifndef FLUTTER_MIRROR_PLUGIN_JNI_MIRACAST_RECEIVER_H_
#define FLUTTER_MIRROR_PLUGIN_JNI_MIRACAST_RECEIVER_H_

#include <jni.h>
#include <memory>

namespace jni {

class MiracastReceiver {
 public:
  MiracastReceiver(
      JavaVM* vm,
      JNIEnv* env,
      jobject obj);

  ~MiracastReceiver();

  void StopMirror(const std::string& mirrorId);

  void sendIdrRequest(const std::string& mirrorId);

 private:
  void InitMethods(
      JNIEnv* env,
      jobject obj);

 private:
  jobject obj_ = nullptr;
  JavaVM* vm_ = nullptr;

  // Methods of MiracastReceiver Java class
  jmethodID sendIdrRequestMID = nullptr;
  jmethodID stopMirrorMID = nullptr;
};

typedef std::unique_ptr<MiracastReceiver> MiracastReceiverPtr;

}  // namespace jni

#endif  // FLUTTER_MIRROR_PLUGIN_JNI_MIRACAST_RECEIVER_H_
