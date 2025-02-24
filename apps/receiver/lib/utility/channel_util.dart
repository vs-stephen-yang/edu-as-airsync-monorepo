import 'dart:io';

import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/utility/assets_util.dart';

import 'log.dart';

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

const _webtransportCertsListPath = 'assets/channel/webtransport_certs_list.json';

Future<WebTransportCertificate?> getWebTransportCert() async {
  log.info("Finding webTransport certificate");

  Map<String, dynamic> jsonData = await loadAssetAsJsonData(_webtransportCertsListPath);
  List<Map<String, dynamic>> certs = List<Map<String, dynamic>>.from(jsonData['certs']);

  List<Map<String, dynamic>> validCerts = filterValidCertificates(certs);

  if (validCerts.isEmpty) {
    log.warning("Failed to get webTransport certificate");
    return null;
  }

  validCerts.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
  Map<String, dynamic> selectedCert = validCerts.first;

  return WebTransportCertificate(
    List<String>.from(selectedCert["certPem"]),
    List<String>.from(selectedCert["keyPem"]),
  );
}

List<Map<String, dynamic>> filterValidCertificates(List<Map<String, dynamic>> certs) {
  DateTime today = DateTime.now().toUtc();
  return certs.where((cert) {
    DateTime notBefore = DateTime.parse(cert['date']);
    DateTime notAfter = notBefore.add(Duration(days: 14));
    return (notBefore.isBefore(today) || notBefore.isAtSameMomentAs(today)) && today.isBefore(notAfter);
  }).toList();
}
