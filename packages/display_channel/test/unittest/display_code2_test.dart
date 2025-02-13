import 'package:flutter_test/flutter_test.dart';
import 'package:display_channel/src/display_code2.dart';

void main() {
  test('The instance group id for 0.0.0.0 should be 0', () {
    // arrange
    // action
    final actual = getInstanceGroupIdFromIp('0.0.0.0');

    //assert
    expect(actual, 0);
  });

  test('The instance group id for 0.0.0.1 should be 1', () {
    // arrange
    // action
    final actual = getInstanceGroupIdFromIp('0.0.0.1');

    //assert
    expect(actual, 1);
  });

  test('The instance group id for 255.255.255.255 should be 16646655', () {
    // arrange
    // action
    final actual = getInstanceGroupIdFromIp('255.255.255.255');

    //assert
    expect(actual, (1 << 24) - 1);
  });

  test('The instance group id for 255.100.5.13 should be 6554893', () {
    // arrange
    // action
    final actual = getInstanceGroupIdFromIp('255.100.5.13');

    //assert
    expect(actual, 6554893);
  });

  test('encodeDisplayCode() should output a string with at least 8 digits', () {
    // arrange
    // action
    final actual = encodeDisplayCode(DisplayCode(
      instanceGroupId: 1,
    ));

    //assert
    expect(actual, '00000001');
  });

  test('encodeDisplayCode() without instanceIndex', () {
    // arrange
    // action
    final actual = encodeDisplayCode(DisplayCode(
      instanceGroupId: 16777215,
    ));

    //assert
    expect(actual, '16777215');
  });

  test('encodeDisplayCode() with non-zero instanceIndex', () {
    // arrange
    // action
    final actual = encodeDisplayCode(DisplayCode(
      instanceGroupId: 0,
      instanceIndex: 1,
    ));

    //assert
    expect(actual, '16777216');
  });

  test('encodeDisplayCode() for large instance index', () {
    // arrange
    // action
    final actual = encodeDisplayCode(DisplayCode(
      instanceGroupId: 16777215,
      instanceIndex: 58,
    ));

    //assert
    expect(actual, '989855743');
  });

  test('createRemoteIpCandidates() for 1 local private IP', () {
    // arrange
    // action
    final actual = createRemoteIpCandidates(
      DisplayCode(instanceGroupId: 1),
      ['192.168.1.5'],
    );

    //assert
    expect(actual, unorderedEquals(['192.0.0.1', '172.0.0.1', '10.0.0.1']));
  });

  test('createRemoteIpCandidates() for 1 local public IP', () {
    // arrange
    // action
    final actual = createRemoteIpCandidates(
      DisplayCode(instanceGroupId: 16777215),
      ['123.168.1.5'],
    );

    //assert
    expect(
        actual,
        unorderedEquals([
          '123.255.255.255',
          '192.255.255.255',
          '172.255.255.255',
          '10.255.255.255'
        ]));
  });

  test('createRemoteIpCandidates() with no local IP address', () {
    // arrange
    // action
    final actual = createRemoteIpCandidates(
      DisplayCode(instanceGroupId: 1),
      [],
    );

    //assert
    expect(actual, unorderedEquals(['192.0.0.1', '172.0.0.1', '10.0.0.1']));
  });
}
