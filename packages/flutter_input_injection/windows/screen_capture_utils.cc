#include "screen_capture_utils.h"
#include <windows.h>

#define VIEWSONIC_VIRTUAL_DISPLAY_DEVICE_ID L"VID_VIEWSONIC_PID_INDIRECT_DISPLAY_VIRTUAL_DISPLAY_0003"

ScreenId GetPrimaryScreen() {
  DISPLAY_DEVICEW device;
  device.cb = sizeof(device);
  DWORD iDevNum = 0;
  while (EnumDisplayDevicesW(NULL, iDevNum, &device, 0)) {
    if (device.StateFlags & DISPLAY_DEVICE_PRIMARY_DEVICE) {
      return iDevNum;
    }
    iDevNum++;
  }
  return kInvalidScreenId;
}

ScreenId GetVirtualScreen() {
  DISPLAY_DEVICEW device;
  device.cb = sizeof(device);
  DWORD iDevNum = 0;
  while (EnumDisplayDevicesW(NULL, iDevNum, &device, 0)) {
    if (device.StateFlags & DISPLAY_DEVICE_ACTIVE) {
      if (wcsstr(device.DeviceID, VIEWSONIC_VIRTUAL_DISPLAY_DEVICE_ID) != NULL) {
        return iDevNum;
      }
    }
    iDevNum++;
  }
  return kInvalidScreenId;
}

DesktopRect GetScreenRect(const ScreenId screen) {
  if (screen == kInvalidScreenId) {
    return DesktopRect();
  }

  DISPLAY_DEVICEW device;
  device.cb = sizeof(device);
  BOOL result = EnumDisplayDevicesW(NULL, (DWORD)screen, &device, 0);
  if (!result) {
    return DesktopRect();
  }

  DEVMODEW device_mode;
  device_mode.dmSize = sizeof(device_mode);
  device_mode.dmDriverExtra = 0;
  result = EnumDisplaySettingsExW(device.DeviceName, ENUM_CURRENT_SETTINGS,
                                  &device_mode, 0);
  if (!result) {
    return DesktopRect();
  }

  return DesktopRect::MakeXYWH(
      device_mode.dmPosition.x, device_mode.dmPosition.y,
      device_mode.dmPelsWidth, device_mode.dmPelsHeight);
}
