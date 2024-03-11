import 'dart:async';
import 'dart:math';

import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/screens/home.dart';
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
  MirrorState mirrorState = MirrorState.idle;

  MirrorRequest(
      this.mirrorId, this.textureId, this.deviceName, this.mirrorType);
}

class MirrorStateProvider extends ChangeNotifier
    implements FlutterMirrorListener {
  MirrorStateProvider() {
    _flutterMirrorPlugin = FlutterMirror();
    _initPlatformState();
  }

  get deviceName => _deviceName;

  get mirrorViewKey => _mirrorViewKey;

  get isMirroring => HybridConnectionList().isMirroring();

  get airplayEnabled => _airplayEnabled;

  get googleCastEnabled => _googleCastEnabled;

  get miracastEnabled => _miracastEnabled;

  // get mirrorRequestList => _mirrorRequestList;

  // get textureId => _acceptedTextureId;

  get pinCode => _pinCode;

  // get aspectRatio => _aspectRatio;

  get audioEnable => _audioEnabled;
  setAudioEnable() {
    _audioEnabled = !_audioEnabled;
  }

  get flutterMirrorPlugin => _flutterMirrorPlugin;

  FlutterMirror? _flutterMirrorPlugin;
  String _deviceName = '';
  final GlobalKey _mirrorViewKey = GlobalKey();
  bool _airplayEnabled = false;
  bool _googleCastEnabled = false;
  bool _miracastEnabled = false;
  String _pinCode = '';
  Timer? _pinTimer;
  bool _sizeChanged = false;
  Size _videoWidgetSize = const Size(0, 0);
  Offset _videoWidgetOffset = const Offset(0, 0);
  bool _audioEnabled = true;
  bool menuOff = false;
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

    HybridConnectionList().addConnection(
        MirrorRequest(mirrorId, textureId, deviceName, mirrorType));

    notifyListeners();
  }

  @override
  void onMirrorStop(String mirrorId) {
    printInDebug('onMirrorStop $mirrorId', type: runtimeType);
    bool needNotify = false;
    for (MirrorRequest mirrorRequest in HybridConnectionList().getMirrorMap().values) {
      if (mirrorRequest.mirrorId == mirrorId) {
        HybridConnectionList().removeConnection(mirrorRequest);
        needNotify = true;
      }
    }
    // print('_______onMirrorStop mirror map length = ${HybridConnectionList().getMirrorMap().length}');
    // if (needNotify) {
    //   notifyListeners();

      // if (_acceptedMirrorId != mirrorId) {
      //   // ignore the onMirrorStop that is not for the current mirror session
      //   return;
      // }
      // _acceptedMirrorId = null;
      // _acceptedTextureId = null;
      // _acceptedMirrorType = null;
      // _mirrorState = MirrorState.idle;
    Home.showTitleBottomBar.value = true;
    HybridConnectionList().updateSplitScreen();
    menuOff = false;
    notifyListeners();
  }

  @override
  void onMirrorVideoResize(String mirrorId, int width, int height) {
    printInDebug('onMirrorVideoResize', type: runtimeType);
    // if (_acceptedMirrorId == null || _acceptedMirrorId != mirrorId) {
    // for (MirrorRequest request in _mirrorRequestList) {
    //   if (request.mirrorId == mirrorId) {
    //     request.aspectRatio = width/height;
    //   }
    // }

    if (HybridConnectionList().getMirrorMap().isNotEmpty) {
      for (var entry in HybridConnectionList().getMirrorMap().entries) {
        if (entry.value.mirrorId == mirrorId) {
          MirrorRequest request = entry.value;
          request.aspectRatio = width / height;
          HybridConnectionList().getMirrorMap().update(entry.key, (value) => request);

          _sizeChanged = true;
          notifyListeners();
          break;
        }
      }
    }

      // ignore the onMirrorStop that is not for the current mirror session
    //   return;
    // }
    // _aspectRatio = width / height;
    // _sizeChanged = true;
    // notifyListeners();
  }

  // endregion

  // region Public method
  setDeviceName(String instanceName, String displayCode) {
    _deviceName =
        '$instanceName-${displayCode.substring(max(displayCode.length - 5, 0))}';
    notifyListeners();
  }

  clearPinCode() {
    _pinTimer?.cancel();
    _pinCode = '';
    notifyListeners();
  }

  clearRequestMirrorId(int index) {
    if (HybridConnectionList().getMirrorMap().length > index) {
      var mirrorMap = HybridConnectionList().getMirrorMap();
      MirrorRequest request = mirrorMap.values.toList()[index];
      for (var entry in mirrorMap.entries) {
        if (entry.value == request) {
          HybridConnectionList().removeConnection(request);
        }
      }
    }
    notifyListeners();
  }

  setAcceptMirrorId(int index) {
    print('setAcceptMirrorId');
    if (HybridConnectionList().getMirrorMap().isNotEmpty) {
      var mirrorMap = HybridConnectionList().getMirrorMap();
      var idleList = HybridConnectionList().getMirrorMap().values
          .where((request) => request.mirrorState == MirrorState.idle).toList();
      MirrorRequest request = idleList[index];
      for (var entry in mirrorMap.entries) {
        if (entry.value == request) {
          request.mirrorState = MirrorState.mirroring;
          mirrorMap.update(entry.key, (value) => request);
        }
      }
      if (request.mirrorId != null) {
        _flutterMirrorPlugin?.enableAudio(request.mirrorId!, _audioEnabled);
      }

      // _aspectRatio = _mirrorRequestList[index].aspectRatio;
      _sizeChanged = true;

      HybridConnectionList().updateSplitScreen();
      StreamFunction.streamFunctionState.value = stateMenuOff;
      menuOff = true;
      // hideTitleBar
      Home.showTitleBottomBar.value = false;
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

  updateAudioEnable(bool enable) {
    var mirrorMap = HybridConnectionList().getMirrorMap();
    for (MirrorRequest request in mirrorMap.values) {
      if (request.mirrorId != null) {
        _flutterMirrorPlugin?.enableAudio(
            request.mirrorId!, enable & _audioEnabled);
      }
    }
  }

  onTouchEvent(PointerEvent event, String? mirrorId) {
    if (mirrorId == null) {
      return;
    }

    if (_sizeChanged) {
      _getWidgetInfo();
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
      security: AirplaySecurity.onscreenCode,
    ));
    _airplayEnabled = true;
    notifyListeners();
  }

  Future<void> stopAirPlay() async {
    printInDebug('stopAirPlay', type: runtimeType);
    for (MirrorRequest request in HybridConnectionList().getMirrorMap().values) {
      if (request.mirrorId != null &&
          request.mirrorType == MirrorType.airplay) {
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
    for (MirrorRequest request in HybridConnectionList().getMirrorMap().values) {
      if (request.mirrorId != null &&
          request.mirrorType == MirrorType.googlecast) {
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
    for (MirrorRequest request in HybridConnectionList().getMirrorMap().values) {
      if (request.mirrorId != null &&
          request.mirrorType == MirrorType.miracast) {
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

  Future<void> restartMirror() async {
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
      await _flutterMirrorPlugin?.initialize();
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
