#include "tcp_client.h"
#include "sn_client.h"
#include "sa_net_protocol.h"

#include <chrono>

using namespace virtual_display_client;

SNClient::SNClient() {
  tcp_client_ = std::make_unique<TCPClient>();
}

SNClient::~SNClient() {
  Stop();
}

bool SNClient::Start(const char* ip, int port) {
  if (!tcp_client_->Initialize(ip, port)) {
    return false;
  }
  return true;
}

void SNClient::Stop() {
  tcp_client_->Close();
}

bool SNClient::DisplayConnect() {
  if (!tcp_client_->Connect()) {
    return false;
  }
  try {
	auto buf = SANetProtocol::DisplayConnectPacketCreate();
	tcp_client_->SendAll(buf.data(), (int)buf.size());
  } catch (...) {
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
	return false;
  }
  return true;
}
