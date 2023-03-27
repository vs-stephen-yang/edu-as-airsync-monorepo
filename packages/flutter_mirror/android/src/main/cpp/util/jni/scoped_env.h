#ifndef FLUTTER_MIRROR_PLUGIN_SCOPED_ENV_H_
#define FLUTTER_MIRROR_PLUGIN_SCOPED_ENV_H_

#include <jni.h>

namespace jni {

class ScopedEnv {
 public:
  ScopedEnv(JavaVM* vm);
  ~ScopedEnv();

  JNIEnv* operator->() const {
    return env_;
  }

  JNIEnv* operator*() const {
    return env_;
  }

 private:
  JavaVM* vm_ = nullptr;
  JNIEnv* env_ = nullptr;
  bool detach_ = false;
};

}  // namespace jni

#endif  // FLUTTER_MIRROR_PLUGIN_SCOPED_ENV_H_
