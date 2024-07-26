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

class KeyEvent {
  final int usbKeyCode;
  final bool pressed;
  final int delayMs;

  KeyEvent(
    this.usbKeyCode,
    this.pressed,
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
  final _focusNode = FocusNode();
  final _controller = TextEditingController();

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

  List<KeyEvent> generateKeyEvents() {
    final keyEvents = <KeyEvent>[];

    const delayMs = 20;
    // type 'a' - 'z'
    for (var i = 0; i < 26; i += 1) {
      keyEvents.add(KeyEvent(0x070004 + i, true, delayMs));
      keyEvents.add(KeyEvent(0x070004 + i, false, delayMs));
    }

    // type '1' - '9', '0'
    for (var i = 0; i < 10; i += 1) {
      keyEvents.add(KeyEvent(0x07001e + i, true, delayMs));
      keyEvents.add(KeyEvent(0x07001e + i, false, delayMs));
    }

    for (var i = 0; i < 13; i += 1) {
      keyEvents.add(KeyEvent(0x07002c + i, true, delayMs));
      keyEvents.add(KeyEvent(0x07002c + i, false, delayMs));
    }

    // keypad /
    keyEvents.add(KeyEvent(0x070054, true, delayMs));
    keyEvents.add(KeyEvent(0x070054, false, delayMs));
    // keypad *
    keyEvents.add(KeyEvent(0x070055, true, delayMs));
    keyEvents.add(KeyEvent(0x070055, false, delayMs));

    // Keypad Numlock
    keyEvents.add(KeyEvent(0x070053, true, delayMs));
    keyEvents.add(KeyEvent(0x070053, false, delayMs));

    // type keypad '1' - '9', '0'
    for (var i = 0; i < 10; i += 1) {
      keyEvents.add(KeyEvent(0x070059 + i, true, delayMs));
      keyEvents.add(KeyEvent(0x070059 + i, false, delayMs));
    }

    // type 'A' - 'Z'
    keyEvents.add(KeyEvent(0x0700e1, true, 10));
    for (var i = 0; i < 26; i += 1) {
      keyEvents.add(KeyEvent(0x070004 + i, true, delayMs));
      keyEvents.add(KeyEvent(0x070004 + i, false, delayMs));
    }
    keyEvents.add(KeyEvent(0x0700e1, false, 10));

    // type 'a' - 'z'
    for (var i = 0; i < 26; i += 1) {
      keyEvents.add(KeyEvent(0x070004 + i, true, delayMs));
      keyEvents.add(KeyEvent(0x070004 + i, false, delayMs));
    }

    // delete
    for (var i = 0; i < 26; i += 1) {
      keyEvents.add(KeyEvent(0x07002a, true, delayMs));
      keyEvents.add(KeyEvent(0x07002a, false, delayMs));
    }

    return keyEvents;
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

  Future<void> testKey() async {
    final keyEvents = generateKeyEvents();

    // replay the key events
    for (var keyEvent in keyEvents) {
      await _flutterInputInjectionPlugin.sendKey(
        keyEvent.usbKeyCode,
        keyEvent.pressed,
      );

      await Future.delayed(
        Duration(milliseconds: keyEvent.delayMs),
      );
    }
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
              Text('Running on: $_platformVersion\n'),
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
              ElevatedButton(
                onPressed: () {
                  _controller.clear();

                  // move focus to the text field
                  FocusScope.of(context).requestFocus(_focusNode);

                  testKey();
                },
                child: const Text('Test Key'),
              ),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.none,
                decoration: const InputDecoration(
                  labelText: '',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
