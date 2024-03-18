import 'package:flutter/services.dart';

Future<Uint8List> loadAssetAsBytes(String assetPath) async {
  ByteData data = await rootBundle.load(assetPath);
  return data.buffer.asUint8List();
}
