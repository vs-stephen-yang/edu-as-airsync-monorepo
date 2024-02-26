import 'dart:async';

import 'package:display_flutter/model/rtc_connector_list.dart';
import 'package:display_flutter/utility/print_in_debug.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mirror/airplay_config.dart';
import 'package:flutter_mirror/flutter_mirror.dart';
import 'package:flutter_mirror/flutter_mirror_listener.dart';
import 'package:flutter_mirror/googlecast_config.dart';
import 'package:flutter_mirror/mirror_type.dart';
import 'package:uuid/uuid.dart';

enum MirrorState {
  idle,
  mirroring,
}

class MirrorRequest {
  String? mirrorId;
  int textureId;
  String? deviceName;
  MirrorType? mirrorType;
  double aspectRatio = 3 / 2;

  MirrorRequest(
      this.mirrorId, this.textureId, this.deviceName, this.mirrorType);
}

class MirrorStateProvider extends ChangeNotifier
    implements FlutterMirrorListener {
  MirrorStateProvider() {
    _plugin = FlutterMirror();
    _initPlatformState();
  }

  get deviceName => _deviceName;

  get mirrorViewKey => _mirrorViewKey;

  get isMirroring => _mirrorState == MirrorState.mirroring;

  get airplayEnabled => _airplayEnabled;

  get googleCastEnabled => _googleCastEnabled;

  get miracastEnabled => _miracastEnabled;

  get requestingMirror => _requestingMirror;

  get textureId => _acceptedTextureId;

  get pinCode => _pinCode;

  get aspectRatio => _aspectRatio;

  get audioEnable => _audioEnabled;

  FlutterMirror? _plugin;
  String _deviceName = '';
  final GlobalKey _mirrorViewKey = GlobalKey();
  MirrorState _mirrorState = MirrorState.idle;
  bool _airplayEnabled = false;
  bool _googleCastEnabled = false;
  bool _miracastEnabled = false;
  final List<MirrorRequest> _requestingMirror = [];
  String? _acceptedMirrorId;
  int? _acceptedTextureId;
  MirrorType? _acceptedMirrorType;
  String _pinCode = '';
  Timer? _pinTimer;
  double _aspectRatio = 3 / 2;
  bool _sizeChanged = false;
  Size _videoWidgetSize = const Size(0, 0);
  Offset _videoWidgetOffset = const Offset(0, 0);
  bool _audioEnabled = true;
  Map<MirrorType, bool> mirrorTypeState = {
    MirrorType.airplay: false,
    MirrorType.googlecast: false,
    MirrorType.miracast: false,
  };

  // region FlutterMirrorListener
  @override
  void onMirrorAuth(String pin, int timeoutSec) {
    printInDebug('onMirrorAuth', type: runtimeType);
    _pinCode = pin;

    _pinTimer?.cancel();
    _pinTimer = Timer(Duration(seconds: timeoutSec), () {
      _pinCode = '';
      notifyListeners();
    });
    notifyListeners();
  }

  @override
  void onMirrorStart(String mirrorId, int textureId, String deviceName,
      MirrorType mirrorType) {
    printInDebug('onMirrorStart', type: runtimeType);
    _pinTimer?.cancel();
    _pinCode = '';

    _requestingMirror
        .addAll({MirrorRequest(mirrorId, textureId, deviceName, mirrorType)});

    notifyListeners();
  }

  @override
  void onMirrorStop(String mirrorId) {
    printInDebug('onMirrorStop $mirrorId', type: runtimeType);
    bool needNotify = false;
    _requestingMirror.removeWhere((element) {
      if (element.mirrorId == mirrorId) {
        needNotify = true;
        return true;
      } else {
        return false;
      }
    });
    if (needNotify) notifyListeners();

    if (_acceptedMirrorId != mirrorId) {
      // ignore the onMirrorStop that is not for the current mirror session
      return;
    }
    _acceptedMirrorId = null;
    _acceptedTextureId = null;
    _acceptedMirrorType = null;
    _mirrorState = MirrorState.idle;

    if (RtcConnectorList().isPresenting()) {
      StreamFunction.streamFunctionState.value = stateMenuOff;
    } else {
      StreamFunction.streamFunctionState.value = stateStandby;
    }
    notifyListeners();
  }

  @override
  void onMirrorVideoResize(String mirrorId, int width, int height) {
    printInDebug('onMirrorVideoResize', type: runtimeType);
    if (_acceptedMirrorId == null || _acceptedMirrorId != mirrorId) {
      for (int i = 0; i < _requestingMirror.length; i++) {
        if (_requestingMirror[i].mirrorId == mirrorId) {
          _requestingMirror[i].aspectRatio = width / height;
          break;
        }
      }
      // ignore the onMirrorStop that is not for the current mirror session
      return;
    }
    _aspectRatio = width / height;
    _sizeChanged = true;
    notifyListeners();
  }

  // endregion

  // region Public method
  setDeviceName(String deviceName) {
    _deviceName = deviceName;
  }

  clearPinCode() {
    _pinTimer?.cancel();
    _pinCode = '';
    notifyListeners();
  }

  clearRequestMirrorId(int index) {
    if (_requestingMirror.length > index) {
      _requestingMirror.removeAt(index);
    }
    notifyListeners();
  }

  setAcceptMirrorId(int index) {
    if (_requestingMirror.isNotEmpty) {
      if (_acceptedMirrorId != null) {
        _plugin?.stopMirror(_acceptedMirrorId!);
      }

      _acceptedMirrorId = _requestingMirror[index].mirrorId;
      _acceptedTextureId = _requestingMirror[index].textureId;
      _acceptedMirrorType = _requestingMirror[index].mirrorType;

      if (_acceptedMirrorId != null) {
        _plugin?.enableAudio(_acceptedMirrorId!, _audioEnabled);
      }

      _aspectRatio = _requestingMirror[index].aspectRatio;
      _sizeChanged = true;

      _requestingMirror.removeAt(index);
      _mirrorState = MirrorState.mirroring;
      StreamFunction.streamFunctionState.value = stateCast;
      notifyListeners();
    }
  }

  stopAcceptedMirror() {
    printInDebug('stopAcceptedMirror', type: runtimeType);
    if (_acceptedMirrorId != null) {
      _plugin?.stopMirror(_acceptedMirrorId!);
    }
    notifyListeners();
  }

  setAudioEnable(bool enable) {
    _audioEnabled = enable;
    if (_acceptedMirrorId != null) {
      _plugin?.enableAudio(_acceptedMirrorId!, enable);
    }
    notifyListeners();
  }

  updateAudioEnable(bool enable) {
    if (_acceptedMirrorId != null) {
      _plugin?.enableAudio(_acceptedMirrorId!, enable & _audioEnabled);
    }
  }

  onTouchEvent(PointerEvent event) {
    if (_acceptedMirrorId == null) {
      return;
    }

    if (_sizeChanged) {
      _getWidgetInfo();
    }

    _plugin?.onMirrorTouch(
        _acceptedMirrorId!,
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
    await _plugin?.startAirplay(AirplayConfig(
      name: _deviceName,
      security: AirplaySecurity.onscreenCode,
    ));
    _airplayEnabled = true;
    notifyListeners();
  }

  Future<void> stopAirPlay() async {
    printInDebug('stopAirPlay', type: runtimeType);
    if (_acceptedMirrorType == MirrorType.airplay) {
      stopAcceptedMirror();
    }
    await _plugin?.stopAirplay();
    _airplayEnabled = false;
    notifyListeners();
  }

  Future<void> startGoogleCast() async {
    await _plugin?.startGooglecast(GooglecastConfig(
      name: _deviceName,
      uniqueId: (const Uuid()).v4(),
    ));
    _googleCastEnabled = true;
    notifyListeners();
  }

  Future<void> stopGoogleCast() async {
    if (_acceptedMirrorType == MirrorType.googlecast) {
      stopAcceptedMirror();
    }
    await _plugin?.stopGooglecast();
    _googleCastEnabled = false;
    notifyListeners();
  }

  Future<void> startMiracast() async {
    await _plugin?.startMiracast(_deviceName);
    _miracastEnabled = true;
    notifyListeners();
  }

  Future<void> stopMiracast() async {
    if (_acceptedMirrorType == MirrorType.miracast) {
      stopAcceptedMirror();
    }
    await _plugin?.stopMiracast();
    _miracastEnabled = false;
    notifyListeners();
  }

  Future<void> pauseMirror() async {
    printInDebug('pauseMirror', type: runtimeType);
    mirrorTypeState[MirrorType.airplay] = _airplayEnabled;
    mirrorTypeState[MirrorType.googlecast] = _googleCastEnabled;
    mirrorTypeState[MirrorType.miracast] = _miracastEnabled;
    stopAirPlay();
    stopGoogleCast();
    stopMiracast();
  }

  Future<void> resumeMirror() async {
    printInDebug('resumeMirror', type: runtimeType);
    if (mirrorTypeState[MirrorType.airplay]!) {
      startAirPlay();
    }
    if (mirrorTypeState[MirrorType.googlecast]!) {
      startGoogleCast();
    }
    if (mirrorTypeState[MirrorType.miracast]!) {
      startMiracast();
    }
  }

  Future<void> restartMirror() async {
    printInDebug('restartMirror', type: runtimeType);
    if (_mirrorState == MirrorState.idle) {
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
      _plugin?.registerListener(this);
      await _plugin?.initialize();
    } on PlatformException {
      printInDebug('Mirror initialize failure.', type: runtimeType);
    }
  }

  void _getWidgetInfo() {
    final RenderBox renderBox =
        mirrorViewKey.currentContext?.findRenderObject() as RenderBox;
    _sizeChanged = false;

    _videoWidgetSize = renderBox.size;
    _videoWidgetOffset = renderBox.localToGlobal(Offset.zero);
  }
  // endregion
}
