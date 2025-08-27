#include "rtp_receiver_core.h"
#include "h264_util.h"
#include "ip_pktinfo_detector.h"
#include "log.h"
#include <cstring>
#include <iostream>
#include <sstream>
#include <uvgrtp/lib.hh>

constexpr int RECEIVER_WAIT_TIME_MS = 100;
uvgrtp::context ctx;
uvgrtp::session* session;

RtpReceiverCore::RtpReceiverCore() : running_(false) {}

RtpReceiverCore::~RtpReceiverCore() {
    stop();
}

void RtpReceiverCore::start(const std::vector<std::string>& candidate_local_ips, const std::string& multicast_ip, int video_port, int audio_port, std::vector<uint8_t>& key, std::vector<uint8_t>& salt, uint32_t ssrc, uint32_t video_roc, uint32_t audio_roc, AUCallback callback, AUCallback audio_callback) {
    if (running_)
        return;

    std::string selected_interface;

    // 策略 1: 有多個候選介面時進行檢測
    if (candidate_local_ips.size() > 1) {
        selected_interface = detect_best_interface(candidate_local_ips, multicast_ip, video_port, key, salt, ssrc, video_roc);
    }
    // 策略 2: 只有一個候選介面時直接使用
    else if (!candidate_local_ips.empty()) {
        selected_interface = candidate_local_ips[0];
    }
    // 策略 3: 沒有候選介面時拋出錯誤
    else {
        ALOGE("No candidate interfaces provided");
        return;
    }

    // 使用選定的介面啟動 RTP 接收器
    start_rtp_receiver_with_interface(selected_interface, multicast_ip, video_port, audio_port, key, salt, ssrc, video_roc, audio_roc, callback, audio_callback);
}

void RtpReceiverCore::stop() {
    running_ = false;
    if (video_receiver_thread_.joinable()) {
        video_receiver_thread_.join();
    }
    if (audio_receiver_thread_.joinable()) {
        audio_receiver_thread_.join();
    }
    if (session) {
        ctx.destroy_session(session);
        session = nullptr;
    }
}

std::string RtpReceiverCore::detect_best_interface(const std::vector<std::string>& candidate_local_ips,
                                                   const std::string& multicast_ip,
                                                   int port,
                                                   std::vector<uint8_t>& key,
                                                   std::vector<uint8_t>& salt,
                                                   uint32_t ssrc,
                                                   uint32_t roc) {
    // 創建檢測器實例
    auto detector = std::make_unique<ip_pktinfo_detector>();

    // 開始介面檢測
    bool detection_started = detector->start_detection(
        candidate_local_ips,
        multicast_ip,
        static_cast<uint16_t>(port),
        key, salt, ssrc, roc,
        5 // 5 秒超時
    );

    if (!detection_started) {
        // LOG_WARN("Interface detection failed to start, using first interface");
        return candidate_local_ips[0];
    }

    // 等待檢測結果
    auto result = detector->get_result();
    // detector->stop_detection();

    if (result.detection_successful) {
        ALOGD("[RECV Detect] Best interface detected: %s", result.best_interface.c_str());
        return result.best_interface;
    } else {
        ALOGW("[RECV Detect] Interface detection failed: %s", result.error_message.c_str());
        return candidate_local_ips[0];
    }
}

void RtpReceiverCore::start_rtp_receiver_with_interface(const std::string& interface_ip,
                                                        const std::string& multicast_ip,
                                                        int video_port,
                                                        int audio_port,
                                                        std::vector<uint8_t>& key,
                                                        std::vector<uint8_t>& salt,
                                                        uint32_t ssrc,
                                                        uint32_t video_roc,
                                                        uint32_t audio_roc,
                                                        AUCallback callback,
                                                        AUCallback audio_callback) {

    if (running_)
        return;

    ALOGD("[RECV Detect] create receive session with interface IP: %s", interface_ip.c_str());
    running_ = true;
    session = ctx.create_session(interface_ip);
    session->set_multicast_address(multicast_ip);
    auto video_stream = session->create_stream(video_port, RTP_FORMAT_H264, RCE_SRTP | RCE_SRTP_AUTHENTICATE_RTP | RCE_SRTP_KMNGMNT_USER | RCE_RECEIVE_ONLY);
    if (!video_stream) {
        return;
    }

    video_stream->add_srtp_ctx(key.data(), salt.data());
    video_stream->configure_ctx(RCC_REMOTE_SSRC, ssrc);
    video_stream->set_srtp_roc(video_roc);
    video_stream->enable_network_stats(true);

    auto audio_stream = session->create_stream(audio_port, RTP_FORMAT_OPUS, RCE_SRTP | RCE_SRTP_AUTHENTICATE_RTP | RCE_SRTP_KMNGMNT_USER | RCE_RECEIVE_ONLY);
    if (!audio_stream) {
        return;
    }

    audio_stream->add_srtp_ctx(key.data(), salt.data());
    audio_stream->configure_ctx(RCC_REMOTE_SSRC, ssrc);
    audio_stream->set_srtp_roc(audio_roc);
    audio_stream->enable_network_stats(true);

    video_receiver_thread_ = std::thread([video_stream, callback, this]() {
        uint32_t frame_count = 0;

        std::vector<uint8_t> latest_sps, latest_pps;

        auto flush_au = [&](uint32_t ts) {
            auto it = aus_.find(ts);
            if (it == aus_.end())
                return;
            auto& au = it->second;

            // 沒有 VCL 的 AU 不送（純參數集或雜訊）
            if (!au.has_vcl || au.nals.empty()) {
                aus_.erase(it);
                return;
            }

            std::vector<uint8_t> out;

            // IDR 幀前面帶一次 SPS/PPS
            if (au.seen_idr) {
                if (!latest_sps.empty())
                    out.insert(out.end(), latest_sps.begin(), latest_sps.end());
                if (!latest_pps.empty())
                    out.insert(out.end(), latest_pps.begin(), latest_pps.end());
            }
            for (auto& n : au.nals)
                out.insert(out.end(), n.begin(), n.end());

            callback(out);
            aus_.erase(it);
        };

        while (running_) {
            auto* frame = video_stream->pull_frame(RECEIVER_WAIT_TIME_MS);
            if (!frame || !frame->payload || frame->payload_len == 0) {
                if (frame)
                    uvgrtp::frame::dealloc_frame(frame);
                continue;
            }

            frame_count++;

            // 新增：每100個 frame 輸出網路統計
            if (frame_count % 100 == 0) {
                auto network_stats = video_stream->get_network_stats();

                ALOGI("=== NETWORK STATISTICS (Frame %u) ===", frame_count);
                ALOGI("Network Received: %u", network_stats.network_received);
                ALOGI("Network Expected: %u", network_stats.network_expected);
                ALOGI("Network Lost: %u", network_stats.network_lost);
                ALOGI("Network Loss Rate: %.2f%%", network_stats.network_loss_rate);
                ALOGI("Size Errors: %u", network_stats.size_errors);
                ALOGI("Auth Failures: %u", network_stats.auth_failures);
                ALOGI("Replay Attacks: %u", network_stats.replay_attacks);
                ALOGI("Decrypt Success: %u", network_stats.decrypt_success);
                ALOGI("Duplicate Packets: %u", network_stats.duplicate_packets);
                ALOGI("Out-of-order Packets: %u", network_stats.out_of_order_packets);
                ALOGI("=========================================");
            }

            uint32_t ts = frame->header.timestamp;
            bool marker = frame->header.marker; // ← 一幀最後一包
            const uint8_t* payload = frame->payload;
            size_t plen = frame->payload_len;

            auto& au = aus_[ts];
            if (au.nals.empty())
                au.first_seen = std::chrono::steady_clock::now();

            auto push_one_annexb_nal = [&](const uint8_t* nal, size_t n) {
                std::vector<uint8_t> v;
                v.insert(v.end(), nal, nal + n);

                int t = h264::nal_type_of_any(v.data(), v.size());
                if (t == 7) {
                    latest_sps = v;
                } else if (t == 8) {
                    latest_pps = v;
                } else if (t == 5) {
                    au.seen_idr = true;
                    au.has_vcl = true;
                } else if (t == 1) {
                    au.has_vcl = true;
                }

                au.nals.emplace_back(std::move(v));
            };

            // Annex-B：可能同一 payload 內多顆 NAL
            auto segs = h264::scan_annexb_nals(payload, plen);
            if (segs.empty()) {
                ALOGW("Annex-B payload but no NAL found (len=%zu)", plen);
            } else if (segs.size() > 1) {
                ALOGW("Multiple NALs in one payload: %zu", segs.size());
            }
            for (auto& s : segs)
                push_one_annexb_nal(s.first, s.second);

            // frame 結束判定：RTP marker
            if (marker) {
                flush_au(ts);
            }

            uvgrtp::frame::dealloc_frame(frame);

            for (auto it = aus_.begin(); it != aus_.end();) {
                if (std::chrono::steady_clock::now() - it->second.first_seen > std::chrono::milliseconds(500)) {
                    // 放棄這幀（丟掉）
                    it = aus_.erase(it);
                } else
                    ++it;
            }
        }

        session->destroy_stream(video_stream);
    });

    audio_receiver_thread_ = std::thread([audio_stream, audio_callback, this]() {
        while (running_) {
            auto* frame = audio_stream->pull_frame(RECEIVER_WAIT_TIME_MS);
            if (!frame || !frame->payload || frame->payload_len == 0) {
                continue;
            }
            std::vector<uint8_t> au;
            au.insert(au.end(), frame->payload, frame->payload + frame->payload_len);
            audio_callback(au);
            uvgrtp::frame::dealloc_frame(frame);
        }

        session->destroy_stream(audio_stream);
    });
}