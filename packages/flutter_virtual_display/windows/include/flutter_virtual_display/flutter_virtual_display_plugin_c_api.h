#ifndef FLUTTER_PLUGIN_FLUTTER_VIRTUAL_DISPLAY_PLUGIN_C_API_H
#define FLUTTER_PLUGIN_FLUTTER_VIRTUAL_DISPLAY_PLUGIN_C_API_H

#include <flutter_plugin_registrar.h>

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

FLUTTER_PLUGIN_EXPORT void FlutterVirtualDisplayPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // FLUTTER_PLUGIN_FLUTTER_VIRTUAL_DISPLAY_PLUGIN_C_API_H
