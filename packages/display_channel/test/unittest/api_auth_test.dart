import 'package:display_channel/src/api/api_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'generateApiSignature should calculate correct auth signature based on query parameters and path',
    () {
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
    },
  );

  test(
    'generateApiSignature should calculate correct signature with query parameters 1',
    () {
      // arrange

      //action
      final actual = generateApiSignature(
        queryParameters: {
          'instanceIndex': '0',
          'groupId': '1379699',
        },
        body: {},
        timestampMs: 1722853988174, // in unix timestamp
        path: '/v1/instance',
      );

      //assert
      expect(
        actual,
        '72211e7289276bf73ea06f87d3371a1f232156cde71df3630dfe1967c27c42aa',
      );
    },
  );

  test(
    'generateApiSignature should calculate correct signature with query parameters 2',
    () {
      // instanceId=v-789&role=server&x-timestamp=1723692488641&x-signature=4a597b74f882fbc891bd97ba4ce50ee9e58b501e5df505371c0d3e5f57b45761

      // arrange

      //action
      final actual = generateApiSignature(
        queryParameters: {
          'instanceId': 'v-789',
          'role': 'server',
        },
        body: {},
        timestampMs: 1723692488641, // in unix timestamp
        path: '',
      );

      //assert
      expect(
        actual,
        '4a597b74f882fbc891bd97ba4ce50ee9e58b501e5df505371c0d3e5f57b45761',
      );
    },
  );

  test(
    'generateApiSignature should calculate correct signature with query parameters 3',
    () {
      // clientId=sender-123&displayCode=test-code&instanceIndex=1&token=test&groupId=1379699&role=client&x-timestamp=1723692544552&x-signature=b32733fb4871eff1a08c3177f343300af7796ad55a331a097db7b338082bdbcb

      // arrange

      //action

      final actual = generateApiSignature(
        queryParameters: {
          'clientId': 'sender-123',
          'displayCode': 'test-code',
          'instanceIndex': '1',
          'token': 'test',
          'groupId': '1379699',
          'role': 'client',
        },
        body: {},
        timestampMs: 1723692544552, // in unix timestamp
        path: '',
      );

      //assert
      expect(
        actual,
        'a0bb17f9834f9a33fc61a184375455b0819952eb422f654cea3d1b0f83cafbb8',
      );
    },
  );
}
