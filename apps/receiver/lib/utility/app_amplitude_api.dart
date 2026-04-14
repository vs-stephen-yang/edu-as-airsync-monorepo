import 'dart:convert';

import 'package:amplitude_flutter/constants.dart';
import 'package:display_flutter/utility/app_amplitude.dart';
import 'package:display_flutter/utility/client_device_info.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:http/http.dart' as http;

class AppAmplitudeApi implements AppAmplitudeImplement {
  String _apiKey = '';
  String _deviceId = '';
  String _userId = '';
  String _appVersion = '';
  ClientDeviceInfo? _clientDeviceInfo;
  final _globalProperties = <String, String>{};

  @override
  Future<void> ensureInitialized({
    required String apiKey,
    ServerZone? serverZone,
    required String instanceName,
    String? deviceId,
    String? userId,
    String? appVersion,
    ClientDeviceInfo? clientDeviceInfo,
  }) async {
    _apiKey = apiKey;
    _deviceId = deviceId ?? '';
    _userId = userId ?? '';
    _appVersion = appVersion ?? '';
    _clientDeviceInfo = clientDeviceInfo;
  }

  @override
  void setGlobalProperty(String name, String value) {
    _globalProperties[name] = value;
  }

  @override
  Future<void> trackEvent(
    String name, {
    String? userId,
    Map<String, dynamic> properties = const <String, dynamic>{},
  }) async {
    //  HTTP API
    await _sendHttpEvent(
      eventType: name,
      userId: userId,
      eventProperties: {
        ...properties,
        ..._globalProperties,
      },
    );
  }

  /// Internal: Send HTTP request to Amplitude
  Future<void> _sendHttpEvent({
    required String eventType,
    String? userId,
    Map<String, dynamic>? eventProperties,
  }) async {
    final uri = Uri.parse('https://api2.amplitude.com/2/httpapi');
    final ip = await getPublicIP();

    // https://amplitude.com/docs/apis/analytics/http-v2#body-parameters
    final body = jsonEncode({
      'api_key': _apiKey,
      'events': [
        {
          'user_id': userId ?? _userId,
          'device_id': _deviceId,
          'event_type': eventType,
          'time': DateTime.now().millisecondsSinceEpoch,
          'event_properties': eventProperties ?? {},
          'user_properties': {
            'device_type':
                '${_clientDeviceInfo?.clientType} ${_clientDeviceInfo?.clientModel}',
          },
          'app_version': _appVersion,
          'platform': _clientDeviceInfo?.clientType,
          'os_name': _clientDeviceInfo?.clientOs,
          'language': _clientDeviceInfo?.locale,
          'ip': ip,
        }
      ],
    });

    try {
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
        body: body,
      );
    } catch (e) {
      log.severe('Amplitude HTTP API Error: $e');
    }
  }

  Future<String> getPublicIP() async {
    final response = await http.get(Uri.parse('https://api.ipify.org'));
    if (response.statusCode == 200) {
      return response.body.trim();
    } else {
      log.warning('Amplitude HTTP API failed to get public IP');
      return '';
    }
  }
}
