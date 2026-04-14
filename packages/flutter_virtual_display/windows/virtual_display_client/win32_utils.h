#ifndef WIN32_UTILS_H
#define WIN32_UTILS_H

#include <stdint.h>
#include <windows.h>

namespace virtual_display_client {

#define INVALID_DISPLAY_ID (-1)

class Win32Utils {
 public:
  static int IsMonitorAttached(const wchar_t* device_id);
  static bool ReadRegistryValue(const wchar_t* sub_key, const wchar_t* value_name, DWORD* value);
  static bool IsWindows10Version1709OrAbove();
};

} // namespace virtual_display_client

#endif // WIN32_UTILS_H