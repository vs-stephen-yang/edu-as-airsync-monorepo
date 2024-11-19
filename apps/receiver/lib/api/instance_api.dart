import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/api/http_request.dart';

class RegisterInstanceResult {
  String tunnelUrl;
  int instanceIndex;

  RegisterInstanceResult(this.tunnelUrl, this.instanceIndex);

  RegisterInstanceResult.fromJson(Map<String, dynamic> json)
      : tunnelUrl = json['tunnelUrl'],
        instanceIndex = json['instanceIndex'];
}

Future<RegisterInstanceResult?> registerInstanceIndexById(
  String baseApiUrl,
  String instanceId,
  int instanceGroupId,
) async {
  log.info('Registering the instance $baseApiUrl groupId:$instanceGroupId');

  final request = HttpRequest<RegisterInstanceResult>(
    baseApiUrl,
    path: '/v1/instance/$instanceId',
    queryParameters: {
      'groupId': '$instanceGroupId',
    },
  );

  return await request.sendRequest(
    'registerInstance',
    HttpMethod.put,
    RegisterInstanceResult.fromJson,
  );
}
