import 'dart:convert';
import 'dart:io';

import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/utility/channel_util.dart';
import 'package:http/http.dart' as http;

Future<List<RtcIceServer>?> getIceServers(String iceServersApiUrl) async {
  try {
    http.Response response = await http.get(
      Uri.parse(iceServersApiUrl),
    );

    if (response.statusCode >= HttpStatus.ok &&
        response.statusCode < HttpStatus.multiStatus) {
      Map<String, dynamic> iceServerList = jsonDecode(response.body);
      if (iceServerList.containsKey('list')) {
        List list = iceServerList['list'];

        return parseIceServersFromApi(list);
      }
    }
  } catch (e) {
    // http.get maybe no network connection.
  }
  return null;
}
