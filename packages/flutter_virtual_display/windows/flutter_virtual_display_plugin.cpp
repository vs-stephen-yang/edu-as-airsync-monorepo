#include "flutter_virtual_display_plugin.h"

#include <windows.h>
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

#include "flutter_virtual_display.h"

const char* kChannelName = "flutter_virtual_display";

namespace flutter_virtual_display {

// static
void FlutterVirtualDisplayPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {

  auto messenger = registrar->messenger();

  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          messenger, kChannelName,
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<FlutterVirtualDisplayPlugin>(messenger);

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FlutterVirtualDisplayPlugin::FlutterVirtualDisplayPlugin(flutter::BinaryMessenger* messenger) {
  _flutter_virtual_display = std::make_unique<FlutterVirtualDisplay>(messenger);
}

FlutterVirtualDisplayPlugin::~FlutterVirtualDisplayPlugin() {}

void FlutterVirtualDisplayPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto method_name = method_call.method_name();
  if (method_name.compare("initialize") == 0) {
    const flutter::EncodableMap params =
      GetValue<flutter::EncodableMap>(*method_call.arguments());
    const flutter::EncodableMap options = findMap(params, "options");
    const std::string ip = findString(options, "ip");
    const int port = findInt(options, "port");
    if (!ip.empty() || port != -1) {
      result->Success(_flutter_virtual_display->Initialize(ip.c_str(), port));
    } else {
      result->Success(_flutter_virtual_display->Initialize());
    }
  } else if (method_name.compare("startVirtualDisplay") == 0) {
    int device_index = 0;
    _flutter_virtual_display->StartVirtualDisplay(device_index);
    result->Success(flutter::EncodableValue(device_index));
  } else if (method_name.compare("stopVirtualDisplay") == 0) {
    _flutter_virtual_display->StopVirtualDisplay();
    result->Success();
  }
}

}  // namespace flutter_virtual_display
