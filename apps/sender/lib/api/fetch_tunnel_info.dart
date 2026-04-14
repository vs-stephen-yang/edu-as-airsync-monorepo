import 'dart:async';

import 'package:display_cast_flutter/api/http_request.dart';
import 'package:display_cast_flutter/utilities/log.dart';

class FetchTunnelInfoResult {
  String tunnelUrl;

  FetchTunnelInfoResult(this.tunnelUrl);

  FetchTunnelInfoResult.fromJson(Map<String, dynamic> json)
      : tunnelUrl = json['tunnelUrl'];
}

Future<FetchTunnelInfoResult> fetchTunnelInfo(
  String baseApiUrl,
  int instanceIndex,
  int instanceGroupId,
) async {
  log.info('Fetching the instance groupId:$instanceGroupId $baseApiUrl');

  final request = HttpRequest<FetchTunnelInfoResult>(
    baseApiUrl,
    path: '/v1/instance',
    queryParameters: {
      'instanceIndex': instanceIndex.toString(),
      'groupId': instanceGroupId.toString(),
    },
  );

  return await request.sendRequest(
    'fetchTunnelInfo',
    HttpMethod.get,
    FetchTunnelInfoResult.fromJson,
  );
}
