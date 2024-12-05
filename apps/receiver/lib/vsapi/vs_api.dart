import 'package:display_flutter/utility/log.dart';
import 'package:flutter/services.dart';

class VSApi {
  static const MethodChannel _channel =
      MethodChannel('com.mvbcast.crosswalk/vs_api');

  static Future<VSApi?> createVSApiInstance() async {
    var channel = const MethodChannel('com.mvbcast.crosswalk/app_update');
    final flavor = await channel.invokeMethod("getFlavor");
    if (flavor == 'ifp') {
      return VSApi();
    }

    return null;
  }

  Future<String> getSerialNumber() async {
    try {
      return await _channel.invokeMethod('getSerialNumber');
    } on PlatformException catch (e) {
      log.info('On VSApi getSerialNumber', e);
      return 'Unknown';
    }
  }

  Future<String> getCurrentMacAddress() async {
    try {
      return await _channel.invokeMethod('getCurrentMacAddress');
    } on PlatformException catch (e) {
      log.info('On VSApi getCurrentMacAddress', e);
      return 'Unknown';
    }
  }
}
