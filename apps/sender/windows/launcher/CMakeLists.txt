cmake_minimum_required(VERSION 3.14)
project(launcher LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

add_executable(launcher WIN32
        resource.h
        app.rc
        main.cpp)

target_link_libraries(launcher PRIVATE shell32 user32)
