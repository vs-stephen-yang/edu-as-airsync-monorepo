#ifndef FLUTTER_MIRROR_PLUGIN_STRING_H_
#define FLUTTER_MIRROR_PLUGIN_STRING_H_

#include <jni.h>
#include <string>

namespace jni {

class String {
 public:
  String(JNIEnv* env);

  jstring NewString(const std::string& str) const;

  std::string ToUtf8(jstring str) const;

 private:
  JNIEnv* env_ = nullptr;
  jclass class_;
  jmethodID method_getBytes_;
};

}  // namespace jni

#endif  // FLUTTER_MIRROR_PLUGIN_STRING_H_
