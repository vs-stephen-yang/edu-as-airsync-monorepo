#include "jni/service_info_proxy.h"
#include <assert.h>
#include "util/jni/hash_map.h"
#include "util/jni/string.h"

#define DEFINE_FIELD(NAME, SIG) \
  NAME##FId = env->GetFieldID(cls, #NAME, SIG);

#define SET_FIELD(NAME, VALUE) \
  env_->SetObjectField(obj_, NAME##FId, VALUE);

#define SET_FIELD_INT(NAME, VALUE) \
  env_->SetIntField(obj_, NAME##FId, VALUE);

namespace jni {

ServiceInfoProxy::ServiceInfoProxy(
    JNIEnv* env,
    const ServiceInfo& info)
    : env_(env),
      obj_(env) {
  assert(env);

  jclass cls = env->FindClass("com/viewsonic/flutter_mirror/ServiceInfo");

  InitMethods(env, cls);

  // create a java object
  obj_.reset(env->NewObject(cls, constructorMId));

  CopyFrom(info);
}

void ServiceInfoProxy::CopyFrom(const ServiceInfo& info) {
  SET_FIELD_INT(port, info.port);

  jni::String jstr(env_);

  SET_FIELD(serviceName, jstr.NewString(info.service_name));
  SET_FIELD(serviceType, jstr.NewString(info.service_type));

  jni::HashMap jattributes(env_);
  jattributes.CopyFrom(info.attributes);

  SET_FIELD(attributes, jattributes.get());
}

jobject ServiceInfoProxy::get() {
  return obj_;
}

void ServiceInfoProxy::InitMethods(
    JNIEnv* env,
    jclass cls) {
  constructorMId = env->GetMethodID(cls, "<init>", "()V");

  DEFINE_FIELD(port, "I");
  DEFINE_FIELD(serviceName, "Ljava/lang/String;");
  DEFINE_FIELD(serviceType, "Ljava/lang/String;");
  DEFINE_FIELD(attributes, "Ljava/util/Map;");
}

}  // namespace jni
