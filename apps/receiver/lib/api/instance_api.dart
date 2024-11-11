import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/utility/log.dart';

class RegisterInstanceResult {
  String tunnelApiUrl;
  int instanceIndex;

  RegisterInstanceResult(this.tunnelApiUrl, this.instanceIndex);
}

Future<RegisterInstanceResult?> registerInstanceIndexById(
  String baseApiUrl,
  String instanceId,
  int instanceGroupId,
) async {
  try {
    log.info('Registering the instance $baseApiUrl groupId:$instanceGroupId');

    final request = buildApiRequest(
      baseApiUrl,
      '/v1/instance/$instanceId',
      queryParameters: {
        'groupId': '$instanceGroupId',
      },
      time: DateTime.now(),
      signatureLocation: SignatureLocation.header,
    );

    http.Response response = await http
        .put(
          request.url,
          headers: request.headers,
          body: request.body,
        )
        .timeout(const Duration(seconds: 6));
    log.info('Status of Instance Register API: ${response.statusCode}');

    if (response.statusCode >= HttpStatus.ok &&
        response.statusCode < HttpStatus.multiStatus) {
      Map json = jsonDecode(response.body);

      final tunnelApiUrl = json['tunnelUrl'] ?? '';
      final instanceIndex = json['instanceIndex'];

      return RegisterInstanceResult(tunnelApiUrl, instanceIndex);
    } else {
      log.warning(
          'Instance Register API failed. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    log.warning('Instance Register API failed with $e');
    return null;
  }
}
