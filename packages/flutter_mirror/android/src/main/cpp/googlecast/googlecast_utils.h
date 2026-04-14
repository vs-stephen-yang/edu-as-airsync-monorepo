#ifndef FLUTTER_MIRROR_PLUGIN_GOOGLECAST_UTILS_H_
#define FLUTTER_MIRROR_PLUGIN_GOOGLECAST_UTILS_H_

#include "cast/cast_receiver.h"
#include "service_info.h"

ServiceInfo ToServiceInfo(const openscreen::cast::ServiceInfo& info);

#endif  // FLUTTER_MIRROR_PLUGIN_GOOGLECAST_UTILS_H_
