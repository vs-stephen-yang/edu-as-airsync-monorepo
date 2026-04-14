#include <windows.h>
#include <wlanapi.h>
#include <memory>
#include <string>

#pragma comment(lib, "wlanapi.lib")
#pragma comment(lib, "ole32.lib")

int GetWifiSignalStrength() {
    HANDLE hClient = NULL;
    DWORD dwMaxClient = 2;
    DWORD dwCurVersion = 0;
    DWORD dwResult = 0;

    dwResult = WlanOpenHandle(dwMaxClient, NULL, &dwCurVersion, &hClient);
    if (dwResult != ERROR_SUCCESS) {
        return -1;
//        return "Error: WlanOpenHandle failed";
    }

    PWLAN_INTERFACE_INFO_LIST pIfList = NULL;
    dwResult = WlanEnumInterfaces(hClient, NULL, &pIfList);
    if (dwResult != ERROR_SUCCESS) {
        WlanCloseHandle(hClient, NULL);
        return -1;
//        return "Error: WlanEnumInterfaces failed";
    }

    int signalQuality = -1;
    for (int i = 0; i < (int)pIfList->dwNumberOfItems; i++) {
        PWLAN_AVAILABLE_NETWORK_LIST pBssList = NULL;
        dwResult = WlanGetAvailableNetworkList(
                hClient, &pIfList->InterfaceInfo[i].InterfaceGuid,
                0, NULL, &pBssList);

        if (dwResult == ERROR_SUCCESS) {
            for (int j = 0; j < (int)pBssList->dwNumberOfItems; j++) {
                WLAN_AVAILABLE_NETWORK network = pBssList->Network[j];
                if (network.dwFlags & WLAN_AVAILABLE_NETWORK_CONNECTED) {
                    signalQuality = (int)network.wlanSignalQuality;
                    break;
                }
            }
            WlanFreeMemory(pBssList);
        }
    }

    if (pIfList != NULL) {
        WlanFreeMemory(pIfList);
    }
    WlanCloseHandle(hClient, NULL);

    return signalQuality;
//    if (signalQuality >= 0) {
//        return std::to_string(signalQuality); // return 0~100
//    } else {
//        return "Error: No connected Wi-Fi";
//    }
}
