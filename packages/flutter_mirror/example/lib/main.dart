import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_mirror/flutter_mirror.dart';
import 'package:flutter_mirror/flutter_mirror_listener.dart';
import 'package:flutter_mirror/airplay_config.dart';
import 'package:flutter_mirror/mirror_type.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements FlutterMirrorListener {
  String? _mirrorId;
  int? _textureId;

  bool _audioEnabled = false;

  double _aspectRatio = 3 / 2;
  bool _sizeChanged = false;
  Size _videoWidgetSize = Size(0, 0);
  Offset _videoWidgetOffset = Offset(0, 0);

  String _pin = "";
  bool _pinVisibility = false;
  Timer? _pinTimer;

  final _plugin = FlutterMirror();

  GlobalKey stickyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.

    try {
      _plugin.registerListener(this);
      await _plugin.initialize();

      await startServices();
    } on PlatformException {}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  @override
  void onMirrorAuth(String pin, int timeoutSec) {
    setState(() {
      _pin = pin;
      _pinVisibility = true;
    });

    _pinTimer?.cancel();
    _pinTimer = Timer(Duration(seconds: timeoutSec), () {
      setState(() {
        _pin = "";
        _pinVisibility = false;
      });
    });
  }

  @override
  void onMirrorStart(
    String mirrorId,
    int textureId,
    String deviceName,
    MirrorType mirrorType,
  ) {
    print('Mirror type: $mirrorType');

    _pinTimer?.cancel();
    _pin = "";
    _pinVisibility = false;
    _audioEnabled = false;

    if (_mirrorId != null) {
      _plugin.stopMirror(_mirrorId!);
    }

    // enable audio
    _plugin.enableAudio(mirrorId, true);
    _audioEnabled = true;

    if (!mounted) return;

    setState(() {
      _mirrorId = mirrorId;
      _textureId = textureId;
    });
  }

  @override
  void onMirrorStop(String mirrorId) {
    _plugin.stopMirror(mirrorId);

    setState(() {
      _mirrorId = null;
      _textureId = null;
    });
  }

  @override
  void onMirrorVideoResize(String mirrorId, int width, int height) {
    if (!mounted) return;

    setState(() {
      setState(() {
        _aspectRatio = width / height;
        _sizeChanged = true;
      });
    });
  }

  void _getWidgetInfo(_) {
    final RenderBox renderBox =
        stickyKey.currentContext?.findRenderObject() as RenderBox;
    //stickyKey.currentContext?.size;
    _sizeChanged = false;

    _videoWidgetSize = renderBox.size;
    print(
        'Video widget size: ${_videoWidgetSize.width}, ${_videoWidgetSize.height}');

    _videoWidgetOffset = renderBox.localToGlobal(Offset.zero);
    print(
        'Video widget fffset: ${_videoWidgetOffset.dx}, ${_videoWidgetOffset.dy}');
  }

  void _onTouchEvent(PointerEvent event) {
    if (_mirrorId == null) {
      return;
    }
    if (_sizeChanged) {
      _getWidgetInfo(null);
    }

    _plugin.onMirrorTouch(
        _mirrorId!,
        event.pointer,
        event.down,
        ((event.position.dx.toInt() - _videoWidgetOffset.dx.toInt()) /
            _videoWidgetSize.width.toInt()),
        ((event.position.dy.toInt() - _videoWidgetOffset.dy.toInt()) /
            _videoWidgetSize.height.toInt()));
  }

  Future<void> startServices() async {
    // start airplay
    await _plugin.startAirplay(const AirplayConfig(
      name: "display-1",
      security: AirplaySecurity.onscreenCode,
    ));

    // start googlecast
    await _plugin.startGooglecast("display-1");

    // start miracast
    await _plugin.startMiracast("display-1");
  }

  Future<void> stopServices() async {
    await _plugin.stopAirplay();
    await _plugin.stopGooglecast();
    await _plugin.stopMiracast();
  }

  void toggleAudio() {
    if (_mirrorId == null) {
      return;
    }
    _audioEnabled = !_audioEnabled;
    _plugin.enableAudio(_mirrorId!, _audioEnabled);
  }

  void stopMirror() {
    if (_mirrorId == null) {
      return;
    }

    _plugin.stopMirror(_mirrorId!);

    setState(() {
      _mirrorId = null;
      _textureId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    var video = AspectRatio(
      key: stickyKey,
      aspectRatio: _aspectRatio,
      child: _textureId != null
          ? Texture(textureId: _textureId!)
          : const Text('video'),
    );

    var videos = Container(
      color: Colors.black,
      child: Row(children: <Widget>[
        Expanded(
          child: Center(
            child: Listener(
                onPointerDown: _onTouchEvent,
                onPointerMove: _onTouchEvent,
                onPointerUp: _onTouchEvent,
                child: video),
          ),
        ),
      ]),
    );

    var pin = Center(
        child: Visibility(
            visible: _pinVisibility,
            child: Container(
                color: Colors.white,
                width: 100,
                height: 100,
                child: Center(
                    child: Text(
                  _pin,
                  style: const TextStyle(fontSize: 25),
                )))));

    var closeButton = FloatingActionButton.extended(
      onPressed: () {
        stopMirror();
      },
      label: const Text('close'),
      icon: const Icon(Icons.close),
      backgroundColor: Colors.pink,
    );

    var startButton = FloatingActionButton.extended(
      onPressed: () {
        startServices();
      },
      label: const Text('start'),
      icon: const Icon(Icons.start),
      backgroundColor: Colors.green,
    );

    var stopButton = FloatingActionButton.extended(
      onPressed: () {
        stopServices();
      },
      label: const Text('stop'),
      icon: const Icon(Icons.stop),
      backgroundColor: Colors.green,
    );

    var toggleAudioButton = FloatingActionButton.extended(
      onPressed: () {
        toggleAudio();
      },
      label: const Text('audio'),
      icon: const Icon(Icons.music_note),
      backgroundColor: Colors.lightBlue,
    );

    var buttons = Container(
      padding: const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          toggleAudioButton,
          closeButton,
          startButton,
          stopButton,
        ],
      ),
    );

    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[videos, pin],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: buttons,
      ),
    );
  }
}
