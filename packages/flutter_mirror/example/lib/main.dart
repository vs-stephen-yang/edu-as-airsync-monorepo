import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_mirror/bluetooth_touchback_listener.dart';
import 'package:flutter_mirror/bluetooth_touchback_status.dart';
import 'package:flutter_mirror/flutter_mirror.dart';
import 'package:flutter_mirror/flutter_mirror_config.dart';
import 'package:flutter_mirror/flutter_mirror_listener.dart';
import 'package:flutter_mirror/airplay_config.dart';
import 'package:flutter_mirror/googlecast_config.dart';
import 'package:flutter_mirror/mirror_type.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _Mirror {
  String mirrorId;
  int textureId;
  bool audioEnabled = false;
  MirrorType mirrorType = MirrorType.airplay;
  bool touchbackEnabled = false;

  double aspectRatio = 3 / 2;
  bool sizeChanged = false;

  Size videoWidgetSize = const Size(0, 0);
  Offset videoWidgetOffset = const Offset(0, 0);

  GlobalKey stickyKey = GlobalKey();

  _Mirror(this.mirrorId, this.textureId);

  void updateSize(int width, int height) {
    aspectRatio = width / height;
    sizeChanged = true;
  }
}

class _MyAppState extends State<MyApp>
    implements FlutterMirrorListener, BluetoothTouchbackListener {
  final _mirrors = <String, _Mirror>{};

  String _pin = "";
  bool _pinVisibility = false;
  Timer? _pinTimer;

  final _plugin = FlutterMirror();

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
      _plugin.registerBluetoothTouchBackListener(this);
      await _plugin.initialize(const FlutterMirrorConfig({
        "VideoPath": 1024 // 52-1C for testing
      }));

      await startServices();
    } on PlatformException {
      //
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  @override
  void onMirrorError(String mirrorType, String errorMessage) {
    print('Mirror error: $mirrorType $errorMessage');
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
    String deviceModel,
  ) {
    print('A new mirror has started. $mirrorType $deviceName');

    _pinTimer?.cancel();
    _pin = "";
    _pinVisibility = false;

    final mirror = _Mirror(
      mirrorId,
      textureId,
    );
    mirror.mirrorType = mirrorType;
    _mirrors[mirrorId] = mirror;

    // enable audio
    _plugin.enableAudio(mirrorId, true);
    mirror.audioEnabled = true;

    if (!mounted) return;

    setState(() {});
  }

  @override
  void onMirrorStop(String mirrorId) {
    _plugin.stopMirror(mirrorId);

    _mirrors.remove(mirrorId);
    setState(() {});
  }

  @override
  void onMirrorVideoResize(String mirrorId, int width, int height) {
    if (!mounted) return;

    final mirror = _mirrors[mirrorId];

    mirror?.updateSize(width, height);

    setState(() {});
  }

  @override
  void onMirrorVideoFrameRate(String mirrorId, int fps) {
    print('Video frame rate: $fps');
  }

  @override
  void onBluetoothTouchbackStatusChanged(BluetoothTouchbackStatus status) {
    print('Bluetooth touchback status: $status');
    Fluttertoast.showToast(
        msg: 'Bluetooth touchback status: $status',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _getWidgetInfo(_Mirror mirror) {
    final RenderBox renderBox =
        mirror.stickyKey.currentContext?.findRenderObject() as RenderBox;
    //stickyKey.currentContext?.size;

    mirror.videoWidgetSize = renderBox.size;
    // print(
    //     'Video widget size: ${mirror.videoWidgetSize.width}, ${mirror.videoWidgetSize.height}');

    mirror.videoWidgetOffset = renderBox.localToGlobal(Offset.zero);
    // print(
    //     'Video widget fffset: ${mirror.videoWidgetOffset.dx}, ${mirror.videoWidgetOffset.dy}');
  }

  void _onTouchEvent(_Mirror mirror, PointerEvent event) {
    //if (mirror.sizeChanged) {
    _getWidgetInfo(mirror);
    //mirror.sizeChanged = false;
    //}

    _plugin.onMirrorTouch(
        mirror.mirrorId,
        event.pointer,
        event.down,
        ((event.position.dx.toInt() - mirror.videoWidgetOffset.dx.toInt()) /
            mirror.videoWidgetSize.width.toInt()),
        ((event.position.dy.toInt() - mirror.videoWidgetOffset.dy.toInt()) /
            mirror.videoWidgetSize.height.toInt()));
  }

  Future<void> startServices() async {
    // start airplay
    await _plugin.startAirplay(const AirplayConfig(
      name: "display-1",
      security: AirplaySecurity.none,
    ));

    // start googlecast
    await _plugin.startGooglecast(const GooglecastConfig(
      name: "display-1",
      uniqueId: "123",
    ));

    // start miracast
    await _plugin.startMiracast("display-1");
  }

  Future<void> stopServices() async {
    await _plugin.stopAirplay();
    await _plugin.stopGooglecast();
    await _plugin.stopMiracast();
  }

  void toggleAudio(_Mirror mirror) {
    mirror.audioEnabled = !mirror.audioEnabled;
    _plugin.enableAudio(mirror.mirrorId, mirror.audioEnabled);
  }

  Future<void> toggleTouchback(_Mirror mirror) async {
    bool newTouchBackState = !mirror.touchbackEnabled;
    bool success =
        await _plugin.enableTouchback(mirror.mirrorId, newTouchBackState);
    if (success) {
      setState(() {
        mirror.touchbackEnabled = newTouchBackState;
      });
    } else {
      Fluttertoast.showToast(
          msg: 'Failed to toggle touchback',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void stopMirror(_Mirror mirror) {
    _mirrors.remove(mirror.mirrorId);

    _plugin.stopMirror(mirror.mirrorId);

    setState(() {});
  }

  Widget buildVideoWidget(_Mirror mirror) {
    print('textureId, ${mirror.textureId}');

    final closeButton = ElevatedButton(
      onPressed: () {
        stopMirror(mirror);
      },
      child: const Text("Close"),
    );

    final toggleEnableTouchback = ElevatedButton(
        onPressed: () async {
          toggleTouchback(mirror);
        },
        child: Text(mirror.touchbackEnabled
            ? "Disable Touchback"
            : "Enable Touchback"));

    final toggleAudioButton = ElevatedButton(
      onPressed: () {
        toggleAudio(mirror);
      },
      child: const Text("Mute"),
    );

    final buttons = Align(
      alignment: Alignment.topRight,
      child: Row(
        children: [
          closeButton,
          toggleAudioButton,
          if (mirror.mirrorType == MirrorType.airplay) toggleEnableTouchback
        ],
      ),
    );

    final video = Listener(
      onPointerDown: (PointerEvent event) {
        _onTouchEvent(mirror, event);
      },
      onPointerMove: (PointerEvent event) {
        _onTouchEvent(mirror, event);
      },
      onPointerUp: (PointerEvent event) {
        _onTouchEvent(mirror, event);
      },
      child: AspectRatio(
        key: mirror.stickyKey,
        aspectRatio: mirror.aspectRatio,
        child: Texture(textureId: mirror.textureId),
      ),
    );

    return Stack(
      children: [
        Container(
          color: Colors.black87,
          child: Center(child: video),
        ),
        buttons,
      ],
    );
  }

  Widget buildPinWidget() {
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
    return pin;
  }

  Widget buildActionButton() {
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

    var buttons = Container(
      padding: const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          startButton,
          stopButton,
        ],
      ),
    );

    return buttons;
  }

  Widget buildVideoWidgets() {
    if (_mirrors.isEmpty) {
      return Container(color: Colors.grey);
    }

    if (_mirrors.length == 1) {
      final mirror = _mirrors.entries.first.value;
      return buildVideoWidget(mirror);
    }

    final videos = <Widget>[
      Container(color: Colors.blue),
      Container(color: Colors.blue),
      Container(color: Colors.blue),
      Container(color: Colors.blue),
    ];

    var index = 0;
    for (var mirror in _mirrors.values) {
      videos[index] = buildVideoWidget(mirror);
      index += 1;
    }

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Row(children: [
            Expanded(flex: 1, child: videos[0]),
            Expanded(flex: 1, child: videos[1]),
          ]),
        ),
        Expanded(
          flex: 1,
          child: Row(children: [
            Expanded(flex: 1, child: videos[2]),
            Expanded(flex: 1, child: videos[3]),
          ]),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget videos = buildVideoWidgets();

    final buttons = buildActionButton();
    final pin = buildPinWidget();

    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            videos,
            pin,
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: buttons,
      ),
    );
  }
}
