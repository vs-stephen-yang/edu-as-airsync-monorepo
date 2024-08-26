cmake_minimum_required(VERSION 3.14)

add_library(virtual_display_client STATIC
        "sa_net_protocol.cpp"
        "sa_net_protocol.h"
        "sn_client.cpp"
        "sn_client.h"
        "tcp_client.h"
        "tcp_client.cpp"
        "win32_utils.h"
        "win32_utils.cpp"
        "spacedeskNetProtocolSmpl.h")

target_include_directories(virtual_display_client PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
