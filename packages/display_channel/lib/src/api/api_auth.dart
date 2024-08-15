import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:display_channel/src/api/api_util.dart';

String generateApiSignature({
  required Map<String, String> queryParameters,
  required Map<String, Object> body,
  required int timestampMs, // in unix timestamp in milliseconds
  required String path,
}) {
  // merge queryParameters and body into a single message
  final payload = {
    ...queryParameters,
    ...body,
  };
  final orderedPayload = orderMapWithKeys(payload);

  final message = '$timestampMs#${json.encode(orderedPayload)}';
  // Convert key to bytes
  final keyBytes = utf8.encode(path);

  // Convert message to bytes
  final messageBytes = utf8.encode(message);

  // Create an HMAC-SHA256 instance
  final hmacSha256 = Hmac(sha256, keyBytes);

  // Compute the HMAC-SHA256 hash
  final signature = hmacSha256.convert(messageBytes);

  // Return the hash as a hexadecimal string
  return signature.toString();
}

Map<String, String> buildAuthHeaders(int timestamp, String signature) {
  return {
    'x-timestamp': '$timestamp',
    'x-signature': signature,
  };
}
