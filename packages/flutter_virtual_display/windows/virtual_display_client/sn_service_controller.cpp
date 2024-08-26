#include "sn_service_controller.h"
#include <windows.h>

#define SERVICE_NAME L"Viewsonic AirSync Virtual Display Service"

using namespace virtual_display_client;

bool SNServiceController::Start() {
  bool result = false;
  SC_HANDLE scManager = OpenSCManager(NULL, NULL, SC_MANAGER_CONNECT);
  if (!scManager) {
    return result;
  }

  SC_HANDLE scService = OpenService(scManager, SERVICE_NAME, SERVICE_START | SERVICE_QUERY_STATUS);
  if (scService) {
    if (StartService(scService, 0, NULL)) {
      result = true;
    }
    CloseServiceHandle(scService);
  }

  CloseServiceHandle(scManager);
  return result;
}

bool SNServiceController::Stop() {
  bool result = false;
  SC_HANDLE scManager = OpenSCManager(NULL, NULL, SC_MANAGER_CONNECT);
  if (!scManager) {
    return result;
  }

  SC_HANDLE scService = OpenService(scManager, SERVICE_NAME, SERVICE_STOP | SERVICE_QUERY_STATUS);
  if (scService) {
    SERVICE_STATUS serviceStatus;
    if (ControlService(scService, SERVICE_CONTROL_STOP, &serviceStatus)) {
      result = true;
    }
    CloseServiceHandle(scService);
  }

  CloseServiceHandle(scManager);
  return result;
}

bool SNServiceController::IsRunning() {
  bool result = false;

  SC_HANDLE scManager = OpenSCManager(NULL, NULL, SC_MANAGER_CONNECT);
  if (!scManager) {
    return result;
  }

  SC_HANDLE scService = OpenService(scManager, SERVICE_NAME, SERVICE_QUERY_STATUS);
  if (scService) {
    SERVICE_STATUS_PROCESS serviceStatus;
    DWORD bytesNeeded;
    if (QueryServiceStatusEx(scService, SC_STATUS_PROCESS_INFO, (LPBYTE)&serviceStatus, sizeof(SERVICE_STATUS_PROCESS), &bytesNeeded)) {
      if (serviceStatus.dwCurrentState == SERVICE_RUNNING) {
        result = true;
      }
    }
    CloseServiceHandle(scService);
  }

  CloseServiceHandle(scManager);
  return result;
}
