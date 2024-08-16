#include "virtual_display_state_watcher.h"
#include "win32_utils.h"

#include <thread>
#include <chrono>

using namespace virtual_display_client;

int VirtualDisplayStateWatcher::WaitForAttach(const wchar_t* device_id, int timeout_ms) {
  auto start_time = std::chrono::steady_clock::now();
  int device_index = INVALID_DISPLAY_ID;

  while (true) {
    device_index = Win32Utils::IsMonitorAttached(device_id);
    if (device_index != INVALID_DISPLAY_ID) {
      return device_index;
    }

    auto current_time = std::chrono::steady_clock::now();
    auto elapsed_time = std::chrono::duration_cast<std::chrono::milliseconds>(current_time - start_time).count();

    if (elapsed_time >= timeout_ms) {
      break;
    }

    std::this_thread::sleep_for(std::chrono::milliseconds(100));
  }

  return device_index;
}

bool VirtualDisplayStateWatcher::WaitForDetach(const wchar_t* device_id, int timeout_ms) {
  int device_index = Win32Utils::IsMonitorAttached(device_id);
  if (device_index == INVALID_DISPLAY_ID) {
    return true;
  }

  auto start_time = std::chrono::steady_clock::now();
  while (true) {
    device_index = Win32Utils::IsMonitorAttached(device_id);
    if (device_index == INVALID_DISPLAY_ID) {
      return true;
    }

    auto current_time = std::chrono::steady_clock::now();
    auto elapsed_time = std::chrono::duration_cast<std::chrono::milliseconds>(current_time - start_time).count();

    if (elapsed_time >= timeout_ms) {
      break;
    }

    std::this_thread::sleep_for(std::chrono::milliseconds(100));
  }

  return false;
}
