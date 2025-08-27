#pragma once
#include <chrono>
#include <cstddef>
#include <cstdint>
#include <utility>
#include <vector>

struct AuBuf {
    std::vector<std::vector<uint8_t>> nals; // 已轉成 Annex-B 的 NALs（含 start-code）
    bool seen_idr = false;
    bool has_vcl = false;
    std::vector<uint8_t> ongoing_fu; // 正在重組的 FU-A（含 start-code + header）
    std::chrono::steady_clock::time_point first_seen;
};

namespace h264 {

    // 傳回此位置的 start code 長度（4 或 3），沒有則回 0
    static inline int start_code_len(const uint8_t* p, size_t n) {
        if (!p)
            return 0;
        if (n >= 4 && p[0] == 0x00 && p[1] == 0x00 && p[2] == 0x00 && p[3] == 0x01)
            return 4;
        if (n >= 3 && p[0] == 0x00 && p[1] == 0x00 && p[2] == 0x01)
            return 3;
        return 0;
    }

    // 嘗試「在任意 buffer 開頭」讀 NAL type（會先跳過 3/4-byte start-code）
    // 讀不到就回 -1
    static inline int nal_type_of_any(const uint8_t* p, size_t n) {
        if (!p || n == 0)
            return -1;
        int scl = start_code_len(p, n);
        if (scl > 0) {
            p += scl;
            n -= (size_t)scl;
        }
        if (n == 0)
            return -1;
        return (int)(p[0] & 0x1F);
    }

    // 掃描 Annex-B buffer，回傳每顆「含 start-code」的 {ptr,len}
    std::vector<std::pair<const uint8_t*, size_t>>
    scan_annexb_nals(const uint8_t* buf, size_t len);

} // namespace h264