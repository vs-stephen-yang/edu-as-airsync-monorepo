#pragma once
#include <windows.h>
#include <sstream>

// internal helper
inline void LogOutput(const std::wstring& msg) {
  wprintf((msg + L"\n").c_str());
}

// macro: each call gets its own local stringstream
#define LOG()                                                                \
  for (bool _once = true; _once; _once = false)                              \
    for (std::wstringstream _ss; _once; LogOutput(_ss.str()), _once = false) \
  _ss