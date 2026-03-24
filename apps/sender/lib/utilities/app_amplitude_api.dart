import 'dart:convert';
import 'dart:io';

import 'package:amplitude_flutter/constants.dart';
import 'package:display_cast_flutter/utilities/app_amplitude.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/client_device_info.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class AppAmplitudeApi implements AppAmplitudeImplement {
  String _apiKey = '';
  String _deviceId = '';
  String _userId = '';
  String _appVersion = '';
  ClientDeviceInfo? _clientDeviceInfo;
  final _globalProperties = <String, String>{};
  EventMode? _mode;
  late final http.Client _httpClient = _createHttpClient();

  http.Client _createHttpClient() {
    final ioClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) {
        const allowedHosts = ['api2.amplitude.com'];
        return allowedHosts.contains(host);
      };
    return IOClient(ioClient);
  }

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
  void setMode(EventMode? mode) {
    _mode = mode;
  }

  @override
  Future<void> trackEvent(
    String name,
    EventCategory category, {
    String? target,
    Map<String, dynamic> properties = const <String, dynamic>{},
  }) async {
    //  HTTP API
    await _sendHttpEvent(
      eventType: name,
      eventProperties: {
        ...properties,
        ..._globalProperties,
        'category': category.name,
        if (target != null) 'target': target,
        if (_mode != null &&
            (category == EventCategory.session ||
                category == EventCategory.annotation))
          'mode': _mode!.value,
      },
    );
  }

  /// Internal: Send HTTP request to Amplitude
  Future<void> _sendHttpEvent({
    required String eventType,
    Map<String, dynamic>? eventProperties,
  }) async {
    final uri = Uri.parse('https://api2.amplitude.com/2/httpapi');
    final ip = await getPublicIP();

    // https://amplitude.com/docs/apis/analytics/http-v2#body-parameters
    final body = jsonEncode({
      'api_key': _apiKey,
      'events': [
        {
          'user_id': _userId,
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
      await _httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
        body: body,
      );
    } catch (e) {
      log.severe('Amplitude HTTP API Error: $e');
    }
  }

  Future<String> getPublicIP() async {
    try {
      final response =
          await _httpClient.get(Uri.parse('https://api.ipify.org')).timeout(
        const Duration(seconds: 5),
      );
      if (response.statusCode == 200) {
        return response.body.trim();
      }
      log.warning('Amplitude HTTP API failed to get public IP');
      return '';
    } catch (e) {
      log.warning('Amplitude HTTP API failed to get public IP: $e');
      return '';
    }
  }
}
