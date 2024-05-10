import 'dart:async';

import 'package:display_flutter/app_overlay_tab.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/utility/device_feature_adapter.dart';
import 'package:display_flutter/utility/print_in_debug.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mirror/airplay_config.dart';
import 'package:flutter_mirror/flutter_mirror.dart';
import 'package:flutter_mirror/flutter_mirror_config.dart';
import 'package:flutter_mirror/flutter_mirror_listener.dart';
import 'package:flutter_mirror/googlecast_config.dart';
import 'package:flutter_mirror/mirror_type.dart';
import 'package:uuid/uuid.dart';

enum MirrorState {
  idle,
  mirroring,
}

class MirrorStateProvider extends ChangeNotifier
    implements FlutterMirrorListener {
  MirrorStateProvider(
    this._instanceInfoProvider,
  ) {
    _flutterMirrorPlugin = FlutterMirror();
    _initPlatformState();

    _instanceInfoProvider.addListener(_onInstanceInfoUpdated);
  }

  get airplayEnabled => _airplayEnabled;

  get googleCastEnabled => _googleCastEnabled;

  get miracastEnabled => _miracastEnabled;

  get pinCode => _pinCode;

  final InstanceInfoProvider _instanceInfoProvider;

  FlutterMirror? _flutterMirrorPlugin;
  String _deviceName = '';
  bool _airplayEnabled = false;
  bool _googleCastEnabled = false;
  bool _miracastEnabled = false;
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
    _isMirrorConfirmation = value;
    notifyListeners();
  }

  bool _isAirPlayCode = false;

  bool get isAirPlayCode => _isAirPlayCode;

  set isAirPlayCode(bool value) {
    _isAirPlayCode = value;
    if (_airplayEnabled) {
      stopAirPlay().whenComplete(() => startAirPlay());
    }
    notifyListeners();
  }

  void _onInstanceInfoUpdated() async {
    if (_deviceName != _instanceInfoProvider.deviceName) {
      _deviceName = _instanceInfoProvider.deviceName;

      // restart when device name changed.
      await _restartMirror();
    }
  }

  // region FlutterMirrorListener
  @override
  void onMirrorAuth(String pin, int timeoutSec) {
    printInDebug('onMirrorAuth', type: runtimeType);
    _pinCode = pin;
    _pinTimer?.cancel();
    Home.isShowPinDialog.value = false;
    Home.isShowPinDialog.value = true;

    _pinTimer = Timer(Duration(seconds: timeoutSec), () {
      _pinCode = '';
      Home.isShowPinDialog.value = false;
    });

    AppOverlayTab().launchApp();
  }

  @override
  void onMirrorStart(String mirrorId, int textureId, String deviceName,
      MirrorType mirrorType) {
    printInDebug('onMirrorStart', type: runtimeType);
    _pinTimer?.cancel();
    _pinCode = '';
    Home.isShowPinDialog.value = false;

    HybridConnectionList().addConnection(MirrorRequest(
        _flutterMirrorPlugin, mirrorId, textureId, deviceName, mirrorType));
    Home.isShowAuthDialog.value = false;
    Home.isShowAuthDialog.value = true;

    AppOverlayTab().launchApp();
  }

  @override
  void onMirrorStop(String mirrorId) {
    printInDebug('onMirrorStop $mirrorId', type: runtimeType);
    for (MirrorRequest request
        in HybridConnectionList().getMirrorMap().values) {
      if (request.mirrorId == mirrorId) {
        HybridConnectionList().removeConnection(request);
        HybridConnectionList().updateSplitScreen();
      }
    }
  }

  @override
  void onMirrorVideoResize(String mirrorId, int width, int height) {
    printInDebug('onMirrorVideoResize', type: runtimeType);
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
    Home.isShowPinDialog.value = false;
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

  stopAcceptedMirror(String? mirrorId) {
    printInDebug('stopAcceptedMirror', type: runtimeType);
    if (mirrorId != null) {
      _flutterMirrorPlugin?.stopMirror(mirrorId);
    }
    notifyListeners();
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

  Future<void> startAirPlay() async {
    printInDebug('startAirPlay', type: runtimeType);
    await _flutterMirrorPlugin?.startAirplay(AirplayConfig(
      name: _deviceName,
      security: _isAirPlayCode? AirplaySecurity.onscreenCode: AirplaySecurity.none,
    ));
    _airplayEnabled = true;
    notifyListeners();
  }

  Future<void> stopAirPlay() async {
    printInDebug('stopAirPlay', type: runtimeType);
    for (MirrorRequest request
        in HybridConnectionList().getMirrorMap().values) {
      if (request.mirrorType == MirrorType.airplay) {
        stopAcceptedMirror(request.mirrorId);
      }
    }
    await _flutterMirrorPlugin?.stopAirplay();
    _airplayEnabled = false;
    notifyListeners();
  }

  Future<void> startGoogleCast() async {
    await _flutterMirrorPlugin?.startGooglecast(GooglecastConfig(
      name: _deviceName,
      uniqueId: (const Uuid()).v4(),
    ));
    _googleCastEnabled = true;
    notifyListeners();
  }

  Future<void> stopGoogleCast() async {
    for (MirrorRequest request
        in HybridConnectionList().getMirrorMap().values) {
      if (request.mirrorType == MirrorType.googlecast) {
        stopAcceptedMirror(request.mirrorId);
      }
    }
    await _flutterMirrorPlugin?.stopGooglecast();
    _googleCastEnabled = false;
    notifyListeners();
  }

  Future<void> startMiracast() async {
    await _flutterMirrorPlugin?.startMiracast(_deviceName);
    _miracastEnabled = true;
    notifyListeners();
  }

  Future<void> stopMiracast() async {
    for (MirrorRequest request
        in HybridConnectionList().getMirrorMap().values) {
      if (request.mirrorType == MirrorType.miracast) {
        stopAcceptedMirror(request.mirrorId);
      }
    }
    await _flutterMirrorPlugin?.stopMiracast();
    _miracastEnabled = false;
    notifyListeners();
  }

  Future<void> pauseMirror() async {
    // printInDebug('pauseMirror', type: runtimeType);
    // mirrorTypeState[MirrorType.airplay] = _airplayEnabled;
    // mirrorTypeState[MirrorType.googlecast] = _googleCastEnabled;
    // mirrorTypeState[MirrorType.miracast] = _miracastEnabled;
    // stopAirPlay();
    // stopGoogleCast();
    // stopMiracast();
  }

  Future<void> resumeMirror() async {
    // printInDebug('resumeMirror', type: runtimeType);
    // if (mirrorTypeState[MirrorType.airplay]!) {
    //   startAirPlay();
    // }
    // if (mirrorTypeState[MirrorType.googlecast]!) {
    //   startGoogleCast();
    // }
    // if (mirrorTypeState[MirrorType.miracast]!) {
    //   startMiracast();
    // }
  }

  Future<void> _restartMirror() async {
    printInDebug('restartMirror', type: runtimeType);
    if (!HybridConnectionList().isMirroring()) {
      if (_airplayEnabled) {
        await stopAirPlay();
        await startAirPlay();
      }

      if (_googleCastEnabled) {
        await stopGoogleCast();
        await startGoogleCast();
      }

      if (_miracastEnabled) {
        await stopMiracast();
        await startMiracast();
      }
    }
  }

  // endregion

  // region Private method
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      _flutterMirrorPlugin?.registerListener(this);
      Map<String, int> options = DeviceFeatureAdapter.getQuickDecodeOptions();
      await _flutterMirrorPlugin?.initialize(FlutterMirrorConfig(options));
    } on PlatformException {
      printInDebug('Mirror initialize failure.', type: runtimeType);
    }
  }

  void _getWidgetInfo(GlobalKey mirrorViewKey) {
    final RenderBox renderBox =
        mirrorViewKey.currentContext?.findRenderObject() as RenderBox;
    _sizeChanged = false;

    _videoWidgetSize = renderBox.size;
    _videoWidgetOffset = renderBox.localToGlobal(Offset.zero);
  }
// endregion
}
