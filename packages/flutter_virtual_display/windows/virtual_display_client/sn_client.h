#ifndef __SN_CLIENT_H__
#define __SN_CLIENT_H__

#include <memory>
#include <thread>
#include <atomic>

namespace virtual_display_client {

class TCPClient;

class SNClient
{
 public:
  SNClient();
  virtual ~SNClient();

  bool Start(const char* ip, int port);
  void Stop();

  bool DisplayConnect();
  bool DisplayDisconnect();

private:
  std::unique_ptr<TCPClient> tcp_client_;
};

} // namespace virtual_display_client

#endif //__SN_CLIENT_H__
