import 'dart:convert';
import 'dart:io';

import 'package:android_window/main.dart' as android_window;
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainWidget extends StatefulWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  final TextEditingController _controller = TextEditingController(text: '-1');

  void _startAnnotation() async {
    if (Platform.isWindows || Platform.isMacOS) {
      final input = _controller.text;
      int screenIndex = -1;
      try {
        screenIndex = int.parse(input);
      }
      catch (e) {
        print('Invalid input: $input');
      }
      final window = await DesktopMultiWindow.createFullscreenWindow(
        jsonEncode({'mode': 'desktop_canvas'}),
        screenIndex
      );
      window.show();
    } else if (Platform.isAndroid) {
      android_window.open(
        size: const Size(1920, 1080), // TODO: Set the size of the window
        position: const Offset(0, 0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Annotation App'),
        ),
        body: Column(
          children: [
            TextButton(
              onPressed: _startAnnotation,
              child: const Text('Start Annotation'),
            ),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: const InputDecoration(
                hintText: 'Monitor Index',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
