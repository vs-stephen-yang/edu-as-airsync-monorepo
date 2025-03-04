#include "flutter_input_injection_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
#include "touch_injector_win.h"

remoting::TouchInjectorWin injector;

namespace flutter_input_injection {

// static
void FlutterInputInjectionPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "flutter_input_injection",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<FlutterInputInjectionPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FlutterInputInjectionPlugin::FlutterInputInjectionPlugin() {
  injector.Init();
}

FlutterInputInjectionPlugin::~FlutterInputInjectionPlugin() {}

void FlutterInputInjectionPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
  } else if (method_call.method_name().compare("sendNormalizedTouch") == 0) {
    const auto *arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments) {
      int action = static_cast<int>(std::get<int>((arguments->find(flutter::EncodableValue("action")))->second));
      int id = static_cast<int>(std::get<int>((arguments->find(flutter::EncodableValue("id")))->second));
      double normalizedX = static_cast<double>(std::get<double>((arguments->find(flutter::EncodableValue("x")))->second));
      double normalizedY = static_cast<double>(std::get<double>((arguments->find(flutter::EncodableValue("y")))->second));
      int screenId = static_cast<int>(std::get<int>((arguments->find(flutter::EncodableValue("screenId")))->second));
      bool autoVirtualDisplay = static_cast<bool>(std::get<bool>((arguments->find(flutter::EncodableValue("autoVirtualDisplay")))->second));
      injector.InjectNormalizedTouchEvent(screenId, autoVirtualDisplay, id, action, normalizedX, normalizedY);
      result->Success(flutter::EncodableValue(true));
    } else {
      result->Error("InvalidArgument", "Invalid argument");
    }
  } else if (method_call.method_name().compare("sendTouch") == 0) {
    const auto *arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments) {
      //const flutter::EncodableMap *argsList = std::get_if<flutter::EncodableMap>(call.arguments());
      //we will get values in pairs ie., first::"action" second::1.
      //we get the second part
      int action = static_cast<int>(std::get<int>((arguments->find(flutter::EncodableValue("action")))->second));
      int id = static_cast<int>(std::get<int>((arguments->find(flutter::EncodableValue("id")))->second));
      int x = static_cast<int>(std::get<int>((arguments->find(flutter::EncodableValue("x")))->second));
      int y = static_cast<int>(std::get<int>((arguments->find(flutter::EncodableValue("y")))->second));

      remoting::protocol::TouchEvent event;
      remoting::protocol::TouchEventPoint tp;
      tp.id_ = id % kMaxSimultaneousTouchCount;
      tp.x_ = x;
      tp.y_ = y;
      tp.angle_ = 0;

      event.event_type_ = action;
      event.points_.push_back(tp);

      injector.InjectTouchEvent(event);

      //result->Success(flutter::EncodableValue("Cpp-SendTouch-action: " + std::to_string(action) + " id: " + std::to_string(id) + " x: " + std::to_string(x) + " y: " + std::to_string(y)));
      result->Success(flutter::EncodableValue(true));
    } else {
      result->Error("InvalidArgument", "Invalid argument");
    }
  } else {
    result->NotImplemented();
  }
}

}  // namespace flutter_input_injection
