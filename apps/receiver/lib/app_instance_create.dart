import 'dart:convert';
import 'dart:io' show Platform;

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/utility/aes_cipher.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AppInstanceCreate {
  static final AppInstanceCreate _instance = AppInstanceCreate._internal();

  //private "Named constructors"
  AppInstanceCreate._internal();

  // passes the instantiation to the _instance object
  factory AppInstanceCreate() => _instance;

  static ensureInitialized(
      ConfigSettings settings, PackageInfo packageInfo) async {
    await _instance._createInstanceId(settings, packageInfo);
  }

  bool _isRegistered = false;

  bool get isRegistered => _isRegistered;

  // App instance id, for admin backend used (Crash report, Application insight,...)
  String _instanceID = '';

  String get instanceID => _instanceID;

  String _serialNumber = '';

  String get serialNumber => _serialNumber;

  String _modelName = '';

  String get modelName => _modelName;

  String _groupID = '';

  String get groupID => _groupID;

  bool get isInstalledInVBS100 => _modelName == 'VBS100';

  bool get isInstalledInVBS200 => _modelName.startsWith('VBS200');

  // Display instance id, for Display backend used (Control socket, entity enroll,...)
  // "VBS100" is serial number, others is App instance id
  String get displayInstanceID =>
      isInstalledInVBS100 ? _serialNumber : _instanceID;

  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_isRegistered', _isRegistered);
    await prefs.setString('app_instanceID', _instanceID);
    await prefs.setString('app_serialNumber', _serialNumber);
    await prefs.setString('app_modelName', _modelName);
    await prefs.setString('app_groupID', _groupID);
  }

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isRegistered = prefs.getBool('app_isRegistered') ?? false;
    _instanceID = prefs.getString('app_instanceID') ?? '';
    _serialNumber = prefs.getString('app_serialNumber') ?? '';
    _modelName = prefs.getString('app_modelName') ?? '';
    _groupID = prefs.getString('app_groupID') ?? '';
  }

  _createInstanceId(ConfigSettings settings, PackageInfo packageInfo) async {
    await _load();

    if (_instanceID.isEmpty) {
      try {
        _serialNumber = (Platform.isWindows) ? '1234567890' : await DeviceInfoVs.serialNumber ?? '1234567890';
      } on PlatformException {
        _serialNumber = '1234567890';
      }
      log.info('serialId: $_serialNumber');

      _instanceID = await _generateInstanceID(_serialNumber);
      _save();
    }
    if (_groupID.isEmpty) {
      _groupID = const Uuid().v4();
      _save();
    }
    log.info('create instance: $_instanceID');
    if (!_isRegistered) {
      bool success;
      success = await _registerInstanceId(settings.icarHostName,
          settings.icarRegisterUrl, _instanceID, packageInfo);
      if (success) {
        _isRegistered = true;
        _save();
      }
    }
  }

  Future<String> _generateInstanceID(String serialId) async {
    String deviceId;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      deviceId = (const Uuid()).v4();
      _modelName = '';
    } else {
      if (Platform.isAndroid) {
        String? androidId = await DeviceInfoVs.getAndroidID;
        AndroidDeviceInfo info = await deviceInfo.androidInfo;
        deviceId = androidId!;
        _modelName = info.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo info = await deviceInfo.iosInfo;
        deviceId = info.identifierForVendor!;
        _modelName = info.model;
      } else if (Platform.isWindows) {
        WindowsDeviceInfo info = await deviceInfo.windowsInfo;
        deviceId = info.deviceId;
        _modelName = info.productName;
      } else {
        deviceId = (const Uuid()).v4(); // todo: support other platform id.
        _modelName = '';
      }
    }
    return _generateMd5(deviceId + serialId);
  }

  String _generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString().toUpperCase();
  }

  Future<bool> _registerInstanceId(String hostName, String registerUrl,
      String instanceID, PackageInfo packageInfo) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=utf-8'
    };
    http.Client client = http.Client();
    try {
      String key = aesEncryptWithBase64(instanceID, hostName);
      String url = registerUrl + Uri.encodeFull(key);
      String content = await _buildAppRegisterString(instanceID, packageInfo);
      var response =
          await client.post(Uri.parse(url), headers: headers, body: content);
      log.info('registerInstanceId ${response.statusCode}');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log.severe('_registerInstanceId', e);
    } finally {
      client.close();
    }
    return false; //default true for "no internet connection"
  }

  Future<String> _buildAppRegisterString(
      String instanceID, PackageInfo packageInfo) async {
    String platform;
    if (kIsWeb) {
      platform = 'Web';
    } else {
      if (Platform.isIOS) {
        platform = 'iOS';
      } else if (Platform.isAndroid) {
        platform = 'Android';
      } else if (Platform.isWindows) {
        platform = 'Windows';
      } else {
        platform = ''; // todo: support other platform.
      }
    }

    // analytics
    Map<String, dynamic> analytics = {
      'CurrentVersion': packageInfo.version,
      'UpdateHistory': packageInfo.version,
      'InstallPlatform': platform,
      'AppName': packageInfo.appName,
    };

    // hardwareProperty
    Map<String, dynamic> hardwareProperty;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      WebBrowserInfo info = await deviceInfo.webBrowserInfo;
      hardwareProperty = {
        'TimeStamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'browserName': info.browserName.toString(),
        'appName': info.appName,
        'platform': info.platform,
        'userAgent': info.userAgent,
      };
    } else {
      if (Platform.isAndroid) {
        String? androidId = await DeviceInfoVs.getAndroidID;
        AndroidDeviceInfo info = await deviceInfo.androidInfo;
        hardwareProperty = {
          'TimeStamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'Android ID': androidId,
          'Android Release': info.version.release,
          'Brand': info.brand,
          'Hardware': info.hardware,
          'Manufacturer': info.manufacturer,
          'Model': info.model,
          'Serial': _serialNumber,
          'Support_abi32': info.supported32BitAbis.toString(),
          'Support_abi64': info.supported64BitAbis.toString(),
          'Support_abi': info.supportedAbis.toString(),
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo info = await deviceInfo.iosInfo;
        hardwareProperty = {
          'TimeStamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'IdentifierForVendor': info.identifierForVendor,
          'SystemVersion': info.systemVersion,
          'SystemName': info.systemName,
          'Machine': info.utsname.machine,
          'Model': info.model,
        };
      } else if (Platform.isWindows) {
        WindowsDeviceInfo info = await deviceInfo.windowsInfo;
        hardwareProperty = {
          'TimeStamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'productName': info.productName,
          'majorVersion': info.majorVersion,
          'minorVersion': info.minorVersion,
          'buildNumber': info.buildNumber,
        };
      } else {
        hardwareProperty = {}; // todo: support other platform.
      }
    }

    Map<String, dynamic> request = {
      'uid': instanceID,
      'version': packageInfo.version,
      'property': hardwareProperty,
      'analytics': analytics,
      'platform_type': platform,
    };
    return json.encode(request);
  }
}
