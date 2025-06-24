#include "srtp.hh"

#include "uvgrtp/frame.hh"

#include "../debug.hh"
#include "../crypto.hh"
#include "base.hh"
#include "global.hh"

#include <cstring>
#include <iostream>


#define MAX_OFF 10000

uvgrtp::srtp::srtp(int rce_flags):base_srtp(),
      authenticate_rtp_(rce_flags& RCE_SRTP_AUTHENTICATE_RTP),
      network_stats_(nullptr)
{}

uvgrtp::srtp::~srtp()
{}

rtp_error_t uvgrtp::srtp::encrypt(uint32_t ssrc, uint16_t seq, uint8_t *buffer, size_t len)
{
    if (use_null_cipher_)
        return RTP_OK;

    uint8_t iv[UVG_IV_LENGTH] = { 0 };
    uint64_t index = (((uint64_t)local_srtp_ctx_->roc) << 16) + seq;

    // Sequence number has wrapped around, update rollover Counter
    if (seq == 0xffff)
    {
        local_srtp_ctx_->roc++;
        UVG_LOG_DEBUG("SRTP encryption rollover, rollovers so far: %lu", local_srtp_ctx_->roc);
    }

    if (create_iv(iv, ssrc, index, local_srtp_ctx_->salt_key) != RTP_OK) {
        UVG_LOG_ERROR("Failed to create IV, unable to encrypt the RTP packet!");
        return RTP_INVALID_VALUE;
    }

    uvgrtp::crypto::aes::ctr ctr(local_srtp_ctx_->enc_key, local_srtp_ctx_->n_e, iv);
    ctr.encrypt(buffer, buffer, len);

    return RTP_OK;
}

// 修改後的 recv_packet_handler
rtp_error_t uvgrtp::srtp::recv_packet_handler(void *args, int rce_flags, uint8_t *read_ptr, size_t size, uvgrtp::frame::rtp_frame **out)
{
    (void)rce_flags;
    (void)read_ptr;
    (void)size;
    auto srtp = (uvgrtp::srtp *)args;
    auto remote_ctx = srtp->get_remote_ctx();
    auto frame = *out;
    uint16_t seq = frame->header.seq;

    // 新增：網路層統計 - 記錄收到的封包
    if (srtp->network_stats_) {
        srtp->network_stats_->record_network_received(seq);
    }

    if (frame->dgram_size < RTP_HDR_SIZE ||
        (srtp->authenticate_rtp() && frame->dgram_size < RTP_HDR_SIZE + UVG_AUTH_TAG_LENGTH)) {
        UVG_LOG_ERROR("Received SRTP packet that has too small size");
        // 新增：統計大小錯誤
        if (srtp->network_stats_)
        {
            srtp->network_stats_->record_size_error(seq);
        }
        return RTP_GENERIC_ERROR;
    }
    /* Calculate authentication tag for the packet and compare it against the one we received */
    if (srtp->authenticate_rtp()) {
        uint8_t digest[10] = {0};
        auto hmac_sha1 = uvgrtp::crypto::hmac::sha1(remote_ctx->auth_key, UVG_AUTH_LENGTH);
        hmac_sha1.update(frame->dgram, frame->dgram_size - UVG_AUTH_TAG_LENGTH);
        hmac_sha1.update((uint8_t *)&remote_ctx->roc, sizeof(remote_ctx->roc));
        hmac_sha1.final((uint8_t *)digest, UVG_AUTH_TAG_LENGTH);
        if (memcmp(digest, &frame->dgram[frame->dgram_size - UVG_AUTH_TAG_LENGTH], UVG_AUTH_TAG_LENGTH)) {
            UVG_LOG_ERROR("Authentication tag mismatch!");
            // 新增：統計認證失敗
            if (srtp->network_stats_) {
                srtp->network_stats_->record_auth_failed(seq);
            }
            return RTP_GENERIC_ERROR;
        }

        if (srtp->is_replayed_packet(digest)) {
            UVG_LOG_ERROR("Replayed packet received, discarding!");
            // 新增：統計重放攻擊
            if (srtp->network_stats_) {
                srtp->network_stats_->record_replay_packet(seq);
            }
            return RTP_GENERIC_ERROR;
        }
        frame->payload_len -= UVG_AUTH_TAG_LENGTH;
    }

    if (srtp->use_null_cipher()) {
        // 新增：統計解密成功（null cipher 也算成功）
        if (srtp->network_stats_) {
            srtp->network_stats_->record_decrypt_success(seq);
        }
        return RTP_PKT_NOT_HANDLED;
    }

    uint32_t ssrc = frame->header.ssrc;
    uint32_t ts = frame->header.timestamp;
    uint64_t index = 0;

    UVG_LOG_DEBUG("======== SRTP decrypt======== seq = %d, roc= %d", seq, (uint64_t)remote_ctx->roc);
    if (ts == remote_ctx->rts && (uint16_t)(seq + MAX_OFF) < MAX_OFF) {
        index = (((uint64_t)remote_ctx->roc - 1) << 16) + seq;
    } else {
        index = (((uint64_t)remote_ctx->roc) << 16) + seq;
    }

    /* Sequence number has wrapped around, update rollover Counter */
    if (seq == 0xffff) {
        remote_ctx->roc++;
        remote_ctx->rts = ts;
        UVG_LOG_DEBUG("SRTP decryption rollover, rollovers so far: %lu", remote_ctx->roc);
    }

    uint8_t iv[UVG_IV_LENGTH] = {0};

    if (srtp->create_iv(iv, ssrc, index, remote_ctx->salt_key) != RTP_OK) {
        UVG_LOG_ERROR("Failed to create IV, unable to encrypt the RTP packet!");
        return RTP_GENERIC_ERROR;
    }

    uvgrtp::crypto::aes::ctr ctr(remote_ctx->enc_key, remote_ctx->n_e, iv);
    ctr.decrypt(frame->payload, frame->payload, frame->payload_len);

    // 新增：統計解密成功
    if (srtp->network_stats_) {
        srtp->network_stats_->record_decrypt_success(seq);
    }
    return RTP_PKT_MODIFIED;
}

rtp_error_t uvgrtp::srtp::send_packet_handler(void *arg, uvgrtp::buf_vec& buffers)
{
    auto srtp       = (uvgrtp::srtp *)arg;
    auto frame      = (uvgrtp::frame::rtp_frame *)buffers.at(0).second;
    auto local_ctx   = srtp->get_local_ctx();
    auto off        = srtp->authenticate_rtp() ? 2 : 1;
    auto data       = buffers.at(buffers.size() - off);
    auto hmac_sha1  = uvgrtp::crypto::hmac::sha1(local_ctx->auth_key, UVG_AUTH_LENGTH);
    rtp_error_t ret = RTP_OK;

    if (srtp->use_null_cipher())
        goto authenticate;

    ret = srtp->encrypt(
        ntohl(frame->header.ssrc),
        ntohs(frame->header.seq),
        data.second,
        data.first
    );

    if (ret != RTP_OK) {
        UVG_LOG_ERROR("Failed to encrypt RTP packet!");
        return ret;
    }

authenticate:
    if (!srtp->authenticate_rtp())
        return RTP_OK;

    for (size_t i = 0; i < buffers.size() - 1; ++i)
        hmac_sha1.update((uint8_t *)buffers[i].second, buffers[i].first);

    hmac_sha1.update((uint8_t *)&local_ctx->roc, sizeof(local_ctx->roc));
    hmac_sha1.final((uint8_t *)buffers[buffers.size() - 1].second, UVG_AUTH_TAG_LENGTH);

    return ret;
}

bool uvgrtp::srtp::authenticate_rtp() const
{
    return authenticate_rtp_;
}

uint32_t uvgrtp::srtp::get_local_roc()
{
    return get_local_ctx()->roc;
}

void uvgrtp::srtp::set_remote_roc(uint32_t roc)
{
    remote_srtp_ctx_->roc = roc;
}

namespace uvgrtp
{
    SRTPNetworkStats::SRTPNetworkStats()
        : min_seq_(0), max_seq_(0), seq_cycles_(0), seq_initialized_(false),
          total_received_(0), size_errors_(0), auth_failures_(0),
          replay_attacks_(0), decrypt_success_(0), duplicate_packets_(0),
          out_of_order_packets_(0)
    {
    }

    void SRTPNetworkStats::record_network_received(uint16_t seq)
    {
        std::lock_guard<std::mutex> lock(stats_mutex_);

        // 檢查重複封包
        if (received_sequences_.find(seq) != received_sequences_.end())
        {
            duplicate_packets_++;
            UVG_LOG_DEBUG("Network duplicate packet: seq %u", seq);
            return;
        }

        received_sequences_.insert(seq);
        total_received_++;

        if (!seq_initialized_)
        {
            min_seq_ = seq;
            max_seq_ = seq;
            seq_cycles_ = 0;
            seq_initialized_ = true;
            UVG_LOG_DEBUG("Network stats: first packet seq %u", seq);
            return;
        }

        update_sequence_range(seq);

        // 限制記憶體使用
        if (received_sequences_.size() > MAX_SEQUENCE_HISTORY)
        {
            auto it = received_sequences_.begin();
            for (size_t i = 0; i < MAX_SEQUENCE_HISTORY / 4 && it != received_sequences_.end(); ++i)
            {
                it = received_sequences_.erase(it);
            }
        }
    }

    void SRTPNetworkStats::update_sequence_range(uint16_t seq)
    {
        bool is_newer = is_sequence_newer(seq, max_seq_);
        bool is_older = is_sequence_older(seq, min_seq_);

        if (is_newer)
        {
            // 檢查序列號回捲
            if (seq < max_seq_ && (max_seq_ - seq) > 32768)
            {
                seq_cycles_++;
                UVG_LOG_DEBUG("Network stats: sequence wraparound %u -> %u (cycle %u)",
                              max_seq_, seq, seq_cycles_);
            }
            max_seq_ = seq;
        }
        else if (is_older)
        {
            min_seq_ = seq;
        }
        else
        {
            // 範圍內的封包，檢查是否亂序
            if (seq != max_seq_)
            {
                out_of_order_packets_++;
                UVG_LOG_DEBUG("Network stats: out-of-order packet seq %u (max: %u)",
                              seq, max_seq_);
            }
        }
    }

    bool SRTPNetworkStats::is_sequence_newer(uint16_t seq1, uint16_t seq2) const
    {
        return ((seq1 > seq2) && (seq1 - seq2 < 32768)) ||
               ((seq1 < seq2) && (seq2 - seq1 > 32768));
    }

    bool SRTPNetworkStats::is_sequence_older(uint16_t seq1, uint16_t seq2) const
    {
        return ((seq1 < seq2) && (seq2 - seq1 < 32768)) ||
               ((seq1 > seq2) && (seq1 - seq2 > 32768));
    }

    uint32_t SRTPNetworkStats::calculate_expected_packets() const
    {
        if (!seq_initialized_)
        {
            return 0;
        }

        // 計算擴展序列號範圍
        uint32_t extended_max = (seq_cycles_ << 16) | max_seq_;
        uint32_t extended_min = min_seq_; // min 總是在第一個 cycle

        if (seq_cycles_ > 0)
        {
            return extended_max - extended_min + 1;
        }
        else
        {
            if (max_seq_ >= min_seq_)
            {
                return max_seq_ - min_seq_ + 1;
            }
            else
            {
                // 單一 cycle 內的回捲
                return (65536 - min_seq_) + max_seq_ + 1;
            }
        }
    }

    void SRTPNetworkStats::record_size_error(uint16_t seq)
    {
        std::lock_guard<std::mutex> lock(stats_mutex_);
        size_errors_++;
        UVG_LOG_DEBUG("Network stats: size error for seq %u", seq);
    }

    void SRTPNetworkStats::record_auth_failed(uint16_t seq)
    {
        std::lock_guard<std::mutex> lock(stats_mutex_);
        auth_failures_++;
        UVG_LOG_DEBUG("Network stats: auth failed for seq %u", seq);
    }

    void SRTPNetworkStats::record_replay_packet(uint16_t seq)
    {
        std::lock_guard<std::mutex> lock(stats_mutex_);
        replay_attacks_++;
        UVG_LOG_DEBUG("Network stats: replay attack for seq %u", seq);
    }

    void SRTPNetworkStats::record_decrypt_success(uint16_t seq)
    {
        std::lock_guard<std::mutex> lock(stats_mutex_);
        decrypt_success_++;
        UVG_LOG_DEBUG("Network stats: decrypt success for seq %u", seq);
    }

    NetworkStatsResult SRTPNetworkStats::get_stats() const
    {
        std::lock_guard<std::mutex> lock(stats_mutex_);

        NetworkStatsResult result;
        result.network_received = total_received_;
        result.size_errors = size_errors_;
        result.auth_failures = auth_failures_;
        result.replay_attacks = replay_attacks_;
        result.decrypt_success = decrypt_success_;
        result.duplicate_packets = duplicate_packets_;
        result.out_of_order_packets = out_of_order_packets_;

        if (!seq_initialized_ || total_received_ == 0)
        {
            result.network_expected = 0;
            result.network_lost = 0;
            result.network_loss_rate = 0.0;
        }
        else
        {
            result.network_expected = calculate_expected_packets();

            if (result.network_expected > total_received_)
            {
                result.network_lost = result.network_expected - total_received_;
            }
            else
            {
                result.network_lost = 0;
            }

            if (result.network_expected > 0)
            {
                result.network_loss_rate = (static_cast<double>(result.network_lost) /
                                            result.network_expected) *
                                           100.0;
            }
            else
            {
                result.network_loss_rate = 0.0;
            }
        }

        return result;
    }

    void SRTPNetworkStats::reset_stats()
    {
        std::lock_guard<std::mutex> lock(stats_mutex_);

        received_sequences_.clear();
        min_seq_ = 0;
        max_seq_ = 0;
        seq_cycles_ = 0;
        seq_initialized_ = false;

        total_received_ = 0;
        size_errors_ = 0;
        auth_failures_ = 0;
        replay_attacks_ = 0;
        decrypt_success_ = 0;
        duplicate_packets_ = 0;
        out_of_order_packets_ = 0;

        UVG_LOG_DEBUG("Network stats reset");
    }

    // srtp 類別的方法實作
    void srtp::enable_network_stats(bool enable)
    {
        if (enable && !network_stats_)
        {
            network_stats_ = std::make_unique<SRTPNetworkStats>();
            UVG_LOG_INFO("Network statistics enabled");
        }
        else if (!enable)
        {
            network_stats_.reset();
            UVG_LOG_INFO("Network statistics disabled");
        }
    }

    bool srtp::is_network_stats_enabled() const
    {
        return network_stats_ != nullptr;
    }

    NetworkStatsResult srtp::get_network_stats() const
    {
        if (network_stats_)
        {
            return network_stats_->get_stats();
        }

        // 回傳空的結果
        NetworkStatsResult empty_result = {};
        return empty_result;
    }

    void srtp::reset_network_stats()
    {
        if (network_stats_)
        {
            network_stats_->reset_stats();
        }
    }
}