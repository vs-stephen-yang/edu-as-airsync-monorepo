#pragma once
#include "h264_util.h"
#include <atomic>
#include <cstdint>
#include <functional>
#include <mutex>
#include <stdint.h>
#include <string>
#include <thread>
#include <unordered_map>
#include <unordered_set>
#include <vector>

class RtpReceiverCore {
  public:
    using AUCallback = std::function<void(const std::vector<uint8_t>&)>;

    RtpReceiverCore();
    ~RtpReceiverCore();

    void start(const std::vector<std::string>& local_ips, const std::string& multicast_ip, int video_port, int audio_port, std::vector<uint8_t>& key, std::vector<uint8_t>& salt, uint32_t ssrc, uint32_t video_roc, uint32_t audio_roc, AUCallback callback, AUCallback audio_callback);
    void stop();

  private:
    std::thread video_receiver_thread_;
    std::thread audio_receiver_thread_;
    std::atomic<bool> running_;
    std::unordered_map<uint32_t, AuBuf> aus_; // key = RTP timestamp

    std::string detect_best_interface(const std::vector<std::string>& candidate_local_ips,
                                      const std::string& multicast_ip,
                                      int port,
                                      std::vector<uint8_t>& key,
                                      std::vector<uint8_t>& salt,
                                      uint32_t ssrc,
                                      uint32_t roc);

    void start_rtp_receiver_with_interface(const std::string& interface_ip,
                                           const std::string& multicast_ip,
                                           int video_port,
                                           int audio_port,
                                           std::vector<uint8_t>& key,
                                           std::vector<uint8_t>& salt,
                                           uint32_t ssrc,
                                           uint32_t video_roc,
                                           uint32_t audio_roc,
                                           AUCallback callback,
                                           AUCallback audio_callback);
};