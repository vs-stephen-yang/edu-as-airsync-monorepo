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

  void onMirrorStart(int mirrorId, long textureId);

  void onMirrorVideoResize(int mirrorId, int width, int height);

  void sendIdrRequest(int mirrorId);

 private:
  void InitMethods(
      JNIEnv* env,
      jobject obj);

 private:
  jobject obj_ = nullptr;
  JavaVM* vm_ = nullptr;

  // Methods of MiracastReceiver Java class
  jmethodID onMirrorStartMID = nullptr;
  jmethodID onMirrorVideoResizeMID = nullptr;
  jmethodID sendIdrRequestMID = nullptr;
};

typedef std::unique_ptr<MiracastReceiver> MiracastReceiverPtr;

}  // namespace jni

#endif  // FLUTTER_MIRROR_PLUGIN_JNI_MIRACAST_RECEIVER_H_
