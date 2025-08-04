cmake_minimum_required(VERSION 3.14)
project(custom_actions LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

add_executable(custom_actions
        main.cpp
        install_audio.cpp
)

target_link_libraries(custom_actions PRIVATE shell32 user32)
