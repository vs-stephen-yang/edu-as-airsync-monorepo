#ifndef FLUTTER_MIRROR_PLUGIN_SERVICE_INFO_H_
#define FLUTTER_MIRROR_PLUGIN_SERVICE_INFO_H_

#include <map>
#include <string>

struct ServiceInfo {
  std::string service_name;
  std::string service_type;
  unsigned short port;

  std::map<std::string, std::string> attributes;
};

#endif  // FLUTTER_MIRROR_PLUGIN_SERVICE_INFO_H_
