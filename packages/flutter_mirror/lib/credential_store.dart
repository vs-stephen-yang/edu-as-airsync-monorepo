import 'dart:async' show Future;

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_mirror/credentials.dart';
import 'package:libcastauth/libcastauth.dart';

class CredentialsStore {
  static const _secureDataDir = "packages/flutter_mirror/assets/credentials";
  static const _secureDataPath = "$_secureDataDir/data.json";
  static const _aesKey = "cnEqOxne9Wc01A/gEKjnGICqFUHgyyxbSySXxamOYXA=";
  static const _aesIv = "p9FCq67UzgvieYZ1g7x90w==";

  // 用 Future 做 lazy cache，避免 late
  static Future<CastKeySetReader>? _readerFuture;

  static Future<CastKeySetReader> _loadReader() async {
    final json = await rootBundle.loadString(_secureDataPath);
    final secureData = SecureData(_aesKey, _aesIv)..fromJson(json);
    return CastKeySetReader.fromSecureData(secureData);
  }

  // 保證只會初始化一次
  static Future<CastKeySetReader> get _reader async {
    final existing = _readerFuture;
    if (existing != null) return existing;

    final future = _loadReader();
    _readerFuture = future;
    return future;
  }

  // load today's credentials
  static Future<Credentials> loadToday() async {
    final now = DateTime.now().toUtc();

    return load(now.year, now.month, now.day);
  }

  // load credentials from secureData
  static Future<Credentials> load(int year, int month, int day) async {
    final reader = await _reader;

    final castKey = reader.getKeySet(year, month, day);
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
