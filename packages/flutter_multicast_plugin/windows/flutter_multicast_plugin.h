#ifndef FLUTTER_PLUGIN_FLUTTER_MULTICAST_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_MULTICAST_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_multicast_plugin {

class FlutterMulticastPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterMulticastPlugin();

  virtual ~FlutterMulticastPlugin();

  // Disallow copy and assign.
  FlutterMulticastPlugin(const FlutterMulticastPlugin&) = delete;
  FlutterMulticastPlugin& operator=(const FlutterMulticastPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_multicast_plugin

#endif  // FLUTTER_PLUGIN_FLUTTER_MULTICAST_PLUGIN_H_
