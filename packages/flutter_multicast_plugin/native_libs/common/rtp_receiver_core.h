#pragma once
#include <atomic>
#include <cstdint>
#include <functional>
#include <mutex>
#include <stdint.h>
#include <string>
#include <thread>
#include <unordered_set>
#include <vector>

class RtpReceiverCore {
  public:
    using AUCallback = std::function<void(const std::vector<uint8_t>&)>;

    RtpReceiverCore();
    ~RtpReceiverCore();

    void start(const std::vector<std::string>& local_ips, const std::string& multicast_ip, int port, std::vector<uint8_t> key, std::vector<uint8_t> salt, uint32_t ssrc, uint32_t roc, AUCallback callback);
    void stop();

  private:
    std::vector<std::thread> receiver_threads_;
    std::atomic<bool> running_ = false;
    std::atomic<bool> active_found_ = false;
};