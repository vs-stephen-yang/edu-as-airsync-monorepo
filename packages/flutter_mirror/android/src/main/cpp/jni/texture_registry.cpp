#include "texture_registry.h"

#include <assert.h>
#include <memory>
#include "util/jni/scoped_env.h"
#include "util/log.h"

#define DEFINE_METHOD(NAME, SIG) \
  NAME = env->GetMethodID(cls, #NAME, SIG);

namespace jni {

TextureRegistry::TextureRegistry(
    JavaVM* vm,
    JNIEnv* env,
    jobject obj)
    : vm_(vm) {
  assert(vm != nullptr);
  assert(env != nullptr);
  assert(obj != nullptr);

  ALOGV("TextureRegistry()");

  obj_ = env->NewGlobalRef(obj);
  assert(obj_ != nullptr);

  InitMethods(env, obj);
}

TextureRegistry::~TextureRegistry() {
  ALOGV("~TextureRegistry()");

  jni::ScopedEnv env(vm_);

  env->DeleteGlobalRef(obj_);
}

// create a surface
SurfaceTexture TextureRegistry::CreateSurfaceTexture() {
  ALOGI("Creating a surface texture");

  jni::ScopedEnv env(vm_);

  jlong texture_id = env->CallLongMethod(
      obj_,
      createSurfaceTexture);

  jobject surface = env->CallObjectMethod(
      obj_,
      getSurfaceTexture,
      texture_id);
  assert(surface);

  // This acquires a reference on the ANativeWindow that is returned;
  // be sure to use ANativeWindow_release() when done with it so that it doesn't leak.
  ANativeWindow* wnd = ANativeWindow_fromSurface(*env, surface);
  assert(wnd);

  return SurfaceTexture{
      texture_id,
      wnd};
}

// release a surface
void TextureRegistry::ReleaseSurfaceTexture(
    const SurfaceTexture& texture) {
  assert(texture.wnd);
  ALOGI("Releasing a surface texture");

  // Remove a reference that was previously acquired with ANativeWindow_acquire().
  ANativeWindow_release(texture.wnd);

  jni::ScopedEnv env(vm_);
  env->CallVoidMethod(
      obj_,
      releaseSurfaceTexture,
      texture.id);
}

void TextureRegistry::InitMethods(
    JNIEnv* env,
    jobject obj) {
  assert(env);
  assert(obj);

  jclass cls = env->GetObjectClass(obj);

  // Methods of TextureRegistry class

  // long createSurfaceTexture()
  DEFINE_METHOD(createSurfaceTexture, "()J");
  // Surface getSurfaceTexture(long textureId)
  DEFINE_METHOD(getSurfaceTexture, "(J)Landroid/view/Surface;");
  // void releaseSurfaceTexture(long textureId)
  DEFINE_METHOD(releaseSurfaceTexture, "(J)V");
}

}  // namespace jni
