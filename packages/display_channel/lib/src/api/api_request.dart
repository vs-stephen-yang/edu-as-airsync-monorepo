import 'package:display_channel/src/api/api_auth.dart';
import 'package:display_channel/src/api/api_util.dart';

class ApiRequest {
  Uri url;
  Map<String, String>? headers;
  Map<String, Object>? body;

  ApiRequest(
    this.url, {
    this.headers,
    this.body,
  });
}

ApiRequest buildApiRequest(
  String baseApiUrl,
  String path, {
  Map<String, Object>? queryParameters,
  Map<String, Object>? body,
  required DateTime time,
}) {
  final timestampMs = time.millisecondsSinceEpoch; // unix timestamp

  final signature = generateApiSignature(
    queryParameters: queryParameters ?? {},
    body: body ?? {},
    timestampMs: timestampMs,
    path: path,
  );

  final authHeaders = buildAuthHeaders(timestampMs, signature);

  final baseUrl = Uri.parse(baseApiUrl);
  final url = baseUrl.replace(
      path: path,
      queryParameters: queryParameters?.map((key, value) {
        return MapEntry(key, value.toString());
      }));

  return ApiRequest(
    url,
    headers: authHeaders,
    body: body,
  );
}
