#include "include/flutter_virtual_display/flutter_virtual_display_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_virtual_display_plugin.h"

void FlutterVirtualDisplayPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_virtual_display::FlutterVirtualDisplayPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
