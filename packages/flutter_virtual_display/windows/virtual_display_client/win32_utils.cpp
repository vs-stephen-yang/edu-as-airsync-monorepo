#include "win32_utils.h"

#include <string.h>
#include <windows.h>

using namespace virtual_display_client;

int Win32Utils::IsMonitorAttached(const wchar_t* device_id) {
  if (device_id == nullptr) {
    return INVALID_DISPLAY_ID;
  }
  DISPLAY_DEVICE dd;
  dd.cb = sizeof(DISPLAY_DEVICE);
  DWORD deviceNum = 0;
  while (EnumDisplayDevices(NULL, deviceNum, &dd, 0)) {
	if (dd.StateFlags & DISPLAY_DEVICE_ACTIVE) {
      if (dd.DeviceID == nullptr) {
        continue;
      }
      if (wcsstr(dd.DeviceID, device_id) != nullptr) {
        return (int)deviceNum;
      }
	}
	deviceNum++;
  }
  return INVALID_DISPLAY_ID;
}
