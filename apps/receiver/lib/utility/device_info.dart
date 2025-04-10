import 'dart:io';
import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_flutter/utility/ip_util.dart';
import 'package:display_flutter/utility/log.dart';

const _excludedInterfacesPerDevice = <String, List<String>>{
  // https://viewsonic-ssi.visualstudio.com/Display%20App/_workitems/edit/82027/
  // dvLED model should exclude eth1
  'dvLED': ['eth1'],
};

/// Selects the best IPv4 address from a list of network interfaces,
/// applying device-type-specific exclusion rules and prioritizing
/// by interface name patterns.
///
/// [interfaces] is the list of available network interfaces.
/// [deviceType] is used to look up interface names to exclude.
///
/// Returns the first IP address that passes the filter and matches
/// the priority order.
Future<String?> findIpAddressByDeviceType(
  List<NetworkInterface> interfaces,
  String? deviceType,
) async {
  final excluded = _excludedInterfacesPerDevice[deviceType] ?? [];

  return findBestNetworkIp(
    interfaces: interfaces,
    // Filter out any interface whose name is listed for the current device
    filter: (iface) => !excluded.contains(iface.name),
    priorityOrder: ['eth', 'wlan', 'wi', 'rmnet', 'wwan'],
  );
}

/// Automatically detects the device type and retrieves the best IPv4 address
/// for this device by applying device-specific interface filtering.
///
/// Internally gathers all IPv4 interfaces and delegates to [findIpAddressByDeviceType].
Future<String?> findDeviceIpAddress() async {
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );

    final deviceType = await DeviceInfoVs.deviceType;

    return await findIpAddressByDeviceType(interfaces, deviceType);
  } catch (e) {
    log.warning('findDeviceIpAddress failed', e);

    return null;
  }
}
