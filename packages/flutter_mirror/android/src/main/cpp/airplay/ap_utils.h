#ifndef FLUTTER_MIRROR_PLUGIN_AP_UTILS_H_
#define FLUTTER_MIRROR_PLUGIN_AP_UTILS_H_

#include "airplay/airplay_receiver.h"
#include "service_info.h"

ServiceInfo ToServiceInfo(const ap::ServiceInfo& info);

#endif  // FLUTTER_MIRROR_PLUGIN_AP_UTILS_H_
