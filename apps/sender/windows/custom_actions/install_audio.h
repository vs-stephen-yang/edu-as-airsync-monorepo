#pragma once
#include <string>

bool InstallAudioDevice(const std::wstring& devconPath, const std::wstring& infPath, const std::wstring& hwid);

bool UninstallAudioDevice(const std::wstring& devconPath, const std::wstring& hwid);