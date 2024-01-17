//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <connectivity_plus/connectivity_plus_windows_plugin.h>
#include <device_info_vs/device_info_vs_plugin.h>
#include <flutter_input_injection/flutter_input_injection_plugin_c_api.h>
#include <flutter_mirror/flutter_mirror_plugin_c_api.h>
#include <flutter_webrtc/flutter_web_r_t_c_plugin.h>
#include <network_info_plus_windows/network_info_plus_windows_plugin.h>
#include <permission_handler_windows/permission_handler_windows_plugin.h>
#include <window_size/window_size_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  ConnectivityPlusWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ConnectivityPlusWindowsPlugin"));
  DeviceInfoVsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DeviceInfoVsPlugin"));
  FlutterInputInjectionPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterInputInjectionPluginCApi"));
  FlutterMirrorPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterMirrorPluginCApi"));
  FlutterWebRTCPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterWebRTCPlugin"));
  NetworkInfoPlusWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("NetworkInfoPlusWindowsPlugin"));
  PermissionHandlerWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PermissionHandlerWindowsPlugin"));
  WindowSizePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowSizePlugin"));
}
