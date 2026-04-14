#include "include/flutter_multicast_plugin/flutter_multicast_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_multicast_plugin.h"

void FlutterMulticastPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_multicast_plugin::FlutterMulticastPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
