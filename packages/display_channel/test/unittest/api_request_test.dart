import 'package:display_channel/src/api/api_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildApiRequest', () {
    // arrange

    //action
    final actual = buildApiRequest(
      'https://api.gateway.dev2.airsync.net/',
      '/v1/instance/v-456',
      queryParameters: {
        'instanceIndex': 0,
        'groupId': '1379699',
      },
      time: DateTime.fromMillisecondsSinceEpoch(1722854068762),
      signatureLocation: SignatureLocation.header,
    );

    //assert

    expect(
      actual.url.toString(),
      'https://api.gateway.dev2.airsync.net/v1/instance/v-456?instanceIndex=0&groupId=1379699',
    );

    expect(
      actual.headers,
      {
        'x-timestamp': '1722854068762',
        'x-signature':
            'bca82ae15c24a53a891e548730e9d03058070db70185d5fcbd5c1f9d6785a233',
      },
    );
  });
}
