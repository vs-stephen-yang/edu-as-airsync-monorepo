#include "airplay/ap_utils.h"

ServiceInfo ToServiceInfo(const ap::ServiceInfo& ap_info) {
  ServiceInfo info;

  info.port = ap_info.port;
  info.service_name = ap_info.service_name;
  info.service_type = ap_info.service_type;
  info.attributes = ap_info.attributes;

  return info;
}
