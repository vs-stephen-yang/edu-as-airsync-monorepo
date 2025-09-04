import 'dart:async';

import 'package:app_ota_flutter/app_ota_flutter.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/services/display_service_broadcast.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'model/hybrid_connection_list.dart';

/// IFP (arch):  Can Updated with silent install
/// EDLA (arch): Can Updated with silent install
/// OPEN: Can Updated with Google UI
/// STORE: Integrate InAppUpdate, wait verify

class AppUpdateHelper {
  OtaEnvironment _otaEnvironment = OtaEnvironment.production;
  OtaFlavor _otaFlavor = OtaFlavor.ifp;

  // 用來記錄，當次為下載apk，不安裝。
  bool newVersionDownloaded = false;
  bool appAlarmOTA = false;

  get otaFlavor => _otaFlavor;

  ensureInitialized(ConfigSettings configSettings) async {
    if (configSettings.isDevelopEnvironment) {
      _otaEnvironment = OtaEnvironment.stage;
    }
    var channel = const MethodChannel('com.mvbcast.crosswalk/app_update');
    String flavor = await channel.invokeMethod("getFlavor");
    switch (flavor) {
      case 'ifp':
        _otaFlavor = OtaFlavor.ifp;
        break;
      case 'open':
        _otaFlavor = OtaFlavor.open;
        break;
      case 'store':
        _otaFlavor = OtaFlavor.store;
        break;
      case 'edla':
        _otaFlavor = OtaFlavor.edla;
        break;
    }

    var channelAlarm =
        const MethodChannel('com.mvbcast.crosswalk/app_update_alarm');
    channelAlarm.setMethodCallHandler((call) async {
      if (call.method == 'AppAlarmOTA') {
        appAlarmOTA = true;
        await checkAppUpdate(true);
      }
    });

    var channelSleepStatus =
        const MethodChannel('com.mvbcast.crosswalk/sleep_status');
    channelSleepStatus.setMethodCallHandler((call) async {
      if (call.method == 'onSleepStatusChanged') {
        newVersionDownloaded = false;
        if (HybridConnectionList.hybridSplitScreenCount.value == 0) {
          await checkAppUpdate(true);
        }
      }
    });
  }

  initializeChecking({required AppUpdateListener listener}) async {
    AppOtaFlutter().setListener(listener);
    if (_otaFlavor == OtaFlavor.store) {
      checkInAppUpdate();
    }
    await checkAppUpdate(true);
  }

  checkAppUpdate(bool isStartupCheck) async {
    log.info('InApp _otaState: $_otaEnvironment');
    log.info('InApp _otaFlavor: $_otaFlavor');
    if (_otaFlavor != OtaFlavor.edla) {
      unawaited(
        AppOtaFlutter().startOTAProcess(
            OtaApp.display, _otaEnvironment, _otaFlavor,
            isStartupCheck: isStartupCheck),
      );
    }
  }

  startAppUpdate(String filePath) async {
    DisplayServiceBroadcast.instance.dispose();
    if (_otaFlavor == OtaFlavor.ifp || _otaFlavor == OtaFlavor.edla) {
      // silent install
      unawaited(AppOtaFlutter().startSilentInstallApk(filePath));
    } else {
      // using google UI
      unawaited(AppOtaFlutter().startInstallApk(filePath));
    }
  }

  checkInAppUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await InAppUpdate.checkForUpdate().then((info) {
      log.info('InApp info: ${info.toString()}');
      AppOtaFlutter().isNeedInAppUpdate =
          info.availableVersionCode! > int.parse(packageInfo.buildNumber);
    }).catchError((e) {
      log.severe('InApp error', e);
      AppOtaFlutter().isNeedInAppUpdate = false;
    });
  }

  startInAppUpdate() {
    InAppUpdate.performImmediateUpdate().then((result) {
      log.info('InApp result: ${result.toString()}');
      if (result == AppUpdateResult.success) {
        trackEvent('ota_success', EventCategory.system);
      } else {
        trackEvent('ota_fail', EventCategory.system);
      }
    }).catchError((e) {
      log.severe('InApp error', e);
      trackEvent('ota_fail', EventCategory.system);
    });
  }
}
