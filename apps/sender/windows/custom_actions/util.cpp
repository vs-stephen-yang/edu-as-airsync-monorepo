#include <windows.h>

#include <msi.h>
#include <msiquery.h>
#include <sstream>
#include <string>
#include "msi_util.h"

// thread_local so it's safe per thread
thread_local MSIHANDLE g_hInstall = 0;

// Setter for MSI handle
void SetLoggingMsiHandle(MSIHANDLE hInstall) {
  g_hInstall = hInstall;
}

// internal helper
void LogOutput(const std::wstring& msg) {
  if (g_hInstall != 0) {
    // Running inside MSI: log using MsiProcessMessage
    MSIHANDLE hRecord = MsiCreateRecord(1);
    if (hRecord) {
      MsiRecordSetStringW(hRecord, 0, msg.c_str());
      MsiProcessMessage(g_hInstall, INSTALLMESSAGE_INFO, hRecord);
      MsiCloseHandle(hRecord);
    }
  } else {
    // Fallback: console output (e.g. test harness)
    wprintf(L"%ls\n", msg.c_str());
  }
}
