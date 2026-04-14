#include "tcp_client.h"
#include "sn_client.h"
#include "sn_service_controller.h"
#include "sa_net_protocol.h"

using namespace virtual_display_client;

SNClient::SNClient(bool check_service_status)
  : last_error_(Error::ERROR_NONE), check_service_status_(check_service_status) {
  tcp_client_ = std::make_unique<TCPClient>();
  sn_service_controller_ = std::make_unique<SNServiceController>();
}

SNClient::~SNClient() {
  Stop();
}

bool SNClient::Start(const char* ip, int port) {
  if (check_service_status_) {
    if (!sn_service_controller_->IsRunning()) {
      last_error_ = Error::ERROR_WINDOW_SERVICE_NOT_RUNNING;
      return false;
    }
  }
  if (!tcp_client_->Initialize(ip, port)) {
    return false;
  }
  return true;
}

void SNClient::Stop() {
  tcp_client_->Close();
}

bool SNClient::DisplayConnect(int pixelWidth, int pixelHeight) {
  if (!tcp_client_->Connect()) {
    last_error_ = Error::ERROR_FAILED_TO_CONNECT_TO_SERVER;
    return false;
  }
  try {
	auto buf = SANetProtocol::DisplayConnectPacketCreate(pixelWidth, pixelHeight);
	tcp_client_->SendAll(buf.data(), (int)buf.size());
  } catch (...) {
    last_error_ = Error::ERROR_UNKNOWN;
	return false;
  }
  return true;
}

bool SNClient::DisplayDisconnect() {
  try {
    auto buf = SANetProtocol::DisplayDisconnectPacketCreate();
	tcp_client_->SendAll(buf.data(), (int)buf.size());
  }
  catch (...) {
    last_error_ = Error::ERROR_UNKNOWN;
	return false;
  }
  return true;
}

std::string SNClient::GetLastError() {
  return GetErrorString(last_error_);
}
