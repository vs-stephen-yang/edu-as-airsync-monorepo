import 'package:flutter_mirror/credentials.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:libcastauth/libcastauth.dart';

class CredentialsStore {
  static const _secureDataDir = "packages/flutter_mirror/assets/credentials";
  static const _secureDataPath = "$_secureDataDir/data.json";
  static const _aesKey = "ezING5WA+zc51LI4defJCuYS5ei8v5SZHkz01n2Oj+k=";
  static const _aesIv = "34Ez/9A42ykogldQC04/kA==";

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
