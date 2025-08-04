#pragma once
#include <sstream>
#include <string>

void LogOutput(const std::wstring& msg);

// macro: each call gets its own local stringstream
#define LOG()                                                                \
  for (bool _once = true; _once; _once = false)                              \
    for (std::wstringstream _ss; _once; LogOutput(_ss.str()), _once = false) \
  _ss