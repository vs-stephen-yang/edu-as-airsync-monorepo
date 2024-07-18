import 'dart:io';
import 'dart:convert';
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
  String apiBaseUrl,
  String instanceId,
  int instanceGroupId,
) async {
  final url = '$apiBaseUrl/instances';
  http.Response response = await http.put(
    Uri.parse(url),
    body: json.encode(
      {
        'instanceId': instanceId,
        'instanceGroupId': '$instanceGroupId',
      },
    ),
  );

  if (response.statusCode != HttpStatus.ok) {
    throw Exception('$url status ${response.statusCode}');
  }

  final data = jsonDecode(response.body);

  return RegisterInstanceResult(
    data['tunnelApiUrl'],
    int.parse(data['instanceIndex']),
  );
}

Future<String> fetchInstanceInfo(
  String apiBaseUrl,
  int instanceIndex,
  int instanceGroupId,
) async {
  final url =
      '$apiBaseUrl?instanceIndex=$instanceIndex&instanceGroupId=$instanceGroupId';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode != HttpStatus.ok) {
    throw Exception('$url status ${response.statusCode}');
  }

  Map data = jsonDecode(response.body);
  return data['tunnelApiUrl'];
}
