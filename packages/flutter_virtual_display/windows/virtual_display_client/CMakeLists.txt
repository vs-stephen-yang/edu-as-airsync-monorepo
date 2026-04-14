cmake_minimum_required(VERSION 3.14)

add_library(virtual_display_client STATIC
        "sa_net_protocol.cpp"
        "sa_net_protocol.h"
        "sn_client.cpp"
        "sn_client.h"
        "sn_error.cpp"
        "sn_error.h"
        "sn_service_controller.cpp"
        "sn_service_controller.h"
        "tcp_client.h"
        "tcp_client.cpp"
        "spacedeskNetProtocolSmpl.h"
        "win32_utils.cpp"
        "win32_utils.h")

target_include_directories(virtual_display_client PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
