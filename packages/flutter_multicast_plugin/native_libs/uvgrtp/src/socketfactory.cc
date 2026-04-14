#include "socketfactory.hh"
#include "debug.hh"
#include "global.hh"
#include "random.hh"
#include "rtcp_reader.hh"
#include "socket.hh"
#include "uvgrtp/frame.hh"

#ifdef _WIN32
#include <Ws2tcpip.h>
#define MSG_DONTWAIT 0
#else
#include <errno.h>
#include <netdb.h>
#include <netinet/in.h>
#include <poll.h>
#include <pthread.h>
#include <sys/socket.h>
#include <sys/types.h>

#endif
#include <algorithm>
#include <cstring>
#include <iterator>

constexpr size_t DEFAULT_INITIAL_BUFFER_SIZE = 4194304;

uvgrtp::socketfactory::socketfactory(int rce_flags) : rce_flags_(rce_flags),
                                                      local_address_(""),
                                                      used_ports_({}),
                                                      ipv6_(false),
                                                      used_sockets_({}),
                                                      reception_flows_({}),
                                                      rtcp_readers_to_ports_({}) {
}

uvgrtp::socketfactory::~socketfactory() {
}

rtp_error_t uvgrtp::socketfactory::set_local_interface(std::string local_addr) {
    UVG_LOG_DEBUG("[Set multicast] use addr %s to set interface", local_addr.c_str());
    local_address_ = local_addr;
    // check IP address family
    struct addrinfo hint, *res = NULL;
    memset(&hint, '\0', sizeof(hint));
    hint.ai_family = PF_UNSPEC;
    hint.ai_flags = AI_NUMERICHOST;

    if (getaddrinfo(local_address_.c_str(), NULL, &hint, &res) != 0) {
        return RTP_GENERIC_ERROR;
    }
    if (res->ai_family == AF_INET6) {
        ipv6_ = true;
    }

    freeaddrinfo(res);
    return RTP_OK;
}

std::shared_ptr<uvgrtp::socket> uvgrtp::socketfactory::finalize_socket_creation(
    std::shared_ptr<uvgrtp::socket> socket,
    int type, uint16_t port,
    const std::string& bind_address,
    bool is_send_only) {
    rtp_error_t ret = RTP_OK;
    if (ipv6_) {
        ret = socket->init(AF_INET6, SOCK_DGRAM, 0);
    } else {
        ret = socket->init(AF_INET, SOCK_DGRAM, 0);
    }

    if (ret == RTP_OK) {

#ifdef _WIN32
        /* Make the socket non-blocking */
        int enabled = 1;

        if (::ioctlsocket(socket->get_raw_socket(), FIONBIO, (u_long*)&enabled) < 0) {
            return nullptr;
        }
#endif

        used_sockets_.push_back(socket);
        if (port != 0 && !is_send_only) {
            UVG_LOG_DEBUG("[Set multicast] create new socket with bind address %s", bind_address.c_str());
            if (bind_socket(socket, port, bind_address) != RTP_OK) {
                return nullptr;
            }
        } else if (is_send_only && !local_address_.empty()) {
            // 純發送端設置 multicast 接口（不 bind）
            UVG_LOG_DEBUG("[Set multicast] create new socket with set send interface address %s", local_address_.c_str());
            if (socket->set_multicast_send_interface(local_address_) != RTP_OK) {
                UVG_LOG_WARN("Failed to set multicast send interface, will use default");
                // 不返回錯誤，繼續執行
            }
        }

        // If the socket is a type 2 (non-RTCP) socket, install a reception_flow
        if (type == 2) {
            std::shared_ptr<uvgrtp::reception_flow> flow = std::shared_ptr<uvgrtp::reception_flow>(new uvgrtp::reception_flow(ipv6_));
            std::pair pair = std::make_pair(flow, socket);
            reception_flows_.insert(pair);
        } else if (type == 1) {
            // RTCP socket
            std::shared_ptr<uvgrtp::rtcp_reader> reader = std::shared_ptr<uvgrtp::rtcp_reader>(new uvgrtp::rtcp_reader());
            rtcp_readers_to_ports_[reader] = port;
        }
        return socket;
    }

    return nullptr;
}

std::shared_ptr<uvgrtp::socket> uvgrtp::socketfactory::create_new_socket(int type, uint16_t port, const std::string& bind_address, bool is_send_only) {
    std::shared_ptr<uvgrtp::socket> socket = std::make_shared<uvgrtp::socket>(rce_flags_);
    return finalize_socket_creation(socket, type, port, bind_address, is_send_only);
}

std::shared_ptr<uvgrtp::socket> uvgrtp::socketfactory::create_new_socket(int type, uint16_t port, const std::string& bind_address, bool is_detection, int expected_interface) {
    if (!is_detection) {
        // 不是檢測模式，直接調用原有方法
        return create_new_socket(type, port, bind_address);
    }

    // 檢測模式：創建檢測 socket
    std::shared_ptr<uvgrtp::socket> socket = std::make_shared<uvgrtp::socket>(rce_flags_, is_detection, expected_interface);
    return finalize_socket_creation(socket, type, port, bind_address, false);
}

rtp_error_t uvgrtp::socketfactory::bind_socket(std::shared_ptr<uvgrtp::socket> soc, uint16_t port, const std::string& bind_address) {
    rtp_error_t ret = RTP_OK;
    sockaddr_in6 bind_addr6;
    sockaddr_in bind_addr;

    std::string effective_address = bind_address.empty() ? local_address_ : bind_address;
    bool is_custom_multicast = !bind_address.empty();
    UVG_LOG_DEBUG("[Set multicast] effective_address is %s, is_custom_multicast %d", effective_address.c_str(), is_custom_multicast);

    // First check if the address is a multicast address. If the address is a multicast address, several
    // streams can bind to the same port
    // If it is a regular address and you want to multiplex several streams into a single socket, one
    // bind is enough
    if (ipv6_) {
        bind_addr6 = uvgrtp::socket::create_ip6_sockaddr(local_address_, port);
        if (uvgrtp::socket::is_multicast(bind_addr6)) {
            UVG_LOG_INFO("The used address %s is a multicast address", local_address_.c_str());
            ret = soc->bind_ip6(bind_addr6);
        } else if (!is_port_in_use(port)) {
            ret = soc->bind_ip6(bind_addr6);
        }
    } else {
        bind_addr = uvgrtp::socket::create_sockaddr(AF_INET, effective_address, port);
        if (uvgrtp::socket::is_multicast(bind_addr)) {
            UVG_LOG_INFO("The used address %s is a multicast address", effective_address.c_str());
            if (is_custom_multicast) {
                // 自定義 multicast 地址：使用 local_address_ 作為接口
                ret = soc->bind(bind_addr, local_address_);
            } else {
                // 原有邏輯：直接綁定（會使用 INADDR_ANY 作為接口）
                ret = soc->bind(bind_addr);
            }
        } else if (!is_port_in_use(port)) {
            ret = soc->bind(bind_addr);
        }
    }
    if (ret == RTP_OK) {
        used_ports_.insert({port, soc});
        return RTP_OK;
    }

    return ret;
}

rtp_error_t uvgrtp::socketfactory::bind_socket_anyip(std::shared_ptr<uvgrtp::socket> soc, uint16_t port) {
    rtp_error_t ret = RTP_OK;
    std::lock_guard<std::mutex> lg(conf_mutex_);

    if (!is_port_in_use(port)) {

        if (ipv6_) {
            sockaddr_in6 bind_addr6 = uvgrtp::socket::create_ip6_sockaddr_any(port);
            ret = soc->bind_ip6(bind_addr6);
        } else {
            ret = soc->bind(AF_INET, INADDR_ANY, port);
        }
        if (ret == RTP_OK) {
            used_ports_.insert({port, soc});
            return RTP_OK;
        }
    }
    return ret;
}

std::shared_ptr<uvgrtp::socket> uvgrtp::socketfactory::get_socket_ptr(int type, uint16_t port) {
    std::lock_guard<std::mutex> lg(conf_mutex_);
    const auto& ptr = used_ports_.find(port);
    if (ptr != used_ports_.end()) {
        return ptr->second;
    }
    return create_new_socket(type, port);
}

std::shared_ptr<uvgrtp::reception_flow> uvgrtp::socketfactory::get_reception_flow_ptr(std::shared_ptr<uvgrtp::socket> socket) {
    std::lock_guard<std::mutex> lg(conf_mutex_);
    for (const auto& ptr : reception_flows_) {
        if (ptr.second == socket) {
            return ptr.first;
        }
    }
    return nullptr;
}

std::shared_ptr<uvgrtp::rtcp_reader> uvgrtp::socketfactory::install_rtcp_reader(uint16_t port) {
    std::shared_ptr<uvgrtp::rtcp_reader> reader = std::shared_ptr<uvgrtp::rtcp_reader>(new uvgrtp::rtcp_reader());
    rtcp_readers_to_ports_[reader] = port;
    return reader;
}

std::shared_ptr<uvgrtp::rtcp_reader> uvgrtp::socketfactory::get_rtcp_reader(uint16_t port) {
    for (auto& p : rtcp_readers_to_ports_) {
        if (p.second == port) {
            return p.first;
        }
    }
    return nullptr;
}

bool uvgrtp::socketfactory::get_ipv6() const {
    return ipv6_;
}

bool uvgrtp::socketfactory::is_port_in_use(uint16_t port) {
    if (used_ports_.find(port) == used_ports_.end()) {
        return false;
    }
    return true;
}

bool uvgrtp::socketfactory::clear_port(uint16_t port, std::shared_ptr<uvgrtp::socket> socket) {
    std::lock_guard<std::mutex> lg(conf_mutex_);

    if (port != 0) {
        used_ports_.erase(port);
    }
    for (auto& p : rtcp_readers_to_ports_) {
        if (p.second == port) {
            rtcp_readers_to_ports_.erase(p.first);
            break;
        }
    }
    auto it = std::find(used_sockets_.begin(), used_sockets_.end(), socket);
    if (it != used_sockets_.end()) {
        used_sockets_.erase(it);
    }
    for (auto& p : reception_flows_) {
        if (p.second == socket) {
            reception_flows_.erase(p.first);
            break;
        }
    }
    return true;
}