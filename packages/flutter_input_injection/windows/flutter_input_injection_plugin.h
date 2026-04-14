#ifndef FLUTTER_PLUGIN_FLUTTER_INPUT_INJECTION_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_INPUT_INJECTION_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_input_injection {

class FlutterInputInjectionPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);
  static const int kMaxSimultaneousTouchCount = 255;

  FlutterInputInjectionPlugin();

  virtual ~FlutterInputInjectionPlugin();

  // Disallow copy and assign.
  FlutterInputInjectionPlugin(const FlutterInputInjectionPlugin&) = delete;
  FlutterInputInjectionPlugin& operator=(const FlutterInputInjectionPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_input_injection

#endif  // FLUTTER_PLUGIN_FLUTTER_INPUT_INJECTION_PLUGIN_H_
