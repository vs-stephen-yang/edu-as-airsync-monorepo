#include "tcp_client.h"

class WinSockInit
{
public:
	WinSockInit()
	{
		WSADATA wsaData;
		(void)WSAStartup(MAKEWORD(2, 2), &wsaData);
	}

	~WinSockInit()
	{
		WSACleanup();
	}

	static WinSockInit& GetInstance()
	{
		static WinSockInit g_WinSockInit;
		return g_WinSockInit;
	}
};

using namespace virtual_display_client;

TCPClient::TCPClient() {
  WinSockInit::GetInstance();
}

TCPClient::~TCPClient() {}

bool TCPClient::Initialize(const std::string& ip, int port, bool no_delay) {
  ip_ = ip;
  port_ = port;
  no_delay_ = no_delay;
  return true;
}

bool TCPClient::Connect() {
	Close();

	int ret = 0;
	struct addrinfo* result = NULL;
	struct addrinfo* ptr = NULL;

	struct addrinfo hints {};
	hints.ai_family = AF_UNSPEC;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_protocol = IPPROTO_TCP;

	ret = getaddrinfo(ip_.c_str(), std::to_string(port_).c_str(), &hints, &result);
	if (ret != 0) {
		return false;
	}

	bool success = false;
	for (ptr = result; ptr != NULL; ptr = ptr->ai_next) {
		socket_ = socket(ptr->ai_family, ptr->ai_socktype, ptr->ai_protocol);
		if (socket_ == INVALID_SOCKET) {
			success = false;
			break;
		}

		if (no_delay_) {
			int value = 1;
			int szValueLen = sizeof(value);
			ret = setsockopt(socket_, IPPROTO_TCP, TCP_NODELAY, (char*)&value, szValueLen);
			if (ret != 0)
			{
				success = false;
				break;
			}
		}

		ret = connect(socket_, ptr->ai_addr, (int)ptr->ai_addrlen);
		if (ret != 0) {
			closesocket(socket_);
			socket_ = INVALID_SOCKET;
		}
		else {
			success = true;
			break;
		}
	}
	freeaddrinfo(result);

	return success;
}

int TCPClient::Send(unsigned char* buffer, int buffer_len) {
  return ::send(socket_, (char*)buffer, buffer_len, 0);
}

int TCPClient::Recv(unsigned char* buffer, int buffer_len) {
  return ::recv(socket_, (char*)buffer, buffer_len, 0);
}

bool TCPClient::SendAll(unsigned char* buffer, int buffer_len) {
    int total_sent = 0;
    while (total_sent < buffer_len) {
        int sent = Send(buffer + total_sent, buffer_len - total_sent);
        if (sent == SOCKET_ERROR) {
            return false;
        }
        total_sent += sent;
    }
    return true;
}

bool TCPClient::RecvAll(int len, unsigned char* buffer, int buffer_len) {
	int remain = buffer_len;
	do
	{
		int ret = recv(socket_, (char*)buffer, remain, 0);
		if (ret <= 0) {
			return false;
		}

		remain -= ret;
		buffer += ret;
	} while (remain > 0);

	return true;
}

void TCPClient::Close() {
	if (socket_ != INVALID_SOCKET) {
		closesocket(socket_);
    }
	socket_ = INVALID_SOCKET;
}

void TCPClient::Shutdown(unsigned int p_TimeoutMs) {
	if (socket_ == INVALID_SOCKET) {
		return;
    }

	if (shutdown(socket_, SD_SEND) == SOCKET_ERROR) {
		return;
	}

	WaitClose(p_TimeoutMs);
}

void TCPClient::WaitClose(unsigned int p_TimeoutMs) {
	WSAEVENT hEvent = WSACreateEvent();

	if (WSAEventSelect(socket_, hEvent, FD_CLOSE) == SOCKET_ERROR) {
		WSACloseEvent(hEvent);
		return;
	}

	DWORD ret = WSAWaitForMultipleEvents(1, &hEvent, FALSE, p_TimeoutMs, FALSE);
	WSACloseEvent(hEvent);
}
