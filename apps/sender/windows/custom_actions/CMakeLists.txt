cmake_minimum_required(VERSION 3.15)

project(custom_actions LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# =====================================================
# Build a static library with shared implementation
# =====================================================
add_library(custom_actions_core STATIC
        install_audio.cpp
        util.cpp
)

# Force static CRT (/MT or /MTd)
set_property(TARGET custom_actions_core PROPERTY
        MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

target_include_directories(custom_actions_core PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(custom_actions_core
        PRIVATE
        msi)

# =====================================================
# Build the Custom Actions DLL
# =====================================================
add_library(custom_actions SHARED
        custom_actions.cpp # DLL entry points
)

# Force static CRT (/MT or /MTd)
set_property(TARGET custom_actions PROPERTY
        MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

target_link_libraries(custom_actions
        PRIVATE
        custom_actions_core
        msi)

target_compile_definitions(custom_actions PRIVATE
        UNICODE _UNICODE
        CUSTOMACTIONS_EXPORTS
)

# =====================================================
# Build a Test Harness EXE
# =====================================================
add_executable(custom_actions_test
        main.cpp # Console test driver
)

# Force static CRT (/MT or /MTd)
set_property(TARGET custom_actions_test PROPERTY
        MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
target_link_libraries(custom_actions_test
        PRIVATE
        custom_actions_core)
