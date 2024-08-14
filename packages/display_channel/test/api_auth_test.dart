import 'package:display_channel/src/api/api_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Auth signature must be calculated correctly', () {
    // arrange

    //action
    final actual = generateApiSignature(
      queryParameters: {
        'groupId': '1379699',
      },
      body: {},
      timestampMs: 1722854068762, // in unix timestamp
      path: '/v1/instance/v-456',
    );

    //assert
    expect(
      actual,
      '1d8b4ead8d4471ceb387bb9c870e8331dc7b72b0d67ffa1deba96af6f8ad5596',
    );
  });

  test('Ensure the order of query parameters', () {
    // arrange

    //action
    final actual = generateApiSignature(
      queryParameters: {
        'instanceIndex': 0,
        'groupId': '1379699',
      },
      body: {},
      timestampMs: 1722853988174, // in unix timestamp
      path: '/v1/instance',
    );

    //assert
    expect(
      actual,
      '4fbe9d5af99dc1fed35a05a4d9390a721f991679fa007672db2b113e5d02b03c',
    );
  });
}
