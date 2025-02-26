import 'dart:async';

import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_flutter/app_overlay_tab.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/utility/device_feature_adapter.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mirror/airplay_config.dart';
import 'package:flutter_mirror/flutter_mirror.dart';
import 'package:flutter_mirror/flutter_mirror_config.dart';
import 'package:flutter_mirror/flutter_mirror_listener.dart';
import 'package:flutter_mirror/googlecast_config.dart';
import 'package:flutter_mirror/mirror_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum MirrorState {
  idle,
  mirroring,
  moderatorIdle,
}

class MirrorStateProvider extends ChangeNotifier
    implements FlutterMirrorListener {
  MirrorStateProvider(
    this._instanceInfoProvider,
  ) {
    _load();
    _flutterMirrorPlugin = FlutterMirror();
    _initPlatformState();
  }

  startMirrorStartProvider() {
    _instanceInfoProvider.addListener(_onInstanceInfoUpdated);
  }

  get miracastSupport => _miracastSupport;

  get airplayEnabled => _airplayEnabled;

  get googleCastEnabled => _googleCastEnabled;

  get miracastEnabled => _miracastEnabled;

  get isAnyMirrorEnabled =>
      _airplayEnabled | _googleCastEnabled | _miracastEnabled;

  String get pinCode => _pinCode;

  final InstanceInfoProvider _instanceInfoProvider;

  FlutterMirror? _flutterMirrorPlugin;
  String _deviceName = '';
  bool _miracastSupport = true;
  bool _airplayEnabled = false;
  bool _googleCastEnabled = false;
  bool _miracastEnabled = false;
  Timer? _initTimer;
  bool isPlatformInitialized = false;
  String _pinCode = '';
  Timer? _pinTimer;
  bool _sizeChanged = false;
  Size _videoWidgetSize = const Size(0, 0);
  Offset _videoWidgetOffset = const Offset(0, 0);
  Map<MirrorType, bool> mirrorTypeState = {
    MirrorType.airplay: false,
    MirrorType.googlecast: false,
    MirrorType.miracast: false,
  };

  bool _isMirrorConfirmation = false;

  bool get isMirrorConfirmation => _isMirrorConfirmation;

  set isMirrorConfirmation(bool value) {
    _set(autoAcceptRequired: _isMirrorConfirmation = value);
    notifyListeners();
  }

  bool _airplayCodeEnabled = false;

  bool get airPlayCodeEnable => _airplayCodeEnabled;

  Future<void> setAirPlayCodeEnable(bool value) async {
    await _set(airplayCodeEnable: _airplayCodeEnabled = value);
    if (_airplayEnabled) {
      await stopAirPlay(updatePreference: false)
          .whenComplete(() => startAirPlay());
    }
    notifyListeners();
  }

  void _onInstanceInfoUpdated() async {
    if (!isPlatformInitialized) {
      _initTimer?.cancel();
      _initTimer = Timer(const Duration(milliseconds: 500), () {
        _onInstanceInfoUpdated();
        _initTimer = null;
      });
      return;
    }
    if (_deviceName != _instanceInfoProvider.deviceName) {
      _deviceName = _instanceInfoProvider.deviceName;

      // restart when device name changed.
      await restartMirror();
    }
  }

  // region FlutterMirrorListener
  @override
  void onMirrorAuth(String pin, int timeoutSec) {
    log.info('onMirrorAuth');
    _pinCode = pin;
    _pinTimer?.cancel();
    _pinTimer = Timer(Duration(seconds: timeoutSec), () {
      _pinCode = '';
      notifyListeners();
    });

    notifyListeners();

    AppOverlayTab().launchApp();
  }

  @override
  void onMirrorStart(String mirrorId, int textureId, String deviceName,
      MirrorType mirrorType) {
    log.info('onMirrorStart');
    if (mirrorType == MirrorType.airplay) {
      _pinTimer?.cancel();
      _pinCode = '';
    }

    if (HybridConnectionList().connectionListFull()) {
      stopAcceptedMirror(mirrorId);
    } else {
      HybridConnectionList().addConnection(MirrorRequest(
          _flutterMirrorPlugin, mirrorId, textureId, deviceName, mirrorType));
    }

    notifyListeners();

    AppOverlayTab().launchApp();
  }

  @override
  void onMirrorStop(String mirrorId) {
    log.info('onMirrorStop $mirrorId');
    for (MirrorRequest request
        in HybridConnectionList().getMirrorMap().values) {
      if (request.mirrorId == mirrorId) {
        HybridConnectionList().removeConnection(request);
        HybridConnectionList().updateSplitScreen();
        notifyListeners();
      }
    }
  }

  @override
  void onMirrorVideoResize(String mirrorId, int width, int height) {
    log.info('onMirrorVideoResize');
    for (var entry in HybridConnectionList().getMirrorMap().entries) {
      if (entry.value.mirrorId == mirrorId) {
        MirrorRequest request = entry.value;
        request.aspectRatio = width / height;
        HybridConnectionList()
            .getMirrorMap()
            .update(entry.key, (value) => request);

        _sizeChanged = true;
        notifyListeners();
        break;
      }
    }
  }

  // endregion

  // region Public method

  clearPinCode() {
    _pinTimer?.cancel();
    _pinCode = '';
  }

  clearRequestMirrorId(String? mirrorId) {
    for (MirrorRequest request
        in HybridConnectionList().getMirrorMap().values) {
      if (request.mirrorId == mirrorId) {
        _flutterMirrorPlugin?.stopMirror(request.mirrorId);
        HybridConnectionList().removeConnection(request);
      }
    }
    notifyListeners();
  }

  setAcceptMirrorId(String? mirrorId) {
    if (HybridConnectionList().getMirrorMap().isNotEmpty) {
      for (var entry in HybridConnectionList().getMirrorMap().entries) {
        if (entry.value.mirrorId == mirrorId) {
          MirrorRequest request = entry.value;
          request.mirrorState = MirrorState.mirroring;
          request.controlAudio(true, setIsAudioEnabled: true);
          HybridConnectionList()
              .getMirrorMap()
              .update(entry.key, (value) => request);
        }
      }

      // _aspectRatio = _mirrorRequestList[index].aspectRatio;
      _sizeChanged = true;

      HybridConnectionList().updateSplitScreen();
      StreamFunction.streamFunctionState.value = stateMenuOff;
      notifyListeners();
    }
  }

  setModeratorIdleMirrorId(String? mirrorId) {
    if (HybridConnectionList().getMirrorMap().isNotEmpty) {
      for (var entry in HybridConnectionList().getMirrorMap().entries) {
        if (entry.value.mirrorId == mirrorId) {
          MirrorRequest request = entry.value;
          request.mirrorState = MirrorState.moderatorIdle;
          request.controlAudio(false, setIsAudioEnabled: false);
          HybridConnectionList()
              .getMirrorMap()
              .update(entry.key, (value) => request);
        }
      }

      _sizeChanged = true;

      HybridConnectionList().updateSplitScreen();
      StreamFunction.streamFunctionState.value = stateMenuOff;
      notifyListeners();
    }
  }

  stopAcceptedMirror(String? mirrorId) {
    log.info('stopAcceptedMirror');
    if (mirrorId != null) {
      _flutterMirrorPlugin?.stopMirror(mirrorId);
    }
  }

  updateAllAudioEnableState(bool enable) {
    for (MirrorRequest request
        in HybridConnectionList().getMirrorMap().values) {
      request.controlAudio(request.isAudioEnabled & enable,
          setIsAudioEnabled: false);
    }
  }

  onTouchEvent(PointerEvent event, String? mirrorId, GlobalKey mirrorViewKey) {
    if (mirrorId == null) {
      return;
    }

    if (_sizeChanged) {
      _getWidgetInfo(mirrorViewKey);
    }

    _flutterMirrorPlugin?.onMirrorTouch(
        mirrorId,
        event.pointer,
        event.down,
        ((event.position.dx.toInt() - _videoWidgetOffset.dx.toInt()) /
            _videoWidgetSize.width.toInt()),
        ((event.position.dy.toInt() - _videoWidgetOffset.dy.toInt()) /
            _videoWidgetSize.height.toInt()));
  }

  onWidgetSizeChanged() {
    _sizeChanged = true;
  }

  Future<void> startAirPlay({bool updatePreference = true}) async {
    log.info('startAirPlay');
    await _flutterMirrorPlugin?.startAirplay(AirplayConfig(
      name: _deviceName,
      security: _airplayCodeEnabled
          ? AirplaySecurity.onscreenCode
          : AirplaySecurity.none,
    ));
    if (updatePreference) {
      await _set(airplayEnable: true);
    }
    notifyListeners();
  }

  Future<void> stopAirPlay({bool updatePreference = true}) async {
    log.info('stopAirPlay');
    for (MirrorRequest request
        in HybridConnectionList().getMirrorMap().values) {
      if (request.mirrorType == MirrorType.airplay) {
        stopAcceptedMirror(request.mirrorId);
      }
    }
    await _flutterMirrorPlugin?.stopAirplay();
    if (updatePreference) {
      await _set(airplayEnable: false);
    }
    notifyListeners();
  }

  Future<void> startGoogleCast({bool updatePreference = true}) async {
    log.info('startGoogleCast');
    await _flutterMirrorPlugin?.startGooglecast(GooglecastConfig(
      name: _deviceName,
      uniqueId: (const Uuid()).v4(),
    ));
    if (updatePreference) {
      await _set(googleCastEnable: true);
    }
    notifyListeners();
  }

  Future<void> stopGoogleCast({bool updatePreference = true}) async {
    log.info('stopGoogleCast');
    for (MirrorRequest request
        in HybridConnectionList().getMirrorMap().values) {
      if (request.mirrorType == MirrorType.googlecast) {
        stopAcceptedMirror(request.mirrorId);
      }
    }
    await _flutterMirrorPlugin?.stopGooglecast();
    if (updatePreference) {
      await _set(googleCastEnable: false);
    }
    notifyListeners();
  }

  Future<void> startMiracast({bool updatePreference = true}) async {
    if (!_miracastSupport) return;

    log.info('startMiracast');
    await _flutterMirrorPlugin?.startMiracast(_deviceName);
    if (updatePreference) {
      await _set(miracastEnable: true);
    }
    notifyListeners();
  }

  Future<void> stopMiracast({bool updatePreference = true}) async {
    if (!_miracastSupport) return;

    log.info('stopMiracast');
    for (MirrorRequest request
        in HybridConnectionList().getMirrorMap().values) {
      if (request.mirrorType == MirrorType.miracast) {
        stopAcceptedMirror(request.mirrorId);
      }
    }
    await _flutterMirrorPlugin?.stopMiracast();
    if (updatePreference) {
      await _set(miracastEnable: false);
    }
    notifyListeners();
  }

  Future<void> restartMirror() async {
    log.info('restartMirror');
    if (!HybridConnectionList().isMirroring()) {
      if (_airplayEnabled) {
        await stopAirPlay(updatePreference: false);
        await startAirPlay(updatePreference: false);
      }

      if (_googleCastEnabled) {
        await stopGoogleCast(updatePreference: false);
        await startGoogleCast(updatePreference: false);
      }

      if (_miracastEnabled) {
        await stopMiracast(updatePreference: false);
        await startMiracast(updatePreference: false);
      }
    }
  }

  Future<void> stopAllMirror() async {
    log.info('stopMirror');
    await stopAirPlay(updatePreference: false);

    await stopGoogleCast(updatePreference: false);

    await stopMiracast(updatePreference: false);
  }

  // endregion

  // region Private method
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initPlatformState() async {
    var channel = const MethodChannel('com.mvbcast.crosswalk/app_update');
    String flavor = await channel.invokeMethod("getFlavor") ?? '';
    var deviceType = await DeviceInfoVs.deviceType ?? '';
    log.info('deviceType: $deviceType');
    log.info('flavor: $flavor');
    _miracastSupport = (flavor == 'ifp' && deviceType != 'dvLED');
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      _flutterMirrorPlugin?.registerListener(this);

      // Since quick decode is only effective in addressing latency issue with
      // WebRTC (web sender), and using quick decode with AirPlay and ChromeCast
      // results in decode failures, we have decided to apply quick decode
      // exclusively to WebRTC scenarios for now.
      Map<String, int> options =
          DeviceFeatureAdapter.getDecodeOptions(excludeQuickDecodeParams: true);

      log.info('Initialize mirror. Options: ${options.toString()}');

      await _flutterMirrorPlugin?.initialize(FlutterMirrorConfig(options));
    } on PlatformException catch (e, stackTrace) {
      log.severe('Mirror initialize failure', e, stackTrace);
    }
    isPlatformInitialized = true;
  }

  void _getWidgetInfo(GlobalKey mirrorViewKey) {
    final RenderBox renderBox =
        mirrorViewKey.currentContext?.findRenderObject() as RenderBox;
    _sizeChanged = false;

    _videoWidgetSize = renderBox.size;
    _videoWidgetOffset = renderBox.localToGlobal(Offset.zero);
  }

  _set({
    bool? airplayEnable,
    bool? googleCastEnable,
    bool? miracastEnable,
    bool? airplayCodeEnable,
    bool? autoAcceptRequired,
  }) async {
    if (airplayEnable != null) {
      _airplayEnabled = airplayEnable;
    }
    if (googleCastEnable != null) {
      _googleCastEnabled = googleCastEnable;
    }
    if (miracastEnable != null) {
      _miracastEnabled = miracastEnable;
    }
    if (airplayCodeEnable != null) {
      _airplayCodeEnabled = airplayCodeEnable;
    }
    if (autoAcceptRequired != null) {
      _isMirrorConfirmation = autoAcceptRequired;
    }
    await _save();
  }

  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_AirPlayEnable', _airplayEnabled);
    await prefs.setBool('app_GoogleCastEnable', _googleCastEnabled);
    await prefs.setBool('app_MiracastEnable', _miracastEnabled);
    await prefs.setBool('app_AirPlayCodeEnable', _airplayCodeEnabled);
    await prefs.setBool('app_autoAcceptRequired', _isMirrorConfirmation);
  }

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _airplayEnabled = prefs.getBool('app_AirPlayEnable') ?? true;
    _googleCastEnabled = prefs.getBool('app_GoogleCastEnable') ?? true;
    _miracastEnabled = prefs.getBool('app_MiracastEnable') ?? true;
    _airplayCodeEnabled = prefs.getBool('app_AirPlayCodeEnable') ?? false;
    _isMirrorConfirmation = prefs.getBool('app_autoAcceptRequired') ?? false;
    log.info('load settings.');
  }

  Future<void> reloadPreferences() async {
    await _load();
    notifyListeners();
  }

  @override
  void onMirrorVideoFrameRate(String mirrorId, int fps) {
    // TODO add implementation
  }
// endregion
}
