#ifndef FLUTTER_MIRROR_PLUGIN_HASH_MAP_H_
#define FLUTTER_MIRROR_PLUGIN_HASH_MAP_H_

#include <jni.h>
#include <map>
#include <string>
#include "util/jni/local_ref.h"

namespace jni {

class HashMap {
 public:
  HashMap(JNIEnv* env);

  void CopyFrom(
      const std::map<std::string, std::string>& m);

  void Put(
      const std::string& key,
      const std::string& value);

  jobject get() {
    return obj_;
  }

 private:
  void InitMethods(
      JNIEnv* env,
      jclass cls);

 private:
  JNIEnv* env_ = nullptr;

  jni::LocalRef<jobject> obj_;

  // method ID
  jmethodID constructorMId;
  jmethodID putMId;
  jmethodID clearMId;
};

}  // namespace jni

#endif  // FLUTTER_MIRROR_PLUGIN_HASH_MAP_H_
