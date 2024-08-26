#include "flutter_virtual_display.h"

#include <string>

#include <flutter/standard_message_codec.h>
#include <flutter/standard_method_codec.h>
#include <flutter/event_stream_handler_functions.h>

#include "virtual_display_client/sn_client.h"

#include "virtual_display_client/win32_utils.h"
#include "virtual_display_client/virtual_display_state_watcher.h"

using namespace virtual_display_client;

namespace flutter_virtual_display {

const char* kEventChannelName = "FlutterVirtualDisplay.Event";

FlutterVirtualDisplay::FlutterVirtualDisplay(flutter::BinaryMessenger* messenger)
    : messenger_(messenger) {
  sn_client_ = std::make_unique<SNClient>();
  event_channel_ = EventChannelProxy::Create(messenger, kEventChannelName);
}

FlutterVirtualDisplay::~FlutterVirtualDisplay() {}

bool FlutterVirtualDisplay::Initialize(const char* ip, int port) {
  return sn_client_->Start(ip, port);
}

bool FlutterVirtualDisplay::StartVirtualDisplay() {
  if (!sn_client_->DisplayConnect()) {
    return false;
  }
  NotifyVirtualDisplayStarted();
  return true;
}

void FlutterVirtualDisplay::StopVirtualDisplay() {
  sn_client_->DisplayDisconnect();
  NotifyVirtualDisplayStopped();
}

void FlutterVirtualDisplay::NotifyVirtualDisplayStarted() {
  EncodableMap params;
  params[EncodableValue("event")] = "virtualDisplayStarted";
  event_channel_->Success(flutter::EncodableValue(params));
}

void FlutterVirtualDisplay::NotifyVirtualDisplayStopped() {
  EncodableMap params;
  params[EncodableValue("event")] = "virtualDisplayStopped";
  event_channel_->Success(flutter::EncodableValue(params));
}

} // namespace flutter_virtual_display
