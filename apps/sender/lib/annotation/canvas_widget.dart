import 'dart:io';

import 'package:android_window/android_window.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';

import 'drawing_painter.dart';

class CanvasWidget extends StatelessWidget {
  final WindowController? windowController;
  final Map? args;

  const CanvasWidget({
    Key? key,
    this.windowController,
    this.args,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Annotation App',
      debugShowCheckedModeBanner: false,
      home: _DesktopCanvasPage(windowController: windowController),
    );
  }
}

class _DesktopCanvasPage extends StatefulWidget {
  final WindowController? windowController;
  const _DesktopCanvasPage({Key? key, this.windowController}) : super(key: key);

  @override
  State<_DesktopCanvasPage> createState() => _DesktopCanvasPageState();
}

class _DesktopCanvasPageState extends State<_DesktopCanvasPage> {
  final List<DrawingPoint?> _points = [];
  bool _isEraser = false;
  bool _isCollapsed = false;
  SystemTray _systemTray = SystemTray();

  @override
  void initState() {
    super.initState();
  }

  Future<void> showSystemTray() async {
    await _systemTray.initSystemTray(
      title: "",
      iconPath: 'assets/images/ic_logo_airsync_icon.png'
    );

    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        widget.windowController!.show();
        _systemTray.destroy();
        _systemTray = SystemTray();
      }
    });
  }

  void _setDrawMode() {
    setState(() {
      _isEraser = false;
    });
  }

  void _setEraserMode() {
    setState(() {
      _isEraser = true;
    });
  }

  void _clearAll() {
    setState(() {
      _points.clear();
    });
  }

  void _addPoint(Offset offset) {
    Paint paint = Paint()
      ..color = _isEraser ? Colors.transparent : Colors.black
      ..strokeWidth = _isEraser ? 20.0 : 5.0
      ..strokeCap = StrokeCap.round;
    if (_isEraser) {
      paint.blendMode = BlendMode.clear;
    }
    setState(() {
      _points.add(DrawingPoint(offset: offset, paint: paint));
    });
  }

  void _endDrawing() {
    setState(() {
      _points.add(null);
    });
  }

  void _collapse() async {

    if (Platform.isWindows || Platform.isMacOS) {
      await showSystemTray();
      widget.windowController!.hide();
    } else if (Platform.isAndroid) {
      setState(() {
        _isCollapsed = true;
      });
      AndroidWindow.resize(300, 300); // TODO: Set the size of the window
    }
  }

  void _expand() {
    if (Platform.isWindows || Platform.isMacOS) {
      // Do nothing
    } else if (Platform.isAndroid) {
      setState(() {
        _isCollapsed = false;
      });
      AndroidWindow.resize(1920, 1080); // TODO: Set the size of the window
    }
  }

  void _exit() async {
    if (Platform.isWindows || Platform.isMacOS) {
      widget.windowController!.close();
    } else if (Platform.isAndroid) {
      AndroidWindow.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              _addPoint(details.localPosition);
            },
            onPanEnd: (details) {
              _endDrawing();
            },
            child: CustomPaint(
              painter: DrawingPainter(_points),
              size: Size.infinite,
            ),
          ),
          _buildFixedPanel(),
        ],
      ),
    );
  }

  Widget _buildFixedPanel() {
    return Positioned(
      left: 0,
      top: 0,
      child: _buildPanel(),
    );
  }

  Widget _buildPanel() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isCollapsed) ...[
            ElevatedButton(
              onPressed: _setDrawMode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Draw'),
            ),
            ElevatedButton(
              onPressed: _setEraserMode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Eraser'),
            ),
            ElevatedButton(
              onPressed: _clearAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Clear'),
            ),
            ElevatedButton(
              onPressed: _collapse,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Collapse'),
            ),
          ] else
            ...[
              ElevatedButton(
                onPressed: _expand,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Expand'),
              ),
            ],
          ElevatedButton(
            onPressed: _exit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
