#ifndef WIN32_UTILS_H
#define WIN32_UTILS_H

#include <stdint.h>

namespace virtual_display_client {

#define INVALID_DISPLAY_ID (-1)

class Win32Utils {
 public:
  static int IsMonitorAttached(const wchar_t* device_id);
};

} // namespace virtual_display_client

#endif // WIN32_UTILS_H