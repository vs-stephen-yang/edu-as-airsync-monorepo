import 'package:flutter_mirror/credentials.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pem/pem.dart';
import 'dart:convert';
import 'dart:typed_data';

Uint8List decodePem(String pem) {
  const prefix = "-----BEGIN RSA PRIVATE KEY-----";
  const postfix = "-----END RSA PRIVATE KEY-----";

  if (pem.startsWith(prefix)) {
    pem = pem.substring(prefix.length);
  }

  if (pem.endsWith(postfix)) {
    pem = pem.substring(0, pem.length - postfix.length);
  }

  pem = pem.replaceAll('\n', '');
  pem = pem.replaceAll('\r', '');

  return Uint8List.fromList(base64.decode(pem));
}

// convert PEM to DER format
Uint8List pem2der(String pem, PemLabel label) {
  List<int> der = PemCodec(label).decode(pem);

  return Uint8List.fromList(der);
}

String pad2digits(int v) {
  return v.toString().padLeft(2, '0');
}

class CredentialsStore {
  static const credentialsPath = "packages/flutter_mirror/assets/credentials";

  // load today's credentials
  static Future<Credentials> loadToday() async {
    final now = DateTime.now().toUtc();

    return load(now.year, now.month, now.day);
  }

  // load a credentials from file
  static Future<Credentials> load(
    int year,
    int month,
    int day,
  ) async {
    final m = pad2digits(month);
    final d = pad2digits(day);

    final path = "$credentialsPath/cooked_$year-$m-$d.json";

    String json = await rootBundle.loadString(path);
    return parse(json, year, month, day);
  }

  static Credentials parse(
    String json,
    int year,
    int month,
    int day,
  ) {
    Map<String, dynamic> cred = jsonDecode(json);

    Uint8List deviceCert = pem2der(cred['cpu'], PemLabel.certificate);
    Uint8List icaCert = pem2der(cred['ica'], PemLabel.certificate);

    Uint8List tlsCert = pem2der(cred['pu'], PemLabel.certificate);
    Uint8List tlsKey = decodePem(cred['pr']);

    Uint8List signature = base64Decode(cred['sig']);

    return Credentials(
      year,
      month,
      day,
      deviceCert,
      icaCert,
      tlsCert,
      tlsKey,
      signature,
    );
  }
}
