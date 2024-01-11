import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_input_injection/flutter_input_injection.dart';

void main() {
  runApp(const MyApp());
}

class TouchEvent {
  final int id;
  final int action;
  final int x;
  final int y;
  final int delayMs;

  TouchEvent(
    this.id,
    this.action,
    this.x,
    this.y,
    this.delayMs,
  );
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
          await _flutterInputInjectionPlugin.getPlatformVersion() ??
              'Unknown platform version';
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

  List<TouchEvent> generateTouchEvents() {
    final List<TouchEvent> touchEvents = [];

    int x = 200, y = 200;
    int id = 9;
    for (int j = 0; j < 3; ++j) {
      touchEvents.add(
        TouchEvent(id, FlutterInputInjection.TOUCH_POINT_START, x, y, 0),
      );
      for (int i = 0; i < 50; ++i) {
        touchEvents.add(
          TouchEvent(id, FlutterInputInjection.TOUCH_POINT_MOVE, x, y, 10),
        );
        y += 10;
      }
      touchEvents.add(
        TouchEvent(id, FlutterInputInjection.TOUCH_POINT_END, x, y, 0),
      );

      x += 50;
      touchEvents.add(
        TouchEvent(id, FlutterInputInjection.TOUCH_POINT_START, x, y, 0),
      );
      for (int i = 0; i < 50; ++i) {
        touchEvents.add(
          TouchEvent(id, FlutterInputInjection.TOUCH_POINT_MOVE, x, y, 10),
        );
        y -= 10;
      }
      touchEvents.add(
        TouchEvent(id, FlutterInputInjection.TOUCH_POINT_END, x, y, 0),
      );

      x += 50;
      id += 1;
    }
    return touchEvents;
  }

  Future<void> testSingleTouch() async {
    final touchEvents = generateTouchEvents();

    await Future.delayed(const Duration(seconds: 10));

    for (var touchEvent in touchEvents) {
      await _flutterInputInjectionPlugin.sendTouch(
          touchEvent.action, touchEvent.id, touchEvent.x, touchEvent.y);

      await Future.delayed(
        Duration(milliseconds: touchEvent.delayMs),
      );
    }
  }

  Future<void> testMultiTouch() async {
    final touchEvents = generateTouchEvents();

    await Future.delayed(const Duration(seconds: 10));

    for (var touchEvent in touchEvents) {
      // first touch
      await _flutterInputInjectionPlugin.sendTouch(
        touchEvent.action,
        touchEvent.id,
        touchEvent.x,
        touchEvent.y,
      );

      // second touch
      await _flutterInputInjectionPlugin.sendTouch(
        touchEvent.action,
        touchEvent.id + 100,
        touchEvent.x + 500,
        touchEvent.y,
      );

      await Future.delayed(
        Duration(milliseconds: touchEvent.delayMs),
      );
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  testSingleTouch();
                },
                child: const Text('Test Single Touch'),
              ),
              const SizedBox(height: 20), // Adding some space between buttons
              ElevatedButton(
                onPressed: () {
                  testMultiTouch();
                },
                child: const Text('Test MultiTouch'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
