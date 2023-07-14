#include "util/jni/hash_map.h"
#include <assert.h>

#define DEFINE_METHOD(NAME, SIG) \
  NAME##MId = env->GetMethodID(cls, #NAME, SIG);

namespace jni {

HashMap::HashMap(JNIEnv* env)
    : env_(env),
      obj_(env) {
  assert(env);

  jclass cls = env_->FindClass("java/util/HashMap");

  InitMethods(env, cls);

  obj_.reset(env->NewObject(cls, constructorMId));
}

void HashMap::CopyFrom(
    const std::map<std::string, std::string>& m) {
  // Call HashMap.clear()
  env_->CallVoidMethod(obj_, clearMId);

  for (const auto& kv : m) {
    Put(kv.first, kv.second);
  }
}

void HashMap::Put(
    const std::string& key,
    const std::string& value) {
  jni::LocalRef<jstring> jkey(env_, env_->NewStringUTF(key.c_str()));
  jni::LocalRef<jstring> jvalue(env_, env_->NewStringUTF(value.c_str()));

  // Call HashMap.put()
  env_->CallObjectMethod(obj_, putMId, jkey.get(), jvalue.get());
}

void HashMap::InitMethods(
    JNIEnv* env,
    jclass cls) {
  DEFINE_METHOD(put, "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");
  DEFINE_METHOD(clear, "()V");

  constructorMId = env->GetMethodID(cls, "<init>", "()V");
}

}  // namespace jni
