import 'package:flutter_test/flutter_test.dart';
import 'package:display_channel/src/display_code.dart';

void main() {
  test('getClassOfIpAddress(192.168.0.0) should return class C', () {
    // arrange

    // action
    final actual = getClassOfIpAddress('192.168.0.0');

    //assert
    expect(actual, Ipv4Class.classC);
  });

  test('getClassOfIpAddress(192.168.255.255) should return class C', () {
    // arrange

    // action
    final actual = getClassOfIpAddress('192.168.255.255');

    //assert
    expect(actual, Ipv4Class.classC);
  });

  test('getClassOfIpAddress(172.16.0.0) should return class B', () {
    // arrange

    // action
    final actual = getClassOfIpAddress('172.16.0.0');

    //assert
    expect(actual, Ipv4Class.classB);
  });

  test('getClassOfIpAddress(172.31.255.255) should return class B', () {
    // arrange

    // action
    final actual = getClassOfIpAddress('172.31.255.255');

    //assert
    expect(actual, Ipv4Class.classB);
  });

  test('getClassOfIpAddress(10.0.0.0) should return class A', () {
    // arrange

    // action
    final actual = getClassOfIpAddress('10.0.0.0');

    //assert
    expect(actual, Ipv4Class.classA);
  });

  test('getClassOfIpAddress(10.0.0.0) should return class A', () {
    // arrange

    // action
    final actual = getClassOfIpAddress('10.0.0.0');

    //assert
    expect(actual, Ipv4Class.classA);
  });

  test('getClassFromIpIndex(10.255.255.255) should return class A', () {
    // arrange

    // action
    final actual = getClassOfIpAddress('10.255.255.255');

    //assert
    expect(actual, Ipv4Class.classA);
  });

  test('ip conversion between string and int for 192.168.100.50', () {
    // arrange

    // action
    final intAddress = ipv4ToInt('192.168.100.50');
    final actual = intToIPv4(intAddress);

    // assert
    expect(actual, '192.168.100.50');
  });

  test('ip conversion between string and int for 172.31.1.245', () {
    // arrange

    // action
    final intAddress = ipv4ToInt('172.31.1.245');
    final actual = intToIPv4(intAddress);

    // assert
    expect(actual, '172.31.1.245');
  });

  test('conversion between IpIndex and 192.168.0.0', () {
    // arrange

    // action
    final ipIndex = mapIpAddressToIndex('192.168.0.0');
    final actual = mapIpIndexToIpAddress(ipIndex!);

    // assert
    expect(actual, '192.168.0.0');
  });
  test('conversion between IpIndex and 192.168.255.255', () {
    // arrange

    // action
    final ipIndex = mapIpAddressToIndex('192.168.255.255');
    final actual = mapIpIndexToIpAddress(ipIndex!);

    // assert
    expect(actual, '192.168.255.255');
  });

  test('conversion between IpIndex and 172.16.0.0', () {
    // arrange

    // action
    final ipIndex = mapIpAddressToIndex('172.16.0.0');
    final actual = mapIpIndexToIpAddress(ipIndex!);

    // assert
    expect(actual, '172.16.0.0');
  });

  test('conversion between IpIndex and 172.31.255.255', () {
    // arrange

    // action
    final ipIndex = mapIpAddressToIndex('172.31.255.255');
    final actual = mapIpIndexToIpAddress(ipIndex!);

    // assert
    expect(actual, '172.31.255.255');
  });

  test('conversion between IpIndex and 10.0.0.0', () {
    // arrange

    // action
    final ipIndex = mapIpAddressToIndex('10.0.0.0');
    final actual = mapIpIndexToIpAddress(ipIndex!);

    // assert
    expect(actual, '10.0.0.0');
  });

  test('conversion between IpIndex and 10.255.255.255', () {
    // arrange

    // action
    final ipIndex = mapIpAddressToIndex('10.255.255.255');
    final actual = mapIpIndexToIpAddress(ipIndex!);

    // assert
    expect(actual, '10.255.255.255');
  });

  test('encode 192.168.0.0 and 0', () {
    // arrange
    final displayCode = DisplayCode('192.168.0.0', 0);

    // action
    final actual = encodeDisplayCode(displayCode);

    // assert
    expect(actual, '0');
  });

  test('encode 10.255.255.255 and 999999', () {
    // arrange
    final displayCode = DisplayCode('10.255.255.255', 999999);

    // action
    final actual = encodeDisplayCode(displayCode);

    // assert
    expect(actual, '6CB5UR11B');
  });

  test('encode and decode class C', () {
    // arrange
    final displayCode = DisplayCode('192.168.10.123', 1234);

    // action
    final code = encodeDisplayCode(displayCode);
    final actual = decodeDisplayCode(code!);

    // assert
    expect(actual.ipAddress, '192.168.10.123');
    expect(actual.instanceIndex, 1234);
  });

  test('encode and decode class B', () {
    // arrange
    final displayCode = DisplayCode('172.16.5.98', 1234);

    // action
    final code = encodeDisplayCode(displayCode);
    final actual = decodeDisplayCode(code!);

    // assert
    expect(actual.ipAddress, '172.16.5.98');
    expect(actual.instanceIndex, 1234);
  });

  test('encode and decode class A', () {
    // arrange
    final displayCode = DisplayCode('10.15.17.16', 1234);

    // action
    final code = encodeDisplayCode(displayCode);
    final actual = decodeDisplayCode(code!);

    // assert
    expect(actual.ipAddress, '10.15.17.16');
    expect(actual.instanceIndex, 1234);
  });

  test('The length should be not larger than 8 for class B and C', () {
    // arrange
    final displayCode = DisplayCode('172.31.255.255', 999999);

    // action
    final actual = encodeDisplayCode(displayCode);

    // assert
    expect(actual!.length, lessThanOrEqualTo(8));
  });

  test('encode the display index in chunk 1', () {
    // arrange
    final displayCode = DisplayCode('192.168.0.0', 1000000);

    // action
    final actual = encodeDisplayCode(displayCode);

    // assert
    expect(actual, '6CB5UR11C');
  });

  test('encode the display index in chunk 2', () {
    // arrange
    final displayCode = DisplayCode('192.168.0.0', 2000000);

    // action
    final actual = encodeDisplayCode(displayCode);

    // assert
    expect(actual, 'COMBPI22O');
  });

  test('encode and decode the display index in chunk 1 with class B', () {
    // arrange
    final displayCode = DisplayCode('172.21.5.7', 1500000);

    // action
    final code = encodeDisplayCode(displayCode);
    final actual = decodeDisplayCode(code!);

    // assert
    expect(actual.ipAddress, '172.21.5.7');
    expect(actual.instanceIndex, 1500000);
  });

  test('encode and decode the display index in chunk 1 with class C', () {
    // arrange
    final displayCode = DisplayCode('192.168.1.6', 1500000);

    // action
    final code = encodeDisplayCode(displayCode);
    final actual = decodeDisplayCode(code!);

    // assert
    expect(actual.ipAddress, '192.168.1.6');
    expect(actual.instanceIndex, 1500000);
  });

  test('encode and decode the display index in chunk 1 with class A', () {
    // arrange
    final displayCode = DisplayCode('10.100.100.100', 1500000);

    // action
    final code = encodeDisplayCode(displayCode);
    final actual = decodeDisplayCode(code!);

    // assert
    expect(actual.ipAddress, '10.100.100.100');
    expect(actual.instanceIndex, 1500000);
  });
}
