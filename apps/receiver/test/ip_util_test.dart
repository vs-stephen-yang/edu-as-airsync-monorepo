import 'package:display_flutter/utility/ip_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('8.8.8.8 should not be a private IP', () {
    // arrange

    // action
    final actual = isPrivateIp('8.8.8.8');

    //assert
    expect(actual, false);
  });

  test('192.168.0.0 should be a private IP', () {
    // arrange

    // action
    final actual = isPrivateIp('192.168.0.0');

    //assert
    expect(actual, true);
  });

  test('192.168.255.255 should be a private IP', () {
    // arrange

    // action
    final actual = isPrivateIp('192.168.255.255');

    //assert
    expect(actual, true);
  });

  test('172.16.0.0 should be a private IP', () {
    // arrange

    // action
    final actual = isPrivateIp('172.16.0.0');

    //assert
    expect(actual, true);
  });

  test('172.31.255.255 should be a private IP', () {
    // arrange

    // action
    final actual = isPrivateIp('172.31.255.255');

    //assert
    expect(actual, true);
  });

  test('172.15.255.255 should not be a private IP', () {
    // arrange

    // action
    final actual = isPrivateIp('172.15.255.255');

    //assert
    expect(actual, false);
  });

  test('10.0.0.0 should be a private IP', () {
    // arrange

    // action
    final actual = isPrivateIp('10.0.0.0');

    //assert
    expect(actual, true);
  });
}
