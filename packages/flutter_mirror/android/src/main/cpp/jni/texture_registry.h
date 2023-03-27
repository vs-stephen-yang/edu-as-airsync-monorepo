#ifndef FLUTTER_MIRROR_PLUGIN_JNI_TEXTURE_REGISTRY_H_
#define FLUTTER_MIRROR_PLUGIN_JNI_TEXTURE_REGISTRY_H_

#include <android/native_window_jni.h>
#include <jni.h>
#include <memory>
#include "media/surface_texture.h"

namespace jni {

class TextureRegistry {
 public:
  TextureRegistry(
      JavaVM* vm,
      JNIEnv* env,
      jobject obj);

  ~TextureRegistry();

  // create a surface
  SurfaceTexture CreateSurfaceTexture();

  // release a surface
  void ReleaseSurfaceTexture(const SurfaceTexture& texture);

 private:
  void InitMethods(
      JNIEnv* env,
      jobject obj);

 private:
  JavaVM* vm_ = nullptr;
  jobject obj_ = nullptr;

 private:
  // Methods of FlutterGooglecastPlugin Java class
  jmethodID createSurfaceTexture = nullptr;
  jmethodID getSurfaceTexture = nullptr;
  jmethodID releaseSurfaceTexture = nullptr;
};
typedef std::unique_ptr<TextureRegistry> TextureRegistryPtr;

}  // namespace jni

#endif  // FLUTTER_MIRROR_PLUGIN_JNI_TEXTURE_REGISTRY_H_
