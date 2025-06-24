#include "rtp_receiver_core.h"
#include "log.h"
#include <uvgrtp/lib.hh>
#include <cstring>
#include <iostream>

constexpr int RECEIVER_WAIT_TIME_MS = 100;

RtpReceiverCore::RtpReceiverCore() : running_(false) {}

RtpReceiverCore::~RtpReceiverCore()
{
    stop();
}

void RtpReceiverCore::start(const std::string &ip, int port, std::vector<uint8_t> &key, std::vector<uint8_t> &salt, uint32_t ssrc, uint32_t roc, AUCallback callback)
{
    if (running_)
        return;

    running_ = true;

    receiver_thread_ = std::thread([key, salt, ip, port, ssrc, roc, callback, this]() mutable
                                   {
        uvgrtp::context ctx;
        auto session = ctx.create_session(ip);
        auto stream = session->create_stream(port, RTP_FORMAT_H264, RCE_SRTP | RCE_SRTP_KMNGMNT_USER | RCE_RECEIVE_ONLY);
        if (!stream) {
            return;
        }

        stream->add_srtp_ctx(key.data(), salt.data());
        stream->configure_ctx(RCC_REMOTE_SSRC, ssrc);
        stream->set_srtp_roc(roc);
       stream->enable_network_stats(true);

        std::vector<uint8_t> latest_sps, latest_pps, current_au;
        uint32_t frame_count = 0;

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
                continue;
            }

            frame_count++;

            // 新增：每100個 frame 輸出網路統計
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
            if (nal_type == -1) continue;
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
                if (!latest_sps.empty()) au.insert(au.end(), latest_sps.begin(), latest_sps.end());
                if (!latest_pps.empty()) au.insert(au.end(), latest_pps.begin(), latest_pps.end());
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

        session->destroy_stream(stream);
        ctx.destroy_session(session); });
}

void RtpReceiverCore::stop()
{
    running_ = false;
    if (receiver_thread_.joinable())
        receiver_thread_.join();
}