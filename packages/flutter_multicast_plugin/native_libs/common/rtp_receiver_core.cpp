#include "rtp_receiver_core.h"
#include "log.h"
#include <cstring>
#include <iostream>
#include <uvgrtp/lib.hh>

constexpr int RECEIVER_WAIT_TIME_MS = 100;

RtpReceiverCore::RtpReceiverCore() : running_(false) {}

RtpReceiverCore::~RtpReceiverCore() {
    stop();
}

void RtpReceiverCore::start(
    const std::vector<std::string>& local_ips,
    const std::string& multicast_ip,
    int port,
    std::vector<uint8_t> key,
    std::vector<uint8_t> salt,
    uint32_t ssrc,
    uint32_t roc,
    AUCallback callback) {
    running_ = true;
    active_found_ = false;
    receiver_threads_.clear();

    for (std::string local_ip : local_ips) {
        receiver_threads_.emplace_back([local_ip, multicast_ip, port, key, salt, ssrc, roc, callback, this]() mutable {
            uvgrtp::context ctx;
            auto session = ctx.create_session(local_ip);
            session->set_multicast_address(multicast_ip);

            auto stream = session->create_stream(
                port,
                RTP_FORMAT_H264,
                RCE_SRTP | RCE_SRTP_AUTHENTICATE_RTP | RCE_SRTP_KMNGMNT_USER | RCE_RECEIVE_ONLY);
            if (!stream)
                return;

            stream->add_srtp_ctx(key.data(), salt.data());
            stream->configure_ctx(RCC_REMOTE_SSRC, ssrc);
            stream->set_srtp_roc(roc);
            stream->enable_network_stats(true);

            std::vector<uint8_t> latest_sps, latest_pps, current_au;
            auto start = std::chrono::steady_clock::now();
            int frame_count = 0;

            bool declared_winner = false;

            auto find_first_nalu_type = [](const uint8_t* data, size_t size) -> int {
                ALOGI("find first nalu type");
                int nal_type = -1;
                if (size >= 5 &&
                    data[0] == 0x00 &&
                    data[1] == 0x00 &&
                    ((data[2] == 0x00 && data[3] == 0x01) || data[2] == 0x01)) {
                    int offset = (data[2] == 0x00) ? 4 : 3;
                    nal_type = data[offset] & 0x1F;
                }
                return nal_type;
            };

            while (running_) {
                auto* frame = stream->pull_frame(RECEIVER_WAIT_TIME_MS);
                if (!frame || !frame->payload || frame->payload_len == 0) {
                    if (!active_found_ && std::chrono::steady_clock::now() - start > std::chrono::seconds(5)) {
                        break;
                    }
                    continue;
                }

                if (!active_found_.exchange(true)) {
                    declared_winner = true;
                    ALOGI("[Set multicast] Selected interface: %s", local_ip.c_str());
                }

                if (!declared_winner) {
                    ALOGI("[Set multicast] already selected, dealloc ip %s", local_ip.c_str());
                    uvgrtp::frame::dealloc_frame(frame);
                    break;
                }

                frame_count++;

                if (frame_count % 100 == 0) {
                    auto network_stats = stream->get_network_stats();

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

                int nal_type = find_first_nalu_type(frame->payload, frame->payload_len);
                if (nal_type == -1)
                    continue;
                ALOGI("First 4 bytes of payload: %02x %02x %02x %02x (NAL type: %d)",
                      frame->payload[0], frame->payload[1],
                      frame->payload[2], frame->payload[3],
                      nal_type);

                if (nal_type == 7) {
                    latest_sps.assign(frame->payload, frame->payload + frame->payload_len);
                } else if (nal_type == 8) {
                    latest_pps.assign(frame->payload, frame->payload + frame->payload_len);
                }

                if (nal_type == 5) {
                    std::vector<uint8_t> au;
                    if (!latest_sps.empty())
                        au.insert(au.end(), latest_sps.begin(), latest_sps.end());
                    if (!latest_pps.empty())
                        au.insert(au.end(), latest_pps.begin(), latest_pps.end());
                    au.insert(au.end(), frame->payload, frame->payload + frame->payload_len);
                    callback(au);
                } else if (nal_type == 1) {
                    current_au.insert(current_au.end(), frame->payload, frame->payload + frame->payload_len);
                    callback(current_au);
                    current_au.clear();
                }

                uvgrtp::frame::dealloc_frame(frame);
            }

            if (!current_au.empty()) {
                callback(current_au);
                current_au.clear();
            }

            ALOGI("[Set multicast] no one selected, dealloc ip %s", local_ip.c_str());
            session->destroy_stream(stream);
            ctx.destroy_session(session);
        });
    }
}

void RtpReceiverCore::stop() {
    running_ = false;
    for (auto& t : receiver_threads_) {
        if (t.joinable()) {
            t.join();
        }
    }

    receiver_threads_.clear();
}