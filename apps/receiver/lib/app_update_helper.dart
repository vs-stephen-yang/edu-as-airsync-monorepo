import 'dart:async';
import 'dart:io';

import 'package:app_ota_flutter/app_ota_flutter.dart';
import 'package:app_ota_flutter/model/ota_info.dart';
import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/services/display_service_broadcast.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// IFP (arch):  Can Updated with silent install
/// EDLA (arch): Can Updated with silent install
/// OPEN: Can Updated with Google UI
/// STORE: Integrate InAppUpdate, wait verify

class AppUpdateHelper implements AppUpdateListener {
  OtaEnvironment _otaEnvironment = OtaEnvironment.production;
  OtaFlavor _otaFlavor = OtaFlavor.ifp;

  // 用來記錄，當次為下載apk，不安裝。
  bool newVersionDownloaded = false;
  bool appAlarmOTA = false;

  // 防止重複啟動下載進程
  bool _isCheckingUpdate = false;

  // 記錄當前下載狀態
  bool _isDownloading = false;

  // 追踪上次輸出日志的百分比，避免重複輸出
  int _lastLoggedPercent = -1;

  get otaFlavor => _otaFlavor;

  // 定義每個型號對應的最低支援日期版本 (白名單)
  final Map<String, int> _minSupportedVersions = {
    "IFP35": 20260129,
    "IFP41": 20260129,
    "IFP51": 20260205,
  };

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
  }

  initializeChecking() async {
    log.info(
        '[OTA] initializeChecking called: isDownloading=$_isDownloading isChecking=$_isCheckingUpdate');

    // 如果已經在檢查/下載中，不重新啟動 OTA process
    if (AppOtaFlutter().isCheckingUpdate || _isCheckingUpdate) {
      log.info('[OTA] Already checking/downloading, skip initialization');
      return;
    }

    // ✅ 設置自己為 SDK 的 listener
    log.info('[OTA] Setting AppUpdateHelper as listener');
    AppOtaFlutter().setListener(this);

    if (_otaFlavor == OtaFlavor.store) {
      await checkInAppUpdate();
    }
    try {
      await checkAppUpdate(true).timeout(const Duration(seconds: 30));
      if (!AppOtaFlutter().isNeedInAppUpdate) {
        FlutterNativeSplash.remove();
      }
    } on TimeoutException {
      log.info('[OTA] checkAppUpdate timeout');
      FlutterNativeSplash.remove();
    } catch (e) {
      FlutterNativeSplash.remove();
    }
  }

  Future<void> checkAppUpdate(bool isStartupCheck) async {
    log.info('[OTA] InApp _otaState: $_otaEnvironment');
    log.info('[OTA] InApp _otaFlavor: $_otaFlavor');
    log.info(
        '[OTA] checkAppUpdate: isStartup=$isStartupCheck env=$_otaEnvironment flavor=$_otaFlavor isChecking=$_isCheckingUpdate');

    // 如果已經在檢查/下載中，跳過重複調用
    if (_isCheckingUpdate) {
      log.info(
          '[OTA] checkAppUpdate: Already checking/downloading, skip startOTAProcess');
      return;
    }

    _isCheckingUpdate = true;
    log.info('[OTA] checkAppUpdate: Starting OTA process');

    String deviceType = '';
    String? fwVersion;
    bool isEDLASupportOTA = false;
    // 安全解析當前設備的版本號
    try {
      deviceType = await DeviceInfoVs.deviceType ?? '';
      fwVersion = await DeviceInfoVs.getFirmwareVersion;
      log.info(
          '[OTA] Initial check - deviceType: $deviceType, fwVersion: $fwVersion');
      // 核心判斷邏輯 (封裝起來更乾淨)
      isEDLASupportOTA = checkEDLASupport(deviceType, fwVersion);
      log.info('[OTA] isEDLASupportOTA: $isEDLASupportOTA');
    } catch (e, stack) {
      // 即使拋出異常，我們也不 return，讓非 edla 的 flavor 有機會繼續
      log.warning('[OTA] Failed to get device info: $e', stack);
    }

    // 如果是 edla 且不符合版本支援，則跳過更新並重置 flag
    if (_otaFlavor == OtaFlavor.edla && !isEDLASupportOTA) {
      log.info('[OTA] EDLA device version not supported, skipping.');
      _isCheckingUpdate = false;
      return;
    }

    await AppOtaFlutter().startOTAProcess(
      OtaApp.display,
      _otaEnvironment,
      _otaFlavor,
      isStartupCheck: isStartupCheck,
      fwVersion: fwVersion,
    );
  }

  // 檢查邏輯：
  // - 檢查型號是否在白名單內
  // - 檢查當前版本是否大於或等於該型號規定的版本
  bool checkEDLASupport(String type, String? version) {
    // A. 如果版本為 null 或空字串，直接判定不支援
    if (version == null || version.isEmpty) return false;

    // B. 嘗試轉換日期字串為數字
    // 如果字串包含非數字（如 "v1.0"），tryParse 會回傳 null
    final int? currentVersion = int.tryParse(version);
    if (currentVersion == null) {
      log.warning('[OTA] Invalid fwVersion format: $version');
      return false;
    }

    // C. 檢查型號是否存在於清單中
    final int? minVersion = _minSupportedVersions[type];
    if (minVersion == null) {
      log.info('[OTA] Device type $type not in EDLA whitelist');
      return false;
    }

    // D. 最終日期比較
    return currentVersion >= minVersion;
  }

  // 重置檢查標記（在下載完成/失敗/無更新時調用）
  void resetCheckingFlag() {
    log.info('[OTA] resetCheckingFlag: Resetting flags');
    _isCheckingUpdate = false;
    _isDownloading = false;
    _lastLoggedPercent = -1;
  }

  startAppUpdate(String filePath) async {
    DisplayServiceBroadcast.instance?.dispose();
    if (_otaFlavor == OtaFlavor.ifp || _otaFlavor == OtaFlavor.edla) {
      // silent install
      await AppOtaFlutter().startSilentInstallApk(filePath);
    } else {
      // using google UI
      await AppOtaFlutter().startInstallApk(filePath);
    }
  }

  checkInAppUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await InAppUpdate.checkForUpdate().then((info) {
      log.info('[OTA] InApp info: ${info.toString()}');
      AppOtaFlutter().isNeedInAppUpdate =
          info.availableVersionCode! > int.parse(packageInfo.buildNumber);
    }).catchError((e) {
      log.severe('[OTA] InApp error', e);
      AppOtaFlutter().isNeedInAppUpdate = false;
    });
  }

  startInAppUpdate() {
    InAppUpdate.performImmediateUpdate().then((result) {
      log.info('[OTA] InApp result: ${result.toString()}');
      if (result == AppUpdateResult.success) {
        trackEvent('ota_success', EventCategory.system);
      } else {
        trackEvent('ota_fail', EventCategory.system);
      }
    }).catchError((e) {
      log.severe('[OTA] InApp error', e);
      trackEvent('ota_fail', EventCategory.system);
    });
  }

  // 安裝 APK
  Future<void> _installNow(OtaInfo? info) async {
    var folder = await getExternalStorageDirectory();
    var otaFile = File("${folder?.path}/${info?.fileName}");
    await startAppUpdate(otaFile.path);
  }

  // ✅ 實現 AppUpdateListener 接口，處理所有 OTA 狀態變化
  @override
  Future<void> onUpdateCheckFinished(
    UpdateStatus status,
    OtaInfo? info, {
    double? progress,
  }) async {
    log.info('[OTA] onUpdateCheckFinished: status=$status, progress=$progress');

    switch (status) {
      case UpdateStatus.updateDownloading:
        if (progress == -1) {
          FlutterNativeSplash.remove();
          // [USER STORY 90944] Silent software OTA，不顯示UI
        } else if (progress != null) {
          int progressPercent = (progress * 100).toInt();
          if ([10, 20, 30, 40, 50, 70, 80, 100].contains(progressPercent) &&
              progressPercent != _lastLoggedPercent) {
            log.info('[OTA] PROGRESS: $progressPercent%');
            _lastLoggedPercent = progressPercent; // 記錄已輸出的百分比
          }
        }
        // 標記本次為下載，不安裝
        newVersionDownloaded = true;
        // 記錄下載狀態
        _isDownloading = true;
        break;

      case UpdateStatus.updateDownloaded:
        log.info('[OTA] DOWNLOADED');
        // 下載完成，重置標記
        resetCheckingFlag();

        if (_otaFlavor == OtaFlavor.ifp || _otaFlavor == OtaFlavor.edla) {
          // 如果這次是下載，則略過安裝流程。如果是Alarm就安裝。
          if (!newVersionDownloaded || appAlarmOTA) {
            AppOtaFlutter().isNeedInAppUpdate = true;
            await _installNow(info);
            if (_otaFlavor == OtaFlavor.edla) {
              FlutterNativeSplash.remove();
            }
          }
        } else {
          // Open/Store flavor 需要顯示 dialog，但目前不需要
          log.info('[OTA] Open/Store flavor update downloaded');
        }
        break;

      case UpdateStatus.updateInApp:
        log.info('[OTA] IN_APP_UPDATE');
        // InApp 更新，重置標記
        resetCheckingFlag();
        startInAppUpdate();
        break;

      case UpdateStatus.updateToDate:
      case UpdateStatus.unknown:
        // 沒有更新或未知狀態，重置標記
        log.info('[OTA] NO_UPDATE_OR_UNKNOWN: status=$status');
        resetCheckingFlag();
        break;
    }
  }
}
