
#include "util/jni/string.h"
#include "util/jni/local_ref.h"

namespace jni {

String::String(JNIEnv* env)
    : env_(env) {
  class_ = env_->FindClass("java/lang/String");
  method_getBytes_ = env_->GetMethodID(class_, "getBytes", "(Ljava/lang/String;)[B");
}

jstring String::NewString(const std::string& str) const {
  return env_->NewStringUTF(str.c_str());
}

std::string String::ToUtf8(jstring str) const {
  if (str == nullptr) {
    return std::string();
  }

  jni::LocalRef<jstring> charset_name(
      env_,
      env_->NewStringUTF("UTF-8"));

  jni::LocalRef<jbyteArray> byte_array(
      env_,
      env_->CallObjectMethod(
          str,
          method_getBytes_,
          charset_name.get()));

  jsize len = env_->GetArrayLength(byte_array);
  if (len <= 0) {
    return std::string();
  }

  jbyte* bytes = env_->GetByteArrayElements(byte_array, NULL);

  std::string result(reinterpret_cast<char*>(bytes), len);
  env_->ReleaseByteArrayElements(byte_array, bytes, JNI_ABORT);

  return result;
}

}  // namespace jni
