#include "flutter_window.h"

#include <optional>
#include <wtsapi32.h>
#pragma comment(lib, "wtsapi32.lib")

#include "flutter/generated_plugin_registrant.h"
#include "desktop_multi_window/desktop_multi_window_plugin.h"
#include "system_tray/system_tray_plugin.h"
#include "custom_channel.cpp"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {
    if (power_notification_handle_) {
        // Unregister the power notification.
        UnregisterPowerSettingNotification(power_notification_handle_);
    }
    // Unregister the session notification.
    WTSUnRegisterSessionNotification(GetHandle());
}

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
  DesktopMultiWindowSetWindowCreatedCallback([](void *controller) {
      auto *flutter_view_controller =
              reinterpret_cast<flutter::FlutterViewController *>(controller);
      auto *registry = flutter_view_controller->engine();
      SystemTrayPluginRegisterWithRegistrar(
              registry->GetRegistrarForPlugin("SystemTrayPlugin"));
  });

  flutter::FlutterEngine *newEngine  = flutter_controller_->engine();
  custom_channels::minimizeWindow x = custom_channels::minimizeWindow(newEngine);
  custom_channels::debugChannel dbg = custom_channels::debugChannel(newEngine);

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  // Register for power notifications and session notifications.
  power_notification_handle_ = RegisterPowerSettingNotification(GetHandle(), &GUID_CONSOLE_DISPLAY_STATE, DEVICE_NOTIFY_WINDOW_HANDLE);

  // Register for session notifications.
  WTSRegisterSessionNotification(GetHandle(), NOTIFY_FOR_THIS_SESSION);

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
