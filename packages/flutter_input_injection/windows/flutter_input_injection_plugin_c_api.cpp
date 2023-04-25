#include "include/flutter_input_injection/flutter_input_injection_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_input_injection_plugin.h"

void FlutterInputInjectionPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_input_injection::FlutterInputInjectionPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
