import 'package:flutter_mirror/credentials.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:libcastauth/libcastauth.dart';

class CredentialsStore {
  static const _secureDataDir = "packages/flutter_mirror/assets/credentials";
  static const _secureDataPath = "$_secureDataDir/data.json";
  static const _aesKey = "cnEqOxne9Wc01A/gEKjnGICqFUHgyyxbSySXxamOYXA=";
  static const _aesIv = "p9FCq67UzgvieYZ1g7x90w==";

  static late SecureData _secureData;
  static late CastKeySetReader _castKeySetReader;

  // initialize secureData and castKeySetReader
  static Future init() async {
    String json = await rootBundle.loadString(_secureDataPath);
    _secureData = SecureData(_aesKey, _aesIv)..fromJson(json);
    _castKeySetReader = CastKeySetReader.fromSecureData(_secureData);
  }

  // load today's credentials
  static Future<Credentials> loadToday() async {
    final now = DateTime.now().toUtc();

    return load(now.year, now.month, now.day);
  }

  // load credentials from secureData
  static Future<Credentials> load(int year, int month, int day) async {
    var castKey = _castKeySetReader.getKeySet(year, month, day);
    if (castKey == null) {
      throw Exception("No key found for $year-$month-$day");
    }
    return Credentials(
        year,
        month,
        day,
        castKey.deviceCertDer,
        castKey.icaCertDer,
        castKey.tlsCertDer,
        castKey.tlsKeyDer,
        castKey.signature);
  }
}
