import 'dart:io';

import 'package:display_flutter/utility/device_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'ip_util_test.mocks.dart';

@GenerateMocks([NetworkInterface])
void main() {
  group('findIpAddressByDeviceType', () {
    test('returns IP when preferred interface is not excluded', () async {
      // Arrange
      final wlan0 = MockNetworkInterface();
      when(wlan0.name).thenReturn('wlan0');
      when(wlan0.addresses).thenReturn([InternetAddress('192.168.0.101')]);

      final eth0 = MockNetworkInterface();
      when(eth0.name).thenReturn('eth0');
      when(eth0.addresses).thenReturn([InternetAddress('10.0.0.2')]);

      final interfaces = [wlan0, eth0];

      final result = await findIpAddressByDeviceType(
        interfaces,
        'IFP52_1C',
      );

      // Assert
      expect(result, equals('10.0.0.2'));
    });

    test('dvLED should exclude eth1', () async {
      // Arrange
      final eth1 = MockNetworkInterface();
      when(eth1.name).thenReturn('eth1');
      when(eth1.addresses).thenReturn([InternetAddress('10.0.0.2')]);

      final wlan0 = MockNetworkInterface();
      when(wlan0.name).thenReturn('wlan0');
      when(wlan0.addresses).thenReturn([InternetAddress('192.168.0.101')]);

      final interfaces = [eth1, wlan0];

      final result = await findIpAddressByDeviceType(
        interfaces,
        'dvLED',
      );

      // Assert
      expect(result, equals('192.168.0.101'));
    });
  });
}
