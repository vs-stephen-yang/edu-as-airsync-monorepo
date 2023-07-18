#include "googlecast/googlecast_utils.h"

ServiceInfo ToServiceInfo(const openscreen::cast::ServiceInfo& gc_info) {
  ServiceInfo info;

  info.port = gc_info.port;
  info.service_name = gc_info.service_name;
  info.service_type = gc_info.service_type;
  info.attributes = gc_info.attributes;

  return info;
}
