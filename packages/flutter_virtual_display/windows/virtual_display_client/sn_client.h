#ifndef __SN_CLIENT_H__
#define __SN_CLIENT_H__

#include <memory>
#include <thread>
#include <functional>
#include <atomic>
#include "sn_error.h"

namespace virtual_display_client {

class TCPClient;
class SNServiceController;

class SNClient {
 public:
  SNClient(bool check_service_status = true);
  virtual ~SNClient();

  bool Start(const char* ip, int port);
  void Stop();

  bool DisplayConnect(int pixelWidth, int pixelHeight);
  bool DisplayDisconnect();

  std::string GetLastError();

private:
  bool check_service_status_;
  Error last_error_;
  std::unique_ptr<TCPClient> tcp_client_;
  std::unique_ptr<SNServiceController> sn_service_controller_;
};

} // namespace virtual_display_client

#endif //__SN_CLIENT_H__
