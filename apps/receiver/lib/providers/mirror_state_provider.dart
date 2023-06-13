import 'dart:async';
import 'dart:math';

import 'package:display_flutter/utility/print_in_debug.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mirror/airplay_config.dart';
import 'package:flutter_mirror/flutter_mirror.dart';
import 'package:flutter_mirror/flutter_mirror_listener.dart';
import 'package:flutter_mirror/mirror_type.dart';

enum MirrorState {
  idle,
  showPinCode,
  mirroring,
}

class MirrorStateProvider extends ChangeNotifier
    implements FlutterMirrorListener {
  MirrorStateProvider() {
    _plugin = FlutterMirror();
    _initPlatformState();
  }

  get deviceName => _deviceName;

  get mirrorViewKey => _mirrorViewKey;

  get state => _currentState;

  get airplayEnabled => _airplayEnabled;

  get googleCastEnabled => _googleCastEnabled;

  get miracastEnabled => _miracastEnabled;

  get textureId => _textureId;

  get pinCode => _pinCode;

  get aspectRatio => _aspectRatio;

  FlutterMirror? _plugin;
  String _deviceName =
      'Display-${Random().nextInt(9999).toString().padLeft(4, '0')}';
  final GlobalKey _mirrorViewKey = GlobalKey();
  MirrorState _currentState = MirrorState.idle;
  bool _airplayEnabled = false;
  bool _googleCastEnabled = false;
  bool _miracastEnabled = false;
  String? _mirrorId;
  int? _textureId;
  String _pinCode = "";
  Timer? _pinTimer;
  double _aspectRatio = 3 / 2;
  bool _sizeChanged = false;
  Size _videoWidgetSize = const Size(0, 0);
  final Offset _videoWidgetOffset = const Offset(0, 0);

  // region FlutterMirrorListener
  @override
  void onMirrorAuth(String pin, int timeoutSec) {
    _pinCode = pin;
    _setMirrorState(MirrorState.showPinCode);

    _pinTimer?.cancel();
    _pinTimer = Timer(Duration(seconds: timeoutSec), () {
      _pinCode = "";
      _setMirrorState(MirrorState.idle);
    });
  }

  @override
  void onMirrorStart(String mirrorId, int textureId, String deviceName,
      MirrorType mirrorType) {
    _pinTimer?.cancel();
    _pinCode = "";

    if (_mirrorId != null) {
      _plugin?.stopMirror(_mirrorId!);
    }

    _mirrorId = mirrorId;
    _textureId = textureId;

    _plugin?.enableAudio(mirrorId, true);

    _setMirrorState(MirrorState.mirroring);
  }

  @override
  void onMirrorStop(String mirrorId) {
    _plugin?.stopMirror(mirrorId);

    _mirrorId = null;
    _textureId = null;
    _setMirrorState(MirrorState.idle);
  }

  @override
  void onMirrorVideoResize(String mirrorId, int width, int height) {
    _aspectRatio = width / height;
    _sizeChanged = true;
    notifyListeners();
  }

  // endregion

  // region Public method
  setDeviceName(String deviceName) {
    _deviceName = deviceName;
  }

  onTouchEvent(PointerEvent event) {
    if (_mirrorId == null) {
      return;
    }

    if (_sizeChanged) {
      _getWidgetInfo();
    }

    _plugin?.onMirrorTouch(
        _mirrorId!,
        event.pointer,
        event.down,
        ((event.position.dx.toInt() - _videoWidgetOffset.dx.toInt()) /
            _videoWidgetSize.width.toInt()),
        ((event.position.dy.toInt() - _videoWidgetOffset.dy.toInt()) /
            _videoWidgetSize.height.toInt()));
  }

  Future<void> startAirPlay() async {
    await _plugin?.startAirplay(AirplayConfig(
      name: _deviceName,
      security: AirplaySecurity.onscreenCode,
    ));
    _airplayEnabled = true;
    notifyListeners();
  }

  Future<void> stopAirPlay() async {
    await _plugin?.stopAirplay();
    _airplayEnabled = false;
    notifyListeners();
  }

  Future<void> startGoogleCast() async {
    await _plugin?.startGooglecast(_deviceName);
    _googleCastEnabled = true;
    notifyListeners();
  }

  Future<void> stopGoogleCast() async {
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
    await _plugin?.stopMiracast();
    _miracastEnabled = false;
    notifyListeners();
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
      printInDebug('Mirror initialize failure.');
    }
  }

  _setMirrorState(MirrorState mirrorState) {
    _currentState = mirrorState;
    notifyListeners();
  }

  void _getWidgetInfo() {
    final RenderBox renderBox =
        mirrorViewKey.currentContext?.findRenderObject() as RenderBox;
    //stickyKey.currentContext?.size;
    _sizeChanged = false;

    _videoWidgetSize = renderBox.size;
  }
// endregion
}
