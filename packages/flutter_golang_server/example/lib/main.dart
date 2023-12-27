import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_ion_sfu/flutter_ion_sfu.dart';
import 'package:flutter_ion_sfu/flutter_ion_sfu_configuration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = '';

  final _flutterIonSfuPlugin = FlutterIonSfu();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    late String message;
    try {
      await _flutterIonSfuPlugin.initialize();
      final configuration = FlutterIonSfuConfiguration();
      await _flutterIonSfuPlugin.start(configuration);
      message = "Ion SFU Server has started";
    } on PlatformException catch (e) {
      message = "Ion SFU Server failed to start $e";
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _message = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text(_message),
        ),
      ),
    );
  }
}
