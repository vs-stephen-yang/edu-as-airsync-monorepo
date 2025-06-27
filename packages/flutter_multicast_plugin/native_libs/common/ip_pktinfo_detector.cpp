#include "ip_pktinfo_detector.h"
#include "log.h"
#include <algorithm>
#include <iostream>

#include <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <netinet/in.h>
#include <sys/socket.h>

#include <uvgrtp/lib.hh>

ip_pktinfo_detector::ip_pktinfo_detector()
    : detection_complete_(false), timeout_seconds_(5) {
}

ip_pktinfo_detector::~ip_pktinfo_detector() {
    stop_detection();
}

bool ip_pktinfo_detector::start_detection(const std::vector<std::string>& interfaces,
                                          const std::string& multicast_ip,
                                          uint16_t port,
                                          std::vector<uint8_t>& key,
                                          std::vector<uint8_t>& salt,
                                          uint32_t ssrc,
                                          uint32_t roc,
                                          int timeout_seconds) {

    if (interfaces.empty()) {
        ALOGD("[RECV Detect] No interfaces provided");
        return false;
    }

    debug_all_interfaces();

    timeout_seconds_ = timeout_seconds;
    detection_start_time_ = std::chrono::steady_clock::now();
    detection_complete_ = false;
    selected_interface_.clear();

    ALOGD("[RECV Detect] Starting detection on %zu interfaces for %d seconds", interfaces.size(), timeout_seconds);
    ALOGD("[RECV Detect] Target: %s:%d", multicast_ip.c_str(), port);

    // 為每個接口創建檢測上下文
    detection_contexts_.clear();
    detection_contexts_.reserve(interfaces.size());

    for (const auto& interface_ip : interfaces) {
        if (!has_interface_ip(interface_ip)) {
            ALOGE("[RECV Detect] Interface IP %s not found on system", interface_ip.c_str());
            continue;
        }
        int index = get_interface_index(interface_ip);
        ALOGD("[RECV Detect] Candidate interface %s maps to index %d", interface_ip.c_str(), index);

        // 使用 make_unique 創建 detection_context
        auto ctx = std::make_unique<detection_context>();
        ctx->interface_index = index;
        ctx->interface_ip = interface_ip;
        ctx->start_time = std::chrono::steady_clock::now();
        ctx->should_stop = false;     // 明確設定為 false
        ctx->got_valid_frame = false; // 明確設定為 false

        ALOGD("[RECV Detect] Setting up detection for interface: %s", interface_ip.c_str());

        detection_contexts_.push_back(std::move(ctx));
    }

    // 啟動所有檢測線程
    for (auto& ctx_ptr : detection_contexts_) {
        // 注意：這裡要解引用 unique_ptr 來傳遞 reference
        ctx_ptr->detection_thread = std::thread([this, &ctx = *ctx_ptr, multicast_ip, port, key, salt, ssrc, roc]() mutable {
            detection_thread_worker(ctx, multicast_ip, port, key, salt, ssrc, roc);
        });
    }

    ALOGD("[RECV Detect] All detection threads started");
    return true;
}

void ip_pktinfo_detector::detection_thread_worker(detection_context& ctx,
                                                  const std::string& multicast_ip,
                                                  uint16_t port,
                                                  std::vector<uint8_t>& key,
                                                  std::vector<uint8_t>& salt,
                                                  uint32_t ssrc,
                                                  uint32_t roc) {

    ALOGD("[RECV Detect] %s Starting detection thread", ctx.interface_ip.c_str());

    try {
        // 檢查初始狀態
        ALOGD("[RECV Detect] %s Initial state - should_stop: %d, detection_complete: %d",
              ctx.interface_ip.c_str(),
              ctx.should_stop.load(),
              detection_complete_.load());

        // 創建局部的 uvgRTP 組件
        auto context = std::make_shared<uvgrtp::context>();
        auto session = context->create_session(ctx.interface_ip);

        if (!session) {
            ALOGE("[RECV Detect] %s Failed to create session", ctx.interface_ip.c_str());
            return;
        }

        // 設定 multicast 地址
        session->set_multicast_address(multicast_ip);

        // 創建檢測模式的 stream
        auto stream = session->create_stream(port, 0, RTP_FORMAT_H264,
                                             RCE_SRTP | RCE_SRTP_AUTHENTICATE_RTP | RCE_SRTP_KMNGMNT_USER | RCE_RECEIVE_ONLY,
                                             true,                 // is_detection = true
                                             ctx.interface_index); // expected_interface

        if (!stream) {
            ALOGE("[RECV Detect] %s Failed to create stream", ctx.interface_ip.c_str());
            return;
        }

        // 設定 SRTP（如果有提供金鑰）
        if (!key.empty()) {
            if (stream->add_srtp_ctx(key.data(), salt.data()) != RTP_OK) {
                ALOGE("[RECV Detect] %s Failed to set srtp", ctx.interface_ip.c_str());
                return;
            }

            if (ssrc != 0) {
                if (stream->configure_ctx(RCC_REMOTE_SSRC, ssrc) != RTP_OK) {
                    ALOGE("[RECV Detect] %s Failed to set ssrc", ctx.interface_ip.c_str());
                    return;
                }
            }

            if (roc != 0) {
                stream->set_srtp_roc(roc);
            }
        }

        ALOGD("[RECV Detect] %s Stream created successfully, polling for frames...", ctx.interface_ip.c_str());

        // 主動輪詢 frame
        auto timeout = std::chrono::seconds(timeout_seconds_);
        while (!ctx.should_stop && !detection_complete_) {
            auto elapsed = std::chrono::steady_clock::now() - ctx.start_time;
            if (elapsed > timeout) {
                ALOGD("[RECV Detect] %s Detection timeout", ctx.interface_ip.c_str());
                break;
            }

            // 嘗試拉取 frame
            auto frame = stream->pull_frame(100);
            if (frame) {
                ALOGD("[RECV Detect] %s Got valid frame!", ctx.interface_ip.c_str());

                // 釋放 frame
                uvgrtp::frame::dealloc_frame(frame);

                // 標記為成功並記錄時間
                ctx.got_valid_frame = true;
                ctx.first_frame_time = std::chrono::steady_clock::now();

                // 檢查是否是第一個成功的接口
                if (!detection_complete_.exchange(true)) {
                    selected_interface_ = ctx.interface_ip;
                    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(
                        ctx.first_frame_time - detection_start_time_);

                    ALOGD("[RECV Detect] WINNER: %s (first frame in %lld ms)",
                          ctx.interface_ip.c_str(), static_cast<long long>(duration.count()));

                    // 停止所有其他檢測
                    for (auto& other_ctx_ptr : detection_contexts_) {
                        other_ctx_ptr->should_stop = true;
                    }

                    // 通知等待的執行緒
                    {
                        std::lock_guard<std::mutex> lock(detection_mutex_);
                        detection_cv_.notify_all();
                    }
                }
                break;
            }

            // 短暫休眠後繼續輪詢
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
        }

        // 函數結束時，局部變量會自動清理
        session->destroy_stream(stream);
        context->destroy_session(session);

    } catch (const std::exception& e) {
        ALOGE("[RECV Detect] %s Exception: %s", ctx.interface_ip.c_str(), e.what());
    }

    ALOGD("[RECV Detect] %s Detection thread finished", ctx.interface_ip.c_str());
}

ip_pktinfo_detector::detection_result ip_pktinfo_detector::get_result() {
    detection_result result;
    result.detection_successful = false;

    // 等待檢測完成或超時
    std::unique_lock<std::mutex> lock(detection_mutex_);

    auto timeout_duration = std::chrono::seconds(timeout_seconds_);
    bool completed = detection_cv_.wait_for(lock, timeout_duration, [this] {
        return detection_complete_.load() ||
               std::chrono::steady_clock::now() - detection_start_time_ >= std::chrono::seconds(timeout_seconds_);
    });

    auto current_time = std::chrono::steady_clock::now();
    result.detection_duration = std::chrono::duration_cast<std::chrono::milliseconds>(
        current_time - detection_start_time_);

    if (!selected_interface_.empty()) {
        result.best_interface = selected_interface_;
        result.detection_successful = true;

        ALOGD("[RECV Detect] Detection successful: %s in %lld ms",
              selected_interface_.c_str(), static_cast<long long>(result.detection_duration.count()));
    } else {
        result.error_message = completed ? "No interface received valid frames within timeout" : "Detection timed out";
        ALOGD("[RECV Detect] Detection failed: %s", result.error_message.c_str());
    }

    return result;
}

void ip_pktinfo_detector::stop_detection() {
    if (!detection_contexts_.empty()) {
        ALOGD("[RECV Detect] Stopping detection...");

        // 停止所有線程
        for (auto& ctx_ptr : detection_contexts_) {
            ctx_ptr->should_stop = true;
        }

        // 等待所有線程結束
        for (auto& ctx_ptr : detection_contexts_) {
            if (ctx_ptr->detection_thread.joinable()) {
                ctx_ptr->detection_thread.join();
            }
        }

        cleanup_detection_contexts();
        ALOGD("[RECV Detect] Detection stopped");
    }
}

void ip_pktinfo_detector::cleanup_detection_contexts() {
    detection_contexts_.clear();
    detection_complete_ = false;
    selected_interface_.clear();
}

void ip_pktinfo_detector::debug_all_interfaces() {
    ALOGD("[RECV Detect] === All Network Interfaces ===");

    struct ifaddrs* ifaddrs_ptr;
    if (getifaddrs(&ifaddrs_ptr) == -1) {
        ALOGE("[RECV Detect] getifaddrs failed: %s", strerror(errno));
        return;
    }

    ip_to_index_map_.clear();

    for (struct ifaddrs* ifa = ifaddrs_ptr; ifa != NULL; ifa = ifa->ifa_next) {
        if (ifa->ifa_addr == NULL)
            continue;

        // 取得介面索引
        int if_index = if_nametoindex(ifa->ifa_name);

        // 只顯示 IPv4 介面
        if (ifa->ifa_addr->sa_family == AF_INET) {
            struct sockaddr_in* addr_in = (struct sockaddr_in*)ifa->ifa_addr;
            char ip_str[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, &addr_in->sin_addr, ip_str, INET_ADDRSTRLEN);

            ALOGD("[RECV Detect] Interface: %s (index: %d) IP: %s", ifa->ifa_name, if_index, ip_str);

            ip_to_index_map_[std::string(ip_str)] = if_index;
        } else {
            ALOGD("[RECV Detect] Interface: %s (index: %d) [Non-IPv4]", ifa->ifa_name, if_index);
        }
    }

    freeifaddrs(ifaddrs_ptr);

    ALOGD("[RECV Detect] === IP to Index Mapping ===");
    for (const auto& pair : ip_to_index_map_) {
        ALOGD("[RECV Detect] IP: %s → Index: %d", pair.first.c_str(), pair.second);
    }
    ALOGD("[RECV Detect] === End Interface List ===");

    ALOGD("[RECV Detect] === End Interface List ===");
}

int ip_pktinfo_detector::get_interface_index(const std::string& ip) {
    auto it = ip_to_index_map_.find(ip);
    if (it != ip_to_index_map_.end()) {
        return it->second;
    }
    ALOGE("[RECV Detect] IP %s not found in mapping", ip.c_str());
    return -1; // 表示找不到
}

bool ip_pktinfo_detector::has_interface_ip(const std::string& ip) {
    return ip_to_index_map_.find(ip) != ip_to_index_map_.end();
}