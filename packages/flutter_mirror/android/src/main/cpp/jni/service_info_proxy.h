#ifndef FLUTTER_MIRROR_PLUGIN_JNI_SERVICE_INFO_H_
#define FLUTTER_MIRROR_PLUGIN_JNI_SERVICE_INFO_H_

#include <jni.h>
#include <memory>
#include "service_info.h"
#include "util/jni/local_ref.h"

namespace jni {

class ServiceInfoProxy {
 public:
  ServiceInfoProxy(
      JNIEnv* env,
      const ServiceInfo& info);

  void CopyFrom(const ServiceInfo& info);

  jobject get();

 private:
  void InitMethods(
      JNIEnv* env,
      jclass cls);

 private:
  JNIEnv* env_ = nullptr;
  jni::LocalRef<jobject> obj_;

  // methods and fields
  jmethodID constructorMId = nullptr;

  jfieldID portFId = nullptr;
  jfieldID serviceNameFId = nullptr;
  jfieldID serviceTypeFId = nullptr;
  jfieldID attributesFId = nullptr;
};

}  // namespace jni

#endif  // FLUTTER_MIRROR_PLUGIN_JNI_SERVICE_INFO_H_
