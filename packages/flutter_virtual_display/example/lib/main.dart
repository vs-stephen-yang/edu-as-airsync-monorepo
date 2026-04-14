import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_virtual_display/flutter_virtual_display.dart';
import 'package:screen_retriever/screen_retriever.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterVirtualDisplay.instance.onVirtualDisplayError.stream.listen((msg) {
    // get 'errorMessage' from msg
    var dict = msg as Map<dynamic, dynamic>;
    print('Error: ${dict['errorMessage']}');
  });

  bool? isSupported = await FlutterVirtualDisplay.instance.isSupported();
  await FlutterVirtualDisplay.instance.initialize();

  print('Virtual Display is supported: $isSupported');
  runApp(MyApp(enableVirtualDisplayButton: isSupported!));
}

class MyApp extends StatefulWidget {
  final bool enableVirtualDisplayButton;

  const MyApp({super.key, this.enableVirtualDisplayButton = true});

  @override
  State<MyApp> createState() => _MyAppState(enableVirtualDisplayButton);
}

class _MyAppState extends State<MyApp> {
  bool _enableVirtualDisplayButton = false;
  bool _isVirtualDisplayStarted = false;

  _MyAppState(bool enableVirtualDisplayButton) {
    _enableVirtualDisplayButton = enableVirtualDisplayButton;
  }

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

  void _startVirtualDisplay(int pixelWidth, int pixelHeight) async {
    await FlutterVirtualDisplay.instance.startVirtualDisplay(pixelWidth, pixelHeight);
  }

  void _stopVirtualDisplay() async {
    await FlutterVirtualDisplay.instance.stopVirtualDisplay();
  }

  @override
  Widget build(BuildContext context) {
    final display = await ScreenRetriever.instance.getPrimaryDisplay();
    final scale = (display.scaleFactor ?? 1).toDouble();
    final pixelWidth  = (display.size.width  * scale).round();
    final pixelHeight = (display.size.height * scale).round();
  
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_enableVirtualDisplayButton)
                ElevatedButton(
                  onPressed: _isVirtualDisplayStarted
                      ? () => _stopVirtualDisplay()
                      : () => _startVirtualDisplay(pixelWidth, pixelHeight),
                  child: _isVirtualDisplayStarted
                      ? const Text('Stop Virtual Display')
                      : const Text('Start Virtual Display'),
                )
              else
                const Text('Virtual Display is not supported')

            ],
          )
        ),
      ),
    );
  }
}
