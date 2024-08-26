#ifndef __SN_SERVICE_CONTROLLER_H__
#define __SN_SERVICE_CONTROLLER_H__

namespace virtual_display_client {

class SNServiceController {
 public:
  bool Start();
  bool Stop();
  bool IsRunning();
}; // class SNServiceController

} // namespace virtual_display_client

#endif //__SN_SERVICE_CONTROLLER_H__
