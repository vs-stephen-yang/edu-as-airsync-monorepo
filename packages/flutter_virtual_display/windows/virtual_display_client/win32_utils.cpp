#include "win32_utils.h"

#include <string.h>

typedef LONG(WINAPI* RtlGetVersionPtr)(PRTL_OSVERSIONINFOW);

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

bool Win32Utils::ReadRegistryValue(const wchar_t* sub_key, const wchar_t* value_name, DWORD* value) {
  HKEY hKey;
  LONG result = RegOpenKeyEx(HKEY_LOCAL_MACHINE, sub_key, 0, KEY_READ, &hKey);
  if (result != ERROR_SUCCESS) {
    return false;
  }

  DWORD dwType = REG_DWORD;
  DWORD dwSize = sizeof(DWORD);
  LONG Result = RegQueryValueExW(hKey, value_name, NULL, &dwType, (LPBYTE)value, &dwSize);
  if (ERROR_SUCCESS != Result)
  {
      RegCloseKey(hKey);
      return false;
  }

  RegCloseKey(hKey);
  return true;
}

bool Win32Utils::IsWindows10Version1709OrAbove() {
  RTL_OSVERSIONINFOW osvi = { 0 };
  osvi.dwOSVersionInfoSize = sizeof(osvi);

  // Load the ntdll.dll and get the RtlGetVersion function
  HMODULE ntdll = GetModuleHandleW(L"ntdll.dll");
  if (ntdll) {
    RtlGetVersionPtr pRtlGetVersion = (RtlGetVersionPtr)GetProcAddress(ntdll, "RtlGetVersion");
    if (pRtlGetVersion) {
      pRtlGetVersion(&osvi);
      if (osvi.dwMajorVersion == 10 && osvi.dwMinorVersion == 0) {
        // Windows 10 version 1709 corresponds to build 16299
        return osvi.dwBuildNumber >= 16299;
      }
    }
  }
  return false;
}
