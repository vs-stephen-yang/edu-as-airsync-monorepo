#include "install_audio.h"
#include <atlbase.h>  // CComHeapPtr
#include <comdef.h>
#include <endpointvolume.h>
#include <mmdeviceapi.h>
#include <newdev.h>
#include <setupapi.h>
#include <windows.h>
#include <wrl/client.h>
#include <array>
#include <iostream>
#include <string>
#include <vector>
#include "PolicyConfig.h"
#include "util.h"

#pragma comment(lib, "setupapi.lib")
#pragma comment(lib, "newdev.lib")

using Microsoft::WRL::ComPtr;
using DeviceIdArray = std::array<std::wstring, ERole_enum_count>;

constexpr std::array<ERole, ERole_enum_count> AllRoles() {
  return {eConsole, eMultimedia, eCommunications};
}

static const int kRestoreAfterInstallDelayMs = 2 * 1000;
static const int kRestoreRetryDelayMs = 1 * 1000;
static const int kRestoreRetryAttemps = 5;
static const int kProcessWaitTimeoutMs = 30 * 1000;

static bool RunCmd(const std::wstring& cmdPath, const std::wstring& args);

static bool DevconUpdate(const std::wstring& devconPath, const std::wstring& infPath, const std::wstring& hwid);
static bool DevconInstall(const std::wstring& devconPath, const std::wstring& infPath, const std::wstring& hwid);
static bool DevconRemove(const std::wstring& devconPath, const std::wstring& hwid);

static void RestoreDefaultAudioDevice(
    ComPtr<IPolicyConfigVista> policyConfig,
    const DeviceIdArray& originalDeviceIds);

static bool TryRestoreDefaultAudioDevice(
    ComPtr<IPolicyConfigVista> policyConfig,
    const DeviceIdArray& originalDeviceIds);

static bool IsDefaultAudioRestored(const DeviceIdArray& original);

static std::wstring GetDefaultAudioDeviceId(EDataFlow dataFlow, ERole role);

static DeviceIdArray GetDefaultAudioDeviceIds(EDataFlow dataFlow) {
  DeviceIdArray deviceIds;

  for (auto role : AllRoles()) {
    deviceIds[role] = GetDefaultAudioDeviceId(dataFlow, role);
  }
  return deviceIds;
}

// Helper to get current default audio device ID
static std::wstring GetDefaultAudioDeviceId(EDataFlow dataFlow, ERole role) {
  ComPtr<IMMDeviceEnumerator> enumerator;

  HRESULT hr = CoCreateInstance(__uuidof(MMDeviceEnumerator), NULL, CLSCTX_ALL, IID_PPV_ARGS(&enumerator));
  if (FAILED(hr)) {
    LOG() << L"CoCreateInstance failed: " << hr;
    return L"";
  }

  ComPtr<IMMDevice> device;
  hr = enumerator->GetDefaultAudioEndpoint(dataFlow, role, &device);
  if (FAILED(hr)) {
    LOG() << L"GetDefaultAudioEndpoint failed: " << hr;
    return L"";
  }

  CComHeapPtr<WCHAR> deviceId;

  hr = device->GetId(&deviceId);
  if (FAILED(hr)) {
    LOG() << L"GetId failed: " << hr;
    return L"";
  }

  return std::wstring(deviceId);
}

static bool TryRestoreDefaultAudioDevice(
    ComPtr<IPolicyConfigVista> policyConfig,
    const DeviceIdArray& originalDeviceIds) {
  for (int attempt = 0; attempt < kRestoreRetryAttemps; ++attempt) {
    RestoreDefaultAudioDevice(policyConfig, originalDeviceIds);

    if (IsDefaultAudioRestored(originalDeviceIds)) {
      return true;
    }

    Sleep(kRestoreRetryDelayMs);
  }

  LOG() << L"Failed to restore defaults after " << kRestoreRetryAttemps << L" attempts.";

  return false;
}

static void RestoreDefaultAudioDevice(
    ComPtr<IPolicyConfigVista> policyConfig,
    const DeviceIdArray& originalDeviceIds) {
  for (auto role : AllRoles()) {
    if (!originalDeviceIds[role].empty()) {
      LOG() << L"Restoring default audio device [Role " << role << "] to " << originalDeviceIds[role];

      HRESULT hr = policyConfig->SetDefaultEndpoint(originalDeviceIds[role].c_str(), role);

      if (FAILED(hr)) {
        LOG() << L"SetDefaultEndpoint failed: " << hr;
      }
    }
  }
}

static bool IsDefaultAudioRestored(const DeviceIdArray& original) {
  DeviceIdArray current = GetDefaultAudioDeviceIds(eRender);

  return current == original;
}

bool InstallAudioDevice(const std::wstring& devconPath, const std::wstring& infPath, const std::wstring& hwid) {
  try {
    // Step 1: Get current default audio device
    const DeviceIdArray originalDeviceIds = GetDefaultAudioDeviceIds(eRender);
    for (auto role : AllRoles()) {
      LOG() << L"Original default audio device [Role " << role << "]:" << originalDeviceIds[role];
    }

    // Step 2: Try to update virtual audio driver
    if (!DevconUpdate(devconPath, infPath, hwid)) {
      // If update fails (device missing), tries to install.
      if (!DevconInstall(devconPath, infPath, hwid)) {
        LOG() << L"Installing audio driver failed.";
      }
    }

    // Step 3: Restore defaults for all roles
    ComPtr<IPolicyConfigVista> policyConfig;

    HRESULT hr = CoCreateInstance(__uuidof(CPolicyConfigVistaClient),
                                  NULL, CLSCTX_ALL, __uuidof(IPolicyConfigVista), (LPVOID*)&policyConfig);

    if (!policyConfig) {
      LOG() << L"CreatePolicyConfig failed.";
      return false;
    }

    // Give Windows enough time to finish registering the new device before switching defaults back.
    Sleep(kRestoreAfterInstallDelayMs);

    return TryRestoreDefaultAudioDevice(policyConfig, originalDeviceIds);

  } catch (const std::runtime_error& e) {
    LOG() << "Exception occurred in InstallAudioDevice: " << e.what();
    return false;
  }
}

bool UninstallAudioDevice(const std::wstring& devconPath, const std::wstring& hwid) {
  try {
    return DevconRemove(devconPath, hwid);
  } catch (const std::runtime_error& e) {
    LOG() << "Exception occurred in UninstallAudioDevice: " << e.what();
    return false;
  }
}

static bool DevconUpdate(const std::wstring& devconPath, const std::wstring& infPath, const std::wstring& hwid) {
  // devcon update airsyncaudio.inf Root\AirSyncAudio
  // Looks for existing devices in the system that match the provided hardware ID.
  // If found, updates their drivers using the given .inf.
  // Does not create new devices — if no existing device is found, nothing happens.
  std::wstring args = L"update \"" + infPath + L"\" \"" + hwid + L"\"";

  return RunCmd(devconPath, args);
}

static bool DevconInstall(const std::wstring& devconPath, const std::wstring& infPath, const std::wstring& hwid) {
  // devcon install airsyncaudio.inf Root\AirSyncAudio
  // Creates a new device instance for the given hardware ID, regardless of whether one already exists.
  // If a device with the same HWID already exists, you end up with two instances of the same device in Device Manager.
  std::wstring args = L"install \"" + infPath + L"\" \"" + hwid + L"\"";

  return RunCmd(devconPath, args);
}

static bool DevconRemove(const std::wstring& devconPath, const std::wstring& hwid) {
  // devcon remove Root\AirSyncAudio
  std::wstring args = L"remove \"" + hwid + L"\"";

  return RunCmd(devconPath, args);
}

bool RunCmd(const std::wstring& cmdPath, const std::wstring& args) {
  std::wstring cmd = L"\"" + cmdPath + L"\" " + args;

  LOG() << L"Running " << cmd;

  STARTUPINFOW si = {sizeof(si)};
  PROCESS_INFORMATION pi;

  if (!CreateProcessW(
          nullptr,
          cmd.data(),  // mutable string buffer
          nullptr,
          nullptr,
          FALSE,
          0,
          nullptr,
          nullptr,
          &si,
          &pi)) {
    LOG() << L"CreateProcess failed. Error: " << GetLastError();
    throw std::runtime_error("CreateProcess failed.");
  }

  DWORD waitResult = WaitForSingleObject(pi.hProcess, kProcessWaitTimeoutMs);
  if (waitResult == WAIT_TIMEOUT) {
    LOG() << L"Process timed out after " << kProcessWaitTimeoutMs << L" ms.";
    TerminateProcess(pi.hProcess, 1);
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
    throw std::runtime_error("Process timed out.");
  }

  DWORD exitCode = 1;
  GetExitCodeProcess(pi.hProcess, &exitCode);

  CloseHandle(pi.hProcess);
  CloseHandle(pi.hThread);

  LOG() << L"Exit code: " << exitCode;

  return (exitCode == 0);
}