#include "sa_net_protocol.h"

#include <windows.h>
#include <IPTypes.h>
#include "spacedeskNetProtocolSmpl.h"

using namespace virtual_display_client;

const int ProtocolVersionNumberMajor = 4;
const int ProtcolVersionNumberMinor = 8;
const int LicensInformation = 0;
const int FrameRateLimitation = 60;
const int ResolutionListCount = 1;
const int DefaultResolutionX = 1920;
const int DefaultResolutionY = 1080;
const wchar_t* DeviceIdentifier = L"{c9bdf5a6-776d-4533-ba27-9eff7a48d1c0}";
const wchar_t* DeviceName = L"AirSyncDevice";

std::vector<std::uint8_t> SANetProtocol::DisplayConnectPacketCreate(int pixelWidth, int pixelHeight) {
  size_t len = sizeof(PROTOCOL_SPCDSK_SMPL_HEADER) + sizeof(PROTOCOL_SPCDSK_SMPL_DATA_IDENTIFICATION);
  std::vector<uint8_t> buffer(len, 0x00);

  PROTOCOL_SPCDSK_SMPL_HEADER* Packet = (PROTOCOL_SPCDSK_SMPL_HEADER*)buffer.data();
  Packet->HeaderType = PROTOCOL_SPCDSK_SMPL_HEADER_TYPE_IDENTIFICATION;
  Packet->CountbyteDataFollowingHeader = sizeof(PROTOCOL_SPCDSK_SMPL_DATA_IDENTIFICATION);
  Packet->u.Identification.ProtocolVersionNumberMajor = ProtocolVersionNumberMajor;
  Packet->u.Identification.ProtocolVersionNumberMinor = ProtcolVersionNumberMinor;
  Packet->u.Identification.ClientType = PROTOCOL_SPCDSK_SMPL_CLIENT_TYPE_DISPLAY_MONITOR;
  Packet->u.Identification.OsType = PROTOCOL_SPCDSK_SMPL_OS_TYPE_WINDOWS_NATIVE;
  Packet->u.Identification.CompressionTypeDesired = PROTOCOL_SPCDSK_SMPL_COMPRESSION_MJPEG_D1_00;
  Packet->u.Identification.LicensingInformation = LicensInformation;
  Packet->u.Identification.FrameRateLimitation = FrameRateLimitation;
  Packet->u.Identification.ResolutionsListCount = ResolutionListCount;
  Packet->u.Identification.ResolutionX[0] = (pixelWidth > 0) ? pixelWidth : DefaultResolutionX;
  Packet->u.Identification.ResolutionY[0] = (pixelHeight > 0) ? pixelHeight : DefaultResolutionY;

  PROTOCOL_SPCDSK_SMPL_DATA_IDENTIFICATION* pIdentification =
	  (PROTOCOL_SPCDSK_SMPL_DATA_IDENTIFICATION*)(buffer.data() + sizeof(PROTOCOL_SPCDSK_SMPL_HEADER));
  wcscpy_s(pIdentification->DeviceIdentifier, DeviceIdentifier);
  wcscpy_s(pIdentification->DeviceInformation, DeviceName);

  return buffer;
}

std::vector<std::uint8_t> SANetProtocol::DisplayDisconnectPacketCreate() {
  size_t len = sizeof(PROTOCOL_SPCDSK_SMPL_HEADER);
  std::vector<uint8_t> buffer(len, 0x00);

  PROTOCOL_SPCDSK_SMPL_HEADER* Packet = (PROTOCOL_SPCDSK_SMPL_HEADER*)buffer.data();
  Packet->HeaderType = PROTOCOL_SPACEDESK_DISCONNECT;
  Packet->CountbyteDataFollowingHeader = 0;

  return buffer;
}
