import 'dart:io';
import 'dart:convert';
import 'package:display_channel/src/api/api_request.dart';
import 'package:http/http.dart' as http;

class RegisterInstanceResult {
  String tunnelApiUrl;
  int instanceIndex;

  RegisterInstanceResult(
    this.tunnelApiUrl,
    this.instanceIndex,
  );
}

Future<RegisterInstanceResult> registerInstance(
  String apiOrigin,
  String instanceId,
  int instanceGroupId,
) async {
  final request = buildApiRequest(
    apiOrigin,
    '/v1/instance/$instanceId',
    queryParameters: {
      'groupId': '$instanceGroupId',
    },
    time: DateTime.now(),
    signatureLocation: SignatureLocation.header,
  );

  final response = await http.put(
    request.url,
    headers: request.headers,
    body: request.body,
  );

  if (response.statusCode != HttpStatus.ok) {
    throw Exception('${request.url} status ${response.statusCode}');
  }

  final data = jsonDecode(response.body);

  return RegisterInstanceResult(
    data['tunnelUrl'],
    data['instanceIndex'],
  );
}

Future<String> fetchInstanceInfo(
  String apiOrigin,
  int instanceIndex,
  int instanceGroupId,
) async {
  final request = buildApiRequest(
    apiOrigin,
    '/v1/instance',
    queryParameters: {
      'groupId': '$instanceGroupId',
      'instanceIndex': '$instanceIndex',
    },
    time: DateTime.now(),
    signatureLocation: SignatureLocation.header,
  );

  final response = await http.get(
    request.url,
    headers: request.headers,
  );

  if (response.statusCode != HttpStatus.ok) {
    throw Exception('${request.url} status ${response.statusCode}');
  }

  final data = jsonDecode(response.body);

  return data['tunnelUrl'];
}

class LogUploadUrlResult {
  String url;
  String key;

  LogUploadUrlResult(this.url, this.key);
}

Future<LogUploadUrlResult> createLogUploadUrl(
  String apiOrigin,
  String instanceId,
) async {
  final request = buildApiRequest(
    apiOrigin,
    '/v1/instance/$instanceId/logs',
    time: DateTime.now(),
    signatureLocation: SignatureLocation.header,
  );

  final response = await http.post(
    request.url,
    headers: request.headers,
  );

  if (response.statusCode != HttpStatus.ok) {
    throw Exception('${request.url} status ${response.statusCode}');
  }

  final data = jsonDecode(response.body);

  return LogUploadUrlResult(
    data['uploadURL'],
    data['key'],
  );
}
