#include "util/jni/scoped_env.h"
#include <assert.h>

namespace jni {

ScopedEnv::ScopedEnv(JavaVM* vm)
    : vm_(vm) {
  // TODO: specify appropriate jni version
  vm->GetEnv((void**)&env_, JNI_VERSION_1_4);

  if (env_ != nullptr) {
    // the current thread is already attached to the JVM
    detach_ = false;
  } else {
    jint ret = vm->AttachCurrentThread(&env_, NULL);
    assert(ret == JNI_OK);

    detach_ = true;
  }
}

ScopedEnv::~ScopedEnv() {
  if (detach_) {
    vm_->DetachCurrentThread();
  }
}

}  // namespace jni
