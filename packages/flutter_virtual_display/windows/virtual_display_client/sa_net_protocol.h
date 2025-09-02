#ifndef SANET_CLIENT_H
#define SANET_CLIENT_H

#include <vector>
#include <string>

namespace virtual_display_client {

class SANetProtocol
{
 public:
  static std::vector<std::uint8_t> DisplayConnectPacketCreate(int pixelWidth, int pixelHeight);
  static std::vector<std::uint8_t> DisplayDisconnectPacketCreate();
};

} // namespace virtual_display_client

#endif //SANET_CLIENT_H
