#pragma once
#include <functional>
#include <thread>
#include <vector>
#include <atomic>
#include <mutex>
#include <cstdint>
#include <string>
#include <unordered_set>
#include <stdint.h>

class RtpReceiverCore
{
public:
    using AUCallback = std::function<void(const std::vector<uint8_t> &)>;

    RtpReceiverCore();
    ~RtpReceiverCore();

    void start(const std::string &ip, int port, std::vector<uint8_t> &key, std::vector<uint8_t> &salt, uint32_t ssrc, uint32_t roc, AUCallback callback);
    // void start(const std::string &ip, int port, uint8_t *key, uint8_t *salt, uint32_t ssrc, uint32_t roc, AUCallback callback);
    void stop();

private:
    std::thread receiver_thread_;
    std::atomic<bool> running_;
};