#ifndef FLUTTER_PLUGIN_FLUTTER_VIRTUAL_DISPLAY_H
#define FLUTTER_PLUGIN_FLUTTER_VIRTUAL_DISPLAY_H

#include <memory>

#include "flutter_common.h"

#define DEFAULT_IP "127.0.0.1"
#define DEFAULT_PORT 28252
#define VIEWSONIC_INDIRECT_DISPLAY_DEVICE_ID L"VID_VIEWSONIC_PID_INDIRECT_DISPLAY_VIRTUAL_DISPLAY_0003"
#define VIEWSONIC_REGISTRY_PATH L"Software\\Viewsonic\\AirSync Sender"
#define VIEWSONIC_REGISTRY_SERVICE_PORT_NAME L"ServicePort"

namespace virtual_display_client {
class SNClient;
} // namespace virtual_display_client

namespace flutter_virtual_display {

class FlutterVirtualDisplay {
 public:
  FlutterVirtualDisplay(flutter::BinaryMessenger* messenger);
  virtual ~FlutterVirtualDisplay();

  bool IsSupported();
  bool Initialize(const char* ip = DEFAULT_IP, int port = DEFAULT_PORT, bool from_registry = false);
  bool StartVirtualDisplay(int pixelWidth, int pixelHeight);
  void StopVirtualDisplay();

 private:
  void NotifyVirtualDisplayInitialized(bool success, const char* error_message);
  void NotifyVirtualDisplayStarted(bool success, const char* error_message);
  void NotifyVirtualDisplayStopped(bool success, const char* error_message);
  void NotifyVirtualDisplayError(const char* error_message);

 private:
  BinaryMessenger* messenger_;
  std::unique_ptr<EventChannelProxy> event_channel_;
  std::unique_ptr<virtual_display_client::SNClient> sn_client_;
};

}  // namespace flutter_virtual_display

#endif  // FLUTTER_PLUGIN_FLUTTER_VIRTUAL_DISPLAY_H
