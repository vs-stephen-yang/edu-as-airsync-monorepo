#ifndef FLUTTER_MIRROR_PLUGIN_SURFACE_TEXTURE_H_
#define FLUTTER_MIRROR_PLUGIN_SURFACE_TEXTURE_H_

#include <android/native_window_jni.h>
#include <stdint.h>

struct SurfaceTexture {
  int64_t id = 0;
  ANativeWindow* wnd = nullptr;
};

#endif  // FLUTTER_MIRROR_PLUGIN_SURFACE_TEXTURE_H_
