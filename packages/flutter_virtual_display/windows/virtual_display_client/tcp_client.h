#ifndef __TCP_CLIENT_H__
#define __TCP_CLIENT_H__

#include <winsock2.h>
#include <ws2tcpip.h>
#include <string>

namespace virtual_display_client {

class TCPClient {
 public:
  TCPClient();
  virtual ~TCPClient();

  bool Initialize(const std::string& ip, int port, bool no_delay = false);
  bool Connect();
  void Close();

  int Send(unsigned char* buffer, int buffer_len);
  int Recv(unsigned char* buffer, int buffer_len);

  bool SendAll(unsigned char* buffer, int buffer_len);
  bool RecvAll(int len, unsigned char* buffer, int buffer_len);

  void Shutdown(unsigned int timeout_ms);
  void WaitClose(unsigned int timeout_ms);

 public:
  std::string GetIP() const { return ip_; }
  int GetPort() const { return port_; }
  SOCKET GetSocket() const { return socket_; }
  bool IsValid() const { return (socket_ != INVALID_SOCKET); }

private:
  SOCKET socket_ = INVALID_SOCKET;
  std::string ip_;
  int port_ = 0;
  bool no_delay_ = false;
};

} // namespace virtual_display_client

#endif //__TCP_CLIENT_H__
