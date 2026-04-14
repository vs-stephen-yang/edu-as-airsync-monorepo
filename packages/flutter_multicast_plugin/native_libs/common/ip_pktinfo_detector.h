#pragma once

#include <atomic>
#include <chrono>
#include <map>
#include <memory>
#include <string>
#include <thread>
#include <vector>

class ip_pktinfo_detector {
  public:
    struct detection_result {
        std::string best_interface;
        bool detection_successful;
        std::string error_message;
        std::chrono::milliseconds detection_duration;
    };

    ip_pktinfo_detector();
    ~ip_pktinfo_detector();

    // 主要 API
    bool start_detection(const std::vector<std::string>& interfaces,
                         const std::string& multicast_ip,
                         uint16_t port,
                         std::vector<uint8_t>& key,
                         std::vector<uint8_t>& salt,
                         uint32_t ssrc = 0,
                         uint32_t roc = 0,
                         int timeout_seconds = 5);

    detection_result get_result();
    void stop_detection();

  private:
    struct detection_context {
        std::string interface_ip;
        int interface_index;
        std::thread detection_thread;
        std::atomic<bool> got_valid_frame{false};
        std::atomic<bool> should_stop{false};
        std::chrono::steady_clock::time_point start_time;
        std::chrono::steady_clock::time_point first_frame_time;

        // 保持原本的結構，不需要額外的移動語義
    };

    // 主要變更：改用指標容器
    std::vector<std::unique_ptr<detection_context>> detection_contexts_;

    std::atomic<bool> detection_complete_{false};
    std::string selected_interface_;
    std::chrono::steady_clock::time_point detection_start_time_;
    int timeout_seconds_ = 5;
    std::condition_variable detection_cv_;
    std::mutex detection_mutex_;
    std::map<std::string, int> ip_to_index_map_;

    // 私有方法的參數需要調整
    void detection_thread_worker(detection_context& ctx, // 這個參數不變，還是 reference
                                 const std::string& multicast_ip,
                                 uint16_t port,
                                 std::vector<uint8_t>& key,
                                 std::vector<uint8_t>& salt,
                                 uint32_t ssrc,
                                 uint32_t roc);

    void cleanup_detection_contexts();

    void debug_all_interfaces();
    int get_interface_index(const std::string& ip);
    bool has_interface_ip(const std::string& ip);
};