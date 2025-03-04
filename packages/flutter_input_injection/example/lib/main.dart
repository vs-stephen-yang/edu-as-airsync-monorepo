import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_input_injection/flutter_input_injection.dart';
import 'package:flutter_input_injection/flutter_input_injection_platform_interface.dart';

import 'package:scribble/scribble.dart' as scribble;

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
  final _notifier = scribble.ScribbleNotifier();

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
    _flutterInputInjectionPlugin.initialize(
      inputInjectionMethod: InputInjectionMethod.accessibilityService,
      //inputInjectionMethod: InputInjectionMethod.uinput,
    );

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
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

  List<TouchEvent> generateSingleTouchEvents(Size screenSize) {
    final List<TouchEvent> touchEvents = [];

    const int padding = 200;
    const int lineLength = 400;
    const int moveStep = 20;

    int id = 9;

    // Define the four corners
    final List<Point<int>> corners = [
      const Point(padding, padding),
      Point(padding, (screenSize.height - padding - lineLength).toInt()),
      Point((screenSize.width - padding).toInt(), padding),
      Point((screenSize.width - padding).toInt(),
          (screenSize.height - padding - lineLength).toInt()),
    ];

    for (final corner in corners) {
      _simulateTouchPath(touchEvents, id, corner, moveStep, lineLength);
      id++; // Increment touch ID for next stroke
    }

    return touchEvents;
  }

  /// Simulates a touch moving in a straight line downwards
  void _simulateTouchPath(
    List<TouchEvent> touchEvents,
    int id,
    Point<int> start,
    int moveStep,
    int lineLength,
  ) {
    int x = start.x;
    int y = start.y;

    // Start touch event
    touchEvents.add(
      TouchEvent(id, FlutterInputInjection.TOUCH_POINT_START, x, y, 0),
    );

    // Move touch in a straight line
    for (int move = 0; move < lineLength; move += moveStep) {
      y += moveStep;
      touchEvents.add(
        TouchEvent(id, FlutterInputInjection.TOUCH_POINT_MOVE, x, y, 5),
      );
    }

    // End touch event
    touchEvents.add(
      TouchEvent(id, FlutterInputInjection.TOUCH_POINT_END, x, y, 0),
    );
  }

  Future<void> testSingleTouch(Size screenSize) async {
    final touchEvents = generateSingleTouchEvents(screenSize);

    await Future.delayed(const Duration(seconds: 1));

    for (var touchEvent in touchEvents) {
      await _flutterInputInjectionPlugin.sendTouch(
          touchEvent.action, touchEvent.id, touchEvent.x, touchEvent.y);

      await Future.delayed(
        Duration(milliseconds: touchEvent.delayMs),
      );
    }
  }

  List<TouchEvent> generateMultiTouchEvents() {
    final List<TouchEvent> touchEvents = [];

    const int padding = 200;
    const int lineLength = 400;
    const int moveStep = 20;

    int id = 9;

    const start = Point(padding, padding);

    _simulateTouchPath(touchEvents, id, start, moveStep, lineLength);

    return touchEvents;
  }

  Future<void> testMultiTouch(Size screenSize) async {
    final touchEvents = generateMultiTouchEvents();

    await Future.delayed(const Duration(seconds: 1));

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

  Widget createButtons(Size screenSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Scree size ${screenSize.width}x${screenSize.height}\n'),
        ElevatedButton(
          onPressed: () {
            _notifier.clear();
            testSingleTouch(screenSize);
          },
          child: const Text('Test Single Touch'),
        ),
        const SizedBox(height: 20), // Adding some space between buttons
        ElevatedButton(
          onPressed: () {
            _notifier.clear();
            testMultiTouch(screenSize);
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
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size * mediaQuery.devicePixelRatio;

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Stack(
            children: <Widget>[
              scribble.Scribble(
                notifier: _notifier,
              ),
              createButtons(screenSize),
            ],
          ),
        ),
      ),
    );
  }
}
