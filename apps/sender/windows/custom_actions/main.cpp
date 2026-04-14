#include <windows.h>
#include <iostream>
#include <string>
#include <vector>

#include "install_audio.h"
#include "util.h"

int wmain(int argc, wchar_t* argv[]) {
  HRESULT hr = CoInitialize(NULL);

  if (FAILED(hr)) {
    LOG() << L"CoInitialize failed: " << hr;
    return -1;
  }

  if (argc <= 1) {
    return -1;
  }

  std::wstring cmd = argv[1];

  if (cmd == L"install-audio") {
    if (argc != 5) {
      LOG() << L"Usage: install-audio devconPath infPath hwid";

      return -1;
    }
    std::wstring devconPath = argv[2];
    std::wstring infPath = argv[3];
    std::wstring hwid = argv[4];

    LOG() << L"Installing virtual audio device";

    InstallAudioDevice(devconPath, infPath, hwid);
  } else if (cmd == L"uninstall-audio") {
    if (argc != 4) {
      LOG() << L"Usage: uninstall-audio devconPath hwid";
      return -1;
    }

    std::wstring devconPath = argv[2];
    std::wstring hwid = argv[3];

    LOG() << L"Uninstalling virtual audio device";

    UninstallAudioDevice(devconPath, hwid);
  } else {
    LOG() << L"Unknown command: " << cmd;
  }

  return 0;
}