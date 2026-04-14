#include "include/flutter_mirror/flutter_mirror_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_mirror_plugin.h"

void FlutterMirrorPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_mirror::FlutterMirrorPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
