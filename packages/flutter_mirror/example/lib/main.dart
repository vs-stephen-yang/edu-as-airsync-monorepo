import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_mirror/flutter_mirror.dart';
import 'package:flutter_mirror/flutter_mirror_listener.dart';

import 'credential_store.dart';

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

  double _aspectRatio = 3 / 2;

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
      await _plugin.initialize();

      // start airplay
      await _plugin.startAirplay("display-1");

      // load today's credentials
      final credentials = await CredentialsStore.loadToday();

      // start googlecast
      await _plugin.startGooglecast("display-1", credentials);
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
  void onMirrorStart(String mirrorId, int textureId) {
    _pinTimer?.cancel();
    _pin = "";
    _pinVisibility = false;

    if (_mirrorId != null) {
      _plugin.stopMirror(_mirrorId!);
    }
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
      });
    });
  }

  @override
  void onCredentialsUpdate(int year, int month, int day) {
    if (!mounted) return;
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
      aspectRatio: _aspectRatio,
      child: _textureId != null
          ? Texture(textureId: _textureId!)
          : const Text('video'),
    );

    var videos = Container(
      color: Colors.black,
      child: Row(children: <Widget>[Expanded(child: Center(child: video))]),
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

    return MaterialApp(
        home: Scaffold(
      body: Stack(
        children: <Widget>[videos, pin],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          stopMirror();
        },
        label: const Text('Close'),
        icon: const Icon(Icons.close),
        backgroundColor: Colors.pink,
      ),
    ));
  }
}
