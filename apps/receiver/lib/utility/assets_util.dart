import 'dart:convert';

import 'package:flutter/services.dart';

Future<Uint8List> loadAssetAsBytes(String assetPath) async {
  ByteData data = await rootBundle.load(assetPath);
  return data.buffer.asUint8List();
}

Future<Map<String, dynamic>> loadAssetAsJsonData(String assetPath) async {
  try {
    String data = await rootBundle.loadString(assetPath);
    return json.decode(data);
  } catch (e) {
    throw Exception('asset not found: $e');
  }
}
