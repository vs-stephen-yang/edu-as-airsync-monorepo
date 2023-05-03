import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_input_injection/flutter_input_injection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterInputInjectionPlugin = FlutterInputInjection();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _flutterInputInjectionPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> testTouchInject() async {
    await Future.delayed(Duration(seconds: 5));

    int x = 200, y = 200;

    int id = 9;
    for (int j = 0; j < 3; ++j) {
      await _flutterInputInjectionPlugin.sendTouch(FlutterInputInjection.TOUCH_POINT_START, id, x, y);
      for (int i = 0; i < 50; ++i) {
        await _flutterInputInjectionPlugin.sendTouch(FlutterInputInjection.TOUCH_POINT_MOVE, id, x, y);
        y += 10;
        await Future.delayed(Duration(milliseconds: 10));
      }
      await _flutterInputInjectionPlugin.sendTouch(FlutterInputInjection.TOUCH_POINT_END, id, x, y);

      x += 50;
      await _flutterInputInjectionPlugin.sendTouch(FlutterInputInjection.TOUCH_POINT_START, id, x, y);
      for (int i = 0; i < 50; ++i) {
        await _flutterInputInjectionPlugin.sendTouch(FlutterInputInjection.TOUCH_POINT_MOVE, id, x, y);
        y -= 10;
        await Future.delayed(Duration(milliseconds: 10));
      }
      await _flutterInputInjectionPlugin.sendTouch(FlutterInputInjection.TOUCH_POINT_END, id, x, y);

      x += 50;
      id += 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Input injection plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: testTouchInject,
          tooltip: 'Test',
          child: const Icon(Icons.play_arrow),
        )
      ),
    );
  }
}
