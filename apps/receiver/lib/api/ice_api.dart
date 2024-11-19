import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/utility/channel_util.dart';
import 'package:display_flutter/api/http_request.dart';
import 'package:display_flutter/utility/log.dart';

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
  try {
    final request = HttpRequest<List<RtcIceServer>>(
      baseApiUrl,
      path: '/v1/turn/credentials/generate',
      queryParameters: {
        'instanceId': instanceId.toString(),
      },
    );

    return await request.sendRequest(
      'getIceServers',
      HttpMethod.post,
      parseIceServersFromApi,
    );
  } catch (e) {
    log.severe('Failed to get ICE servers', e);
    return null;
  }
}
