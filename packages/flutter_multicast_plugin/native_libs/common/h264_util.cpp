#include "h264_util.h"

namespace h264 {

    std::vector<std::pair<const uint8_t*, size_t>> scan_annexb_nals(const uint8_t* buf, size_t len) {
        std::vector<std::pair<const uint8_t*, size_t>> out;
        if (!buf || len < 4)
            return out;

        // 尋找第一個 start-code
        size_t i = 0;
        for (; i + 3 < len; ++i) {
            if (start_code_len(buf + i, len - i))
                break;
        }
        if (i + 3 >= len)
            return out;

        // 逐顆切
        while (i < len) {
            int sc = start_code_len(buf + i, len - i);
            if (sc == 0)
                break; // 找不到下一顆的開頭

            size_t nal_start = i; // 含 start-code
            size_t payload = i + (size_t)sc;

            // 找下一個 start-code，payload..j 之間是這顆 NAL 內容
            size_t j = payload;
            while (j + 3 < len && start_code_len(buf + j, len - j) == 0) {
                ++j;
            }
            size_t nal_end = (j + 3 < len) ? j : len;

            if (payload < nal_end) {
                out.emplace_back(buf + nal_start, nal_end - nal_start);
            }

            if (j + 3 >= len)
                break; // 沒下一個 start-code 了
            i = j;     // 從下一個 start-code 繼續
        }

        return out;
    }

} // namespace h264