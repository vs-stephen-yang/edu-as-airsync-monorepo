#ifndef VIRTUAL_DISPLAY_STATE_WATCHER_H
#define VIRTUAL_DISPLAY_STATE_WATCHER_H

#include <stdint.h>
#define VIRTUAL_DISPLAY_ATTACH_DETACH_WAITER_TIMEOUT_MS 5000

namespace virtual_display_client {

class VirtualDisplayStateWatcher {
 public:
  static int WaitForAttach(const wchar_t* device_id, int timeout_ms = VIRTUAL_DISPLAY_ATTACH_DETACH_WAITER_TIMEOUT_MS);
  static bool WaitForDetach(const wchar_t* device_id, int timeout_ms = VIRTUAL_DISPLAY_ATTACH_DETACH_WAITER_TIMEOUT_MS);
};

} // namespace virtual_display_client

#endif //VIRTUAL_DISPLAY_STATE_WATCHER_H