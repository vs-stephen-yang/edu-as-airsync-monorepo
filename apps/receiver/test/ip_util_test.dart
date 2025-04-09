import 'dart:io';

import 'package:display_flutter/utility/ip_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'ip_util_test.mocks.dart';

@GenerateMocks([NetworkInterface])
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

  group('findBestNetworkIp', () {
    test('returns IP from highest priority interface', () async {
      // Arrange
      final wlan0 = MockNetworkInterface();
      when(wlan0.name).thenReturn('wlan0');
      when(wlan0.addresses).thenReturn([InternetAddress('192.168.0.101')]);

      final eth0 = MockNetworkInterface();
      when(eth0.name).thenReturn('eth0');
      when(eth0.addresses).thenReturn([InternetAddress('10.0.0.2')]);

      final interfaces = [wlan0, eth0];
      filter(NetworkInterface iface) => true;
      final priorityOrder = ['eth', 'wlan'];

      // Act
      final result = await findBestNetworkIp(
        interfaces: interfaces,
        filter: filter,
        priorityOrder: priorityOrder,
      );

      // Assert
      expect(result, equals('10.0.0.2'));
    });

    test('returns null when filtered out', () async {
      // Arrange
      final eth0 = MockNetworkInterface();
      when(eth0.name).thenReturn('eth0');
      when(eth0.addresses).thenReturn([InternetAddress('10.0.0.2')]);

      final interfaces = [eth0];
      filter(NetworkInterface iface) => false;
      final priorityOrder = ['eth'];

      // Act
      final result = await findBestNetworkIp(
        interfaces: interfaces,
        filter: filter,
        priorityOrder: priorityOrder,
      );

      // Assert
      expect(result, isNull);
    });

    test('returns null when no addresses found', () async {
      // Arrange
      final wlan0 = MockNetworkInterface();
      when(wlan0.name).thenReturn('wlan0');
      when(wlan0.addresses).thenReturn([]);

      final interfaces = [wlan0];
      filter(NetworkInterface iface) => true;
      final priorityOrder = ['wlan'];

      // Act
      final result = await findBestNetworkIp(
        interfaces: interfaces,
        filter: filter,
        priorityOrder: priorityOrder,
      );

      // Assert
      expect(result, isNull);
    });

    test('resolves tie by interface name alphabetically', () async {
      // Arrange
      final eth1 = MockNetworkInterface();
      when(eth1.name).thenReturn('eth1');
      when(eth1.addresses).thenReturn([InternetAddress('10.0.0.3')]);

      final eth0 = MockNetworkInterface();
      when(eth0.name).thenReturn('eth0');
      when(eth0.addresses).thenReturn([InternetAddress('10.0.0.2')]);

      final interfaces = [eth1, eth0];
      filter(NetworkInterface iface) => true;
      final priorityOrder = ['eth'];

      // Act
      final result = await findBestNetworkIp(
        interfaces: interfaces,
        filter: filter,
        priorityOrder: priorityOrder,
      );

      // Assert
      expect(result, equals('10.0.0.2'));
    });

    test(
        'skips highest priority interface due to filter and selects the next one',
        () async {
      // Arrange
      final eth0 = MockNetworkInterface();
      when(eth0.name).thenReturn('eth0');
      when(eth0.addresses).thenReturn([InternetAddress('10.0.0.2')]);

      final eth1 = MockNetworkInterface();
      when(eth1.name).thenReturn('eth1');
      when(eth1.addresses).thenReturn([InternetAddress('10.0.0.3')]);

      final interfaces = [eth0, eth1];
      // eth0 is filtered out
      filter(NetworkInterface iface) => iface.name != 'eth0';
      final priorityOrder = ['eth', 'wlan'];

      // Act
      final result = await findBestNetworkIp(
        interfaces: interfaces,
        filter: filter,
        priorityOrder: priorityOrder,
      );

      // Assert
      expect(result, equals('10.0.0.3'));
    });
  });
}
