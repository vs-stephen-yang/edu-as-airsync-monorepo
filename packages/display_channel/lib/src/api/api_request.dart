import 'package:display_channel/src/api/api_auth.dart';

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

enum SignatureLocation {
  header,
  queryString,
}

Map<String, V>? _mergeWithSignature<V>(
  Map<String, V>? map,
  Map<String, V> signature, {
  required bool shouldMerge,
}) {
  if (!shouldMerge) return map;

  return {
    ...?map,
    ...signature,
  };
}

ApiRequest buildApiRequest(
  String origin,
  String path, {
  Map<String, String>? queryParameters,
  Map<String, String>? headers,
  Map<String, Object>? body,
  required DateTime time,
  required SignatureLocation signatureLocation,
}) {
  final timestampMs = time.millisecondsSinceEpoch; // unix timestamp

  final signature = generateApiSignature(
    queryParameters: queryParameters ?? {},
    body: body ?? {},
    timestampMs: timestampMs,
    path: path,
  );

  final signatureHeaders = buildAuthHeaders(timestampMs, signature);

  // Merge signature into query parameters if required
  final mergedQueryParameters = _mergeWithSignature(
    queryParameters,
    signatureHeaders,
    shouldMerge: signatureLocation == SignatureLocation.queryString,
  );

  final baseUrl = Uri.parse(origin);
  final url = baseUrl.replace(
      path: path,
      queryParameters: mergedQueryParameters?.map((key, value) {
        return MapEntry(key, value.toString());
      }));

  // Merge signature into headers if required
  final mergedHeaders = _mergeWithSignature(
    headers,
    signatureHeaders,
    shouldMerge: signatureLocation == SignatureLocation.header,
  );

  return ApiRequest(
    url,
    headers: mergedHeaders,
    body: body,
  );
}
