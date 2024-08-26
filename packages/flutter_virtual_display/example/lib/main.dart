import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_virtual_display/flutter_virtual_display.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterVirtualDisplay.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isVirtualDisplayStarted = false;

  @override
  void initState() {
    super.initState();

    FlutterVirtualDisplay.instance.onVirtualDisplayStarted.stream.listen((_) {
      setState(() {
        _isVirtualDisplayStarted = true;
      });
    });

    FlutterVirtualDisplay.instance.onVirtualDisplayStopped.stream.listen((_) {
      setState(() {
        _isVirtualDisplayStarted = false;
      });
    });
  }

  void _startVirtualDisplay() async {
    await FlutterVirtualDisplay.instance.startVirtualDisplay();
  }

  void _stopVirtualDisplay() async {
    await FlutterVirtualDisplay.instance.stopVirtualDisplay();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                  onPressed: _isVirtualDisplayStarted ?
                    _stopVirtualDisplay : _startVirtualDisplay,
                  child: _isVirtualDisplayStarted ?
                    const Text('Stop Virtual Display') : const Text('Start Virtual Display'))
            ],
          )
        ),
      ),
    );
  }
}
