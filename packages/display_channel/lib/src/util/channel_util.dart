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
Future<List<String>> fetchIPv4Addresses() async {
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );

    final ipAddresses = <String>[];
    for (var interface in interfaces) {
      for (var address in interface.addresses) {
        ipAddresses.add(address.address);
      }
    }

    return ipAddresses;
  } on UnsupportedError {
    return [];
  }
}
