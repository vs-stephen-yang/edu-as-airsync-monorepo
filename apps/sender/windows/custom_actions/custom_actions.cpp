#include "custom_actions.h"
#include <msi.h>
#include <msiquery.h>
#include <windows.h>
#include <map>
#include <string>
#include "install_audio.h"
#include "msi_util.h"
#include "util.h"

// Returns a map of key=value pairs from CustomActionData
static std::map<std::wstring, std::wstring> GetCustomActionProperties(MSIHANDLE hInstall) {
  std::map<std::wstring, std::wstring> props;

  DWORD size = 0;
  UINT res = MsiGetProperty(hInstall, L"CustomActionData", L"", &size);
  if (res != ERROR_MORE_DATA) {
    return props;  // return empty map if property not found
  }

  size++;  // for null terminator
  std::wstring raw(size, L'\0');
  res = MsiGetProperty(hInstall, L"CustomActionData", &raw[0], &size);
  if (res != ERROR_SUCCESS) {
    return props;
  }
  raw.resize(size);

  std::wstringstream ss(raw);
  std::wstring pair;
  while (std::getline(ss, pair, L';')) {
    size_t eq = pair.find(L'=');
    if (eq != std::wstring::npos) {
      std::wstring key = pair.substr(0, eq);
      std::wstring value = pair.substr(eq + 1);
      props[key] = value;
    }
  }

  return props;
}

CUSTOMACTIONS_API UINT __stdcall InstallAudio(MSIHANDLE hInstall) {
  SetLoggingMsiHandle(hInstall);

  auto props = GetCustomActionProperties(hInstall);

  std::wstring devconPath = props[L"DevconPath"];
  std::wstring infPath = props[L"InfPath"];
  std::wstring hwid = props[L"Hwid"];

  if (devconPath.empty() || infPath.empty() || hwid.empty()) {
    LOG() << L"Missing required MSI properties for InstallAudio.";
    return ERROR_INSTALL_FAILURE;
  }

  return InstallAudioDevice(devconPath, infPath, hwid)
             ? ERROR_SUCCESS
             : ERROR_INSTALL_FAILURE;
}

CUSTOMACTIONS_API UINT __stdcall UninstallAudio(MSIHANDLE hInstall) {
  SetLoggingMsiHandle(hInstall);

  auto props = GetCustomActionProperties(hInstall);

  std::wstring devconPath = props[L"DevconPath"];
  std::wstring hwid = props[L"Hwid"];

  if (devconPath.empty() || hwid.empty()) {
    LOG() << L"Missing required MSI properties for UninstallAudio.";
    return ERROR_INSTALL_FAILURE;
  }

  return UninstallAudioDevice(devconPath, hwid)
             ? ERROR_SUCCESS
             : ERROR_INSTALL_FAILURE;
}