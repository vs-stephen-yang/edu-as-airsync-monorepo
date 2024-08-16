cmake_minimum_required(VERSION 3.14)

set(PROJECT_NAME "flutter_virtual_display")
project(${PROJECT_NAME} LANGUAGES CXX)

cmake_policy(VERSION 3.14...3.25)

set(PLUGIN_NAME "flutter_virtual_display_plugin")

list(APPEND PLUGIN_SOURCES
  "flutter_common.cpp"
  "flutter_common.h"
  "flutter_virtual_display_plugin.cpp"
  "flutter_virtual_display_plugin.h"
  "flutter_virtual_display.cpp"
  "flutter_virtual_display.h"
)

add_subdirectory(virtual_display_client)

add_library(${PLUGIN_NAME} SHARED
  "include/flutter_virtual_display/flutter_virtual_display_plugin_c_api.h"
  "flutter_virtual_display_plugin_c_api.cpp"
  ${PLUGIN_SOURCES}
)

apply_standard_settings(${PLUGIN_NAME})

set_target_properties(${PLUGIN_NAME} PROPERTIES CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include")

target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin virtual_display_client ws2_32)

# bundle services
set(flutter_virtual_display_bundled_services
  "${CMAKE_CURRENT_SOURCE_DIR}/virtual-display-service-bin/x64/Release/virtual-display-service.exe"
  PARENT_SCOPE
)

# bundle drivers
set(flutter_virtual_display_bundled_drivers
  "${CMAKE_CURRENT_SOURCE_DIR}/indirect-display/indirect_display_1_2/x64/indirect_display_1_2.cat"
  "${CMAKE_CURRENT_SOURCE_DIR}/indirect-display/indirect_display_1_2/x64/indirect_display_1_2.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/indirect-display/indirect_display_1_2/x64/indirect_display_1_2.inf"
  PARENT_SCOPE
)
