import 'dart:convert';
import 'dart:io';

import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/utility/channel_util.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:http/http.dart' as http;

// Get ICE server URLS
// POST /v1/turn/credentials/generate
// Response
// {
//   "iceServers": {
//     "urls": [
//       "string"
//     ],
//     "username": "string",
//     "credential": "string",
//     "expiredDate": 0
//   }
// }

Future<List<RtcIceServer>?> getIceServers(
  String baseApiUrl,
  String instanceId,
) async {
  final request = buildApiRequest(
    baseApiUrl,
    '/v1/turn/credentials/generate',
    queryParameters: {
      'instanceId': instanceId.toString(),
    },
    time: DateTime.now(),
    signatureLocation: SignatureLocation.header,
  );

  try {
    http.Response response = await http.post(
      request.url,
      headers: request.headers,
      body: request.body,
    );

    if (response.statusCode >= HttpStatus.ok &&
        response.statusCode < HttpStatus.multiStatus) {
      Map<String, dynamic> body = jsonDecode(response.body);

      return parseIceServersFromApi(body);
    }
  } catch (e) {
    // http.get maybe no network connection.
    log.severe('Failed to get ICE servers', e);
  }
  return null;
}
