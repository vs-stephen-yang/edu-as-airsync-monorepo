#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

#include "wifi_utils.cpp"
#include "time_utils.cpp"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

    flutter::MethodChannel <flutter::EncodableValue> channelAppUpdate(
            flutter_controller_->engine()->messenger(),
            "com.mvbcast.crosswalk/app_update",
            &flutter::StandardMethodCodec::GetInstance());

    channelAppUpdate.SetMethodCallHandler(
            [](const flutter::MethodCall<> &method_call,
               std::unique_ptr <flutter::MethodResult<flutter::EncodableValue>> result) {
                if (method_call.method_name().compare("getFlavor") == 0) {
                    result->Success(flutter::EncodableValue("Windows"));
                    return;
                } else {
                    result->NotImplemented();
                }
            });

    flutter::MethodChannel <flutter::EncodableValue> channelWifiSignalStrength(
            flutter_controller_->engine()->messenger(),
            "com.mvbcast.crosswalk/wifi_signal_strength",
            &flutter::StandardMethodCodec::GetInstance());

    channelWifiSignalStrength.SetMethodCallHandler(
            [](const flutter::MethodCall<> &method_call,
               std::unique_ptr <flutter::MethodResult<flutter::EncodableValue>> result) {
                if (method_call.method_name().compare("getWifiSignalStrength") == 0) {
                    int signal = GetWifiSignalStrength();
                    result->Success(flutter::EncodableValue(signal));
                    return;
                } else {
                    result->NotImplemented();
                }
            });

    flutter::MethodChannel <flutter::EncodableValue> channelWifiHelper(
            flutter_controller_->engine()->messenger(),
            "com.mvbcast.crosswalk/wifi_helper",
            &flutter::StandardMethodCodec::GetInstance());

    channelWifiHelper.SetMethodCallHandler(
            [](const flutter::MethodCall<> &method_call,
               std::unique_ptr <flutter::MethodResult<flutter::EncodableValue>> result) {
                if (method_call.method_name().compare("getFlavor") == 0) {
                    result->Success(flutter::EncodableValue("Windows"));
                    return;
                } else {
                    result->NotImplemented();
                }
            });
    // Create EventChannel
    time_channel_ = std::make_unique<
                    flutter::EventChannel<flutter::EncodableValue>>(
                    flutter_controller_->engine()->messenger(),
                    "com.mvbcast.crosswalk/time_events",
                    &flutter::StandardMethodCodec::GetInstance());
    time_channel_->SetStreamHandler(std::make_unique<TimeFormatStreamHandler>());

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
    time_channel_.reset();
    if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
