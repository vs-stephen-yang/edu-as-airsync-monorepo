#pragma once

#include <cstdint>

namespace uvgrtp {
    struct NetworkStatsResult {
        uint32_t network_received;
        uint32_t network_expected;
        uint32_t network_lost;
        double network_loss_rate;
        uint32_t size_errors;
        uint32_t auth_failures;
        uint32_t replay_attacks;
        uint32_t decrypt_success;
        uint32_t duplicate_packets;
        uint32_t out_of_order_packets;
    };
} // namespace uvgrtp