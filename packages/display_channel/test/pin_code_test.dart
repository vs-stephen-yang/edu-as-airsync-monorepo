import 'package:flutter_test/flutter_test.dart';
import 'package:display_channel/src/pin_code.dart';

void main() {
  test('formatPinCode(0) ', () {
    // arrange

    // action
    final actual = formatPinCode(0);

    //assert
    expect(actual, '000000');
  });

  test('formatPinCode(36^6 - 1) ', () {
    // arrange

    // action
    final actual = formatPinCode(2176782335);

    //assert
    expect(actual, 'ZZZZZZ');
  });

  test('getClassOfIpv4() class A', () {
    // arrange

    // action
    final actual = getClassOfIpv4('10.255.255.255');

    //assert
    expect(actual, 0);
  });

  test('getClassOfIpv4() class B', () {
    // arrange

    // action
    final actual = getClassOfIpv4('172.31.255.255');

    // assert
    expect(actual, 1);
  });

  test('getClassOfIpv4() class C', () {
    // arrange

    // action
    final actual = getClassOfIpv4('192.168.100.50');

    // assert
    expect(actual, 2);
  });

  test('ip conversion between string and int', () {
    // arrange

    // action
    final intAddress = ipv4ToInt('192.168.100.50');
    final actual = intToIPv4(intAddress);

    // assert
    expect(actual, '192.168.100.50');
  });

  test('encode 10.0.0.1', () {
    // arrange
    final pinCode = PinCode('10.0.0.1', 0);

    // action
    String actual = encodePinCode(pinCode);

    // assert
    expect(actual, '000001');
  });

  test('encode and decode for class A', () {
    // arrange
    final pinCode = PinCode('10.9.8.7', 20);

    // action
    String code = encodePinCode(pinCode);
    final actual = decodePinCode(code);

    // assert
    expect(actual.host, '10.9.8.7');
    expect(actual.passcode, 20);
  });

  test('encode and decode for class B', () {
    // arrange
    final pinCode = PinCode('172.31.8.7', 0);

    // action
    String code = encodePinCode(pinCode);
    final actual = decodePinCode(code);

    // assert
    expect(actual.host, '172.31.8.7');
    expect(actual.passcode, 0);
  });

  test('encode and decode for class C', () {
    // arrange
    final pinCode = PinCode('192.168.5.100', 5);

    // action
    String code = encodePinCode(pinCode);
    final actual = decodePinCode(code);

    // assert
    expect(actual.host, '192.168.5.100');
    expect(actual.passcode, 5);
  });

  test('max passcode', () {
    // arrange
    final pinCode = PinCode('192.168.255.255', 120);

    // action
    String code = encodePinCode(pinCode);
    final actual = decodePinCode(code);

    // assert
    expect(actual.host, '192.168.255.255');
    expect(actual.passcode, 120);
  });
}
