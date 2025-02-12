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

const _webtransportCertsListPath = 'assets/channel/webtransport_certs_list.json';

class WebTransportCertificate {
  late List<String> certPem;
  late List<String> keyPem;

  WebTransportCertificate(this.certPem, this.keyPem);
}


Future<WebTransportCertificate?> getWebTransportCert() async {
  Map<String, dynamic> jsonData = await loadAssetAsJsonData(_webtransportCertsListPath);
  List<Map<String, dynamic>> certs = List<Map<String, dynamic>>.from(jsonData['certs']);

  DateTime today = DateTime.now().toUtc();
  List<Map<String, dynamic>> validCerts = [];

  for (var cert in certs) {
    DateTime notBefore = DateTime.parse(cert['date']);
    DateTime notAfter = notBefore.add(Duration(days: 14));

    if ((notBefore.isBefore(today) || notBefore.isAtSameMomentAs(today)) &&
        today.isBefore(notAfter)) {
      validCerts.add(cert);
    }
  }

  if (validCerts.isEmpty) return null;

  validCerts.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
  Map<String, dynamic> selectedCert = validCerts.first;

  List<String> certPem =  List<String>.from(selectedCert["certPem"]);
  List<String> keyPem = List<String>.from(selectedCert["keyPem"]);
  return WebTransportCertificate(certPem, keyPem);
}
