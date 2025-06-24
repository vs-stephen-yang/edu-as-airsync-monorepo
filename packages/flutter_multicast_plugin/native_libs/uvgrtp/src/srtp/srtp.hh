#pragma once

#include <mutex>
#include <memory>
#include <unordered_set>
#include <cstdint>

#include "base.hh"
#include "uvgrtp/network_stats.hh"

namespace uvgrtp {

    class SRTPNetworkStats;
    namespace frame {
        struct rtp_frame;
    }

    class srtp : public base_srtp {
        public:
            srtp(int rce_flags);
            ~srtp();

            /* Decrypt the payload of an RTP packet and verify authentication tag (if enabled) */
            rtp_error_t recv_packet_handler(void* args, int rce_flags, uint8_t* read_ptr, size_t size, uvgrtp::frame::rtp_frame** out);

            /* Encrypt the payload of an RTP packet and add authentication tag (if enabled) */
            static rtp_error_t send_packet_handler(void *arg, buf_vec& buffers);

            uint32_t get_local_roc();
            void set_remote_roc(uint32_t roc);

            void enable_network_stats(bool enable = true);
            bool is_network_stats_enabled() const;
            NetworkStatsResult get_network_stats() const;
            void reset_network_stats();

        private:
            /* TODO:  */
            rtp_error_t encrypt(uint32_t ssrc, uint16_t seq, uint8_t* buffer, size_t len);

            /* Has RTP packet authentication been enabled? */
            bool authenticate_rtp() const;

            /* By default RTP packet authentication is disabled but by
             * giving RCE_SRTP_AUTHENTICATE_RTP to create_stream() user can enable it.
             *
             * The authentication tag will occupy the last 8 bytes of the RTP packet */
            bool authenticate_rtp_;

            // 新增統計成員
            std::unique_ptr<SRTPNetworkStats> network_stats_;
    };

    class SRTPNetworkStats
    {
        private:
            mutable std::mutex stats_mutex_;
            std::unordered_set<uint16_t> received_sequences_;
            uint16_t min_seq_;
            uint16_t max_seq_;
            uint32_t seq_cycles_;
            bool seq_initialized_;

            // 統計計數器
            uint32_t total_received_;
            uint32_t size_errors_;
            uint32_t auth_failures_;
            uint32_t replay_attacks_;
            uint32_t decrypt_success_;
            uint32_t duplicate_packets_;
            uint32_t out_of_order_packets_;

            // 限制記憶體使用
            static const size_t MAX_SEQUENCE_HISTORY = 2000;

            // 私有方法
            void update_sequence_range(uint16_t seq);
            bool is_sequence_newer(uint16_t seq1, uint16_t seq2) const;
            bool is_sequence_older(uint16_t seq1, uint16_t seq2) const;
            uint32_t calculate_expected_packets() const;

        public:
            SRTPNetworkStats();
            ~SRTPNetworkStats() = default;

            // 統計記錄方法
            void record_network_received(uint16_t seq);
            void record_size_error(uint16_t seq);
            void record_auth_failed(uint16_t seq);
            void record_replay_packet(uint16_t seq);
            void record_decrypt_success(uint16_t seq);

            // 獲取統計結果
            NetworkStatsResult get_stats() const;
            void reset_stats();
    };
}

namespace uvg_rtp = uvgrtp;
