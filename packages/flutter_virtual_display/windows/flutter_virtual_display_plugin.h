#ifndef FLUTTER_PLUGIN_FLUTTER_VIRTUAL_DISPLAY_PLUGIN_H
#define FLUTTER_PLUGIN_FLUTTER_VIRTUAL_DISPLAY_PLUGIN_H

#include <memory>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include "flutter_common.h"

namespace flutter_virtual_display {

class FlutterVirtualDisplay;

class FlutterVirtualDisplayPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterVirtualDisplayPlugin(flutter::BinaryMessenger* messenger);

  virtual ~FlutterVirtualDisplayPlugin();

  FlutterVirtualDisplayPlugin(const FlutterVirtualDisplayPlugin&) = delete;
  FlutterVirtualDisplayPlugin& operator=(const FlutterVirtualDisplayPlugin&) = delete;

  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

 private:
  std::unique_ptr<FlutterVirtualDisplay> _flutter_virtual_display;
};

}  // namespace flutter_virtual_display

#endif  // FLUTTER_PLUGIN_FLUTTER_VIRTUAL_DISPLAY_PLUGIN_H
