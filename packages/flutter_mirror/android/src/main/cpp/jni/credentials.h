#ifndef FLUTTER_MIRROR_PLUGIN_JNI_CREDENTIALS_H_
#define FLUTTER_MIRROR_PLUGIN_JNI_CREDENTIALS_H_

#include <jni.h>
#include <string>
#include "./cast/cast_receiver.h"

namespace jni {

// Googlecast's credentials for device authentication
class Credentials {
 public:
  Credentials(
      JNIEnv* env,
      jobject obj);

  openscreen::cast::CastReceiver::Credentials FromJObject() const;

 private:
  void InitFields();

  // Get the byte array field and convert to std::string
  std::string GetBaField(jfieldID fid) const;

  jint GetIntField(jfieldID fid) const;

 private:
  JNIEnv* env_ = nullptr;
  jobject obj_ = nullptr;

  jfieldID yearId = nullptr;
  jfieldID monthId = nullptr;
  jfieldID dayId = nullptr;
  jfieldID deviceCertDerId = nullptr;
  jfieldID icaCertDerId = nullptr;
  jfieldID tlsCertDerId = nullptr;
  jfieldID tlsKeyDerId = nullptr;
  jfieldID signatureId = nullptr;
};

}  // namespace jni

#endif  // FLUTTER_MIRROR_PLUGIN_JNI_CREDENTIALS_H_
