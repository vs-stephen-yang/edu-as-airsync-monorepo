import 'package:display_channel/src/api/api_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildApiRequest', () {
    // arrange

    //action
    final actual = buildApiRequest(
      'https://api2.gateway.dev.airsync.net/',
      '/v1/instance/v-456',
      queryParameters: {
        'instanceIndex': '0',
        'groupId': '1379699',
      },
      time: DateTime.fromMillisecondsSinceEpoch(1722854068762),
      signatureLocation: SignatureLocation.header,
    );

    //assert

    expect(
      actual.url.toString(),
      'https://api2.gateway.dev.airsync.net/v1/instance/v-456?instanceIndex=0&groupId=1379699',
    );

    expect(
      actual.headers,
      {
        'x-timestamp': '1722854068762',
        'x-signature':
            'be365814d19749599bcc74c814225fa97d554c1ab60e0921e6089d5232186e55',
      },
    );
  });
}
