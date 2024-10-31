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

List<RtcIceServer>? parseIceServersFromApi(Map<String, dynamic> body) {
  try {
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
  } catch (e) {
    return null;
  }
}
