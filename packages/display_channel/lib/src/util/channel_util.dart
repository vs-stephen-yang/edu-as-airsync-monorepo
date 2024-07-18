import 'dart:io';

import 'package:display_channel/src/channel.dart';
import 'package:display_channel/src/client_connection.dart';

ChannelCloseCode connectErrorToChannelCloseCode(ConnectErrorType error) {
  switch (error) {
    case ConnectErrorType.websocket:
      return ChannelCloseCode.instanceNotFound;
    default:
      return ChannelCloseCode.networkError;
  }
}

// get the local IP v4 addresses
Future<List<String>> getLocalIpAddresses() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
  );

  final addresses = <String>[];
  for (var interface in interfaces) {
    for (var address in interface.addresses) {
      addresses.add(address.address);
    }
  }
  return addresses;
}
