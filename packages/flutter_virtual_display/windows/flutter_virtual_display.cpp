#include "flutter_virtual_display.h"

#include <string>

#include <flutter/standard_message_codec.h>
#include <flutter/standard_method_codec.h>
#include <flutter/event_stream_handler_functions.h>
#include "virtual_display_client/sn_client.h"
#include "virtual_display_client/win32_utils.h"

#define UNSUPPORTED_WINDOWS_VERSION_ERROR_MESSAGE \
  "Unsupported Windows version. Windows 10 version 1709 or above is required."

using namespace virtual_display_client;

namespace flutter_virtual_display {

const char* kEventChannelName = "FlutterVirtualDisplay.Event";

FlutterVirtualDisplay::FlutterVirtualDisplay(flutter::BinaryMessenger* messenger)
    : messenger_(messenger) {
  sn_client_ = std::make_unique<SNClient>();
  event_channel_ = EventChannelProxy::Create(messenger, kEventChannelName);
}

FlutterVirtualDisplay::~FlutterVirtualDisplay() {}

bool FlutterVirtualDisplay::IsSupported() {
  return Win32Utils::IsWindows10Version1709OrAbove();
}

bool FlutterVirtualDisplay::Initialize(const char* ip, int port, bool from_registry) {
  bool success = false;
  
  if (!IsSupported()) {
    NotifyVirtualDisplayError(UNSUPPORTED_WINDOWS_VERSION_ERROR_MESSAGE);
    return false;
  }

  if (!from_registry) {
    success = sn_client_->Start(ip, port);
  }
  else {
    DWORD dynamicPort = 0;
    if (Win32Utils::ReadRegistryValue(VIEWSONIC_REGISTRY_PATH, VIEWSONIC_REGISTRY_SERVICE_PORT_NAME, &dynamicPort)) {
      success = sn_client_->Start(ip, dynamicPort);
    } else {
      success = sn_client_->Start(ip, port);
    }
  }
  if (success) {
    NotifyVirtualDisplayInitialized(success, sn_client_->GetLastError().c_str());
  } else {
    NotifyVirtualDisplayError(sn_client_->GetLastError().c_str());
  }
  return success;
}

bool FlutterVirtualDisplay::StartVirtualDisplay(int pixelWidth, int pixelHeight) {
  bool success = false;
  if (sn_client_->DisplayConnect(pixelWidth, pixelHeight)) {
    success = true;
  }
  NotifyVirtualDisplayStarted(success, sn_client_->GetLastError().c_str());
  return success;
}

void FlutterVirtualDisplay::StopVirtualDisplay() {
  bool success = sn_client_->DisplayDisconnect();
  NotifyVirtualDisplayStopped(success, sn_client_->GetLastError().c_str());
}

void FlutterVirtualDisplay::NotifyVirtualDisplayInitialized(bool success, const char* error_message) {
  EncodableMap params;
  params[EncodableValue("event")] = "virtualDisplayInitialized";
  params[EncodableValue("success")] = success;
  params[EncodableValue("errorMessage")] = error_message;
  event_channel_->Success(flutter::EncodableValue(params));
}

void FlutterVirtualDisplay::NotifyVirtualDisplayStarted(bool success, const char* error_message) {
  EncodableMap params;
  params[EncodableValue("event")] = "virtualDisplayStarted";
  params[EncodableValue("success")] = success;
  params[EncodableValue("errorMessage")] = error_message;
  event_channel_->Success(flutter::EncodableValue(params));
}

void FlutterVirtualDisplay::NotifyVirtualDisplayStopped(bool success, const char* error_message) {
  EncodableMap params;
  params[EncodableValue("event")] = "virtualDisplayStopped";
  params[EncodableValue("success")] = success;
  params[EncodableValue("errorMessage")] = error_message;
  event_channel_->Success(flutter::EncodableValue(params));
}

void FlutterVirtualDisplay::NotifyVirtualDisplayError(const char* error_message) {
  EncodableMap params;
  params[EncodableValue("event")] = "virtualDisplayError";
  params[EncodableValue("errorMessage")] = error_message;
  event_channel_->Success(flutter::EncodableValue(params));
}

} // namespace flutter_virtual_display
