//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <device_info_vs/device_info_vs_plugin.h>
#include <flutter_mirror/flutter_mirror_plugin_c_api.h>
#include <flutter_webrtc/flutter_web_r_t_c_plugin.h>
#include <permission_handler_windows/permission_handler_windows_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  DeviceInfoVsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DeviceInfoVsPlugin"));
  FlutterMirrorPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterMirrorPluginCApi"));
  FlutterWebRTCPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterWebRTCPlugin"));
  PermissionHandlerWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PermissionHandlerWindowsPlugin"));
}
