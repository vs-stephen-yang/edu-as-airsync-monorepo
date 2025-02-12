import 'dart:io';

import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/utility/assets_util.dart';

enum ReconnectState { idle, reconnecting, success, fail }

const _certPemPath = 'assets/channel/certificate.pem';
const _keyPemPath = 'assets/channel/private_key.pem';

Future<SecurityContext> loadSecurityContextForChannel() async {
  // load files from assets
  final certificateChain = await loadAssetAsBytes(_certPemPath);
  final privateKey = await loadAssetAsBytes(_keyPemPath);

  return SecurityContext()
    ..useCertificateChainBytes(certificateChain)
    ..usePrivateKeyBytes(privateKey);
}

List<RtcIceServer> parseIceServersFromApi(Map<String, dynamic> body) {
  String username = body['username'];
  String credential = body['credential'];

  List urls = body['urls'];

  return urls
      .map(
        (url) => RtcIceServer(
          [url],
          credential: credential,
          username: username,
        ),
      )
      .toList();
}

const _webtransportCertsBasePath = 'assets/channel/';
const _webtransportCertsListFilename = 'webtransport_certs_list.json';
const _webtransportKeyPemFilename = 'webtransport_key.pem';
const _webtransportCertsFilenameRegexp = r'webtransport_cert_(\d{4})_(\d{2})_(\d{2})\.pem';

class WebTransportCertificate {
  late List<String> certPem;
  late List<String> keyPem;

  WebTransportCertificate(this.certPem, this.keyPem);
}

Future<WebTransportCertificate> getWebtransportCert() async {
  DateTime today = DateTime.now();
  List<String> filenames = await loadCertFilenames();
  String certFilename = getValidCert(filenames, today) ?? '';

  List<String> certPem = await loadAssetAsStringList(_webtransportCertsBasePath + certFilename);
  List<String> keyPem = await loadAssetAsStringList(_webtransportCertsBasePath + _webtransportKeyPemFilename);

  return WebTransportCertificate(certPem, keyPem);
}

Future<List<String>> loadCertFilenames() async {
  Map<String, dynamic> jsonData = await loadAssetAsJsonData(_webtransportCertsBasePath + _webtransportCertsListFilename);
  return List<String>.from(jsonData['certs']);
}

String? getValidCert(List<String> certs, DateTime today) {
  List<DateTime> validCerts = [];

  for (var cert in certs) {
    var match = RegExp(_webtransportCertsFilenameRegexp)
        .firstMatch(cert);
    if (match != null) {
      int year = int.parse(match.group(1)!);
      int month = int.parse(match.group(2)!);
      int day = int.parse(match.group(3)!);
      DateTime notBefore = DateTime(year, month, day);
      DateTime notAfter = notBefore.add(Duration(days: 14));

      if (notBefore.isBefore(today) || notBefore.isAtSameMomentAs(today)) {
        if (today.isBefore(notAfter)) {
          validCerts.add(notBefore);
        }
      }
    }
  }

  if (validCerts.isEmpty) return null;

  validCerts.sort((a, b) => b.compareTo(a)); // Choose the latest NOT_BEFORE

  DateTime selectedCert = validCerts.first;
  return "webtransport_cert_${selectedCert.year}_${selectedCert.month.toString().padLeft(2, '0')}_${selectedCert.day.toString().padLeft(2, '0')}.pem";
}