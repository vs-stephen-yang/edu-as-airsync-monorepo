import 'dart:io';

import 'package:android_window/android_window.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:display_cast_flutter/annotation/draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:system_tray/system_tray.dart';

import 'color_box.dart';
import 'drawing_painter.dart';

class CanvasWidget extends StatelessWidget {
  final WindowController? windowController;
  final Map? args;

  const CanvasWidget({
    super.key,
    this.windowController,
    this.args,
  });

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
  const _DesktopCanvasPage({this.windowController});

  @override
  State<_DesktopCanvasPage> createState() => _DesktopCanvasPageState();
}

class _DesktopCanvasPageState extends State<_DesktopCanvasPage> {
  final List<DrawingPoint?> _points = [];
  final List<DrawingPoint?> _pointSave = [];
  bool _isEraser = false;
  bool _isCollapsed = false;
  SystemTray _systemTray = SystemTray();
  Color penColor = Colors.red;
  double strokeWidth = 2.0;

  Future<void> showSystemTray() async {
    await _systemTray.initSystemTray(
      title: "",
      iconPath: Platform.isWindows ? 'assets/images/ic_logo_airsync_icon.ico' : 'assets/images/ic_logo_airsync_icon.png'
    );
    _systemTray.registerSystemTrayEventHandler((eventName) async {
      if (eventName == kSystemTrayEventClick) {
        widget.windowController!.show();
        _systemTray.destroy();
        _systemTray = SystemTray();
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() {
          _points.addAll(_pointSave);
          _pointSave.clear();
        });
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
      ..color = _isEraser ? Colors.transparent : penColor
      ..strokeWidth = _isEraser ? 20.0 : strokeWidth
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
      setState(() {
        _pointSave.addAll(_points.toList());
        _points.clear();
      });
      await Future.delayed(const Duration(milliseconds: 200));
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
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
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
          DraggableWidget(
            onMoveEnd: Platform.isMacOS
                ? () async {
                    // mac如果設定透明背景會有殘影，需要刷新整個視窗殘影才能消失(刷新flutter層Widget無效)。
                    setState(() {
                      _pointSave.addAll(_points.toList());
                      _points.clear();
                    });
                    await Future.delayed(const Duration(milliseconds: 100));
                    await widget.windowController!.hide();
                    await Future.delayed(const Duration(milliseconds: 50));
                    await widget.windowController!.show();
                    setState(() {
                      _points.addAll(_pointSave);
                      _pointSave.clear();
                    });
                  }
                : null,
            child: _buildPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel() {
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: ShapeDecoration(
        color: const Color(0xFF20273E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/images/ic_annotation_drag.svg',width: 20, height: 10,),
          const Gap(16),
          if (!_isCollapsed) ...[
            IconButton(
              icon: 'assets/images/ic_annotation_pen.svg',
              selected: _isEraser == false,
              onPressed: _setDrawMode,
            ),
            const Gap(8),
            IconButton(
              icon: 'assets/images/ic_annotation_eraser.svg',
              selected: _isEraser,
              onPressed: _setEraserMode,
            ),
            const Gap(8),
            IconButton(
              icon: 'assets/images/ic_annotation_trash.svg',
              selected: false,
              onPressed: _clearAll,
            ),
            const Gap(8),
            ColorBar(
              callback: (Color color) {
                _isEraser = false;
                penColor = color;
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                color: Color(0xFF3C455D),
                height: 1,
              ),
            ),
            IconButton(
              icon: 'assets/images/ic_annotation_stroke_thin.svg',
              selected: strokeWidth == 2.0,
              enable: _isEraser == false,
              onPressed: () {
                setState(() {
                  _isEraser = false;
                  strokeWidth = 2.0;
                });
              },
            ),
            const Gap(8),
            IconButton(
              icon: 'assets/images/ic_annotation_stroke_medium.svg',
              selected: strokeWidth == 8.0,
              enable: _isEraser == false,
              onPressed: () {
                setState(() {
                  _isEraser = false;
                  strokeWidth = 8.0;
                });
              },
            ),
            const Gap(8),
            IconButton(
              icon: 'assets/images/ic_annotation_stroke_thick.svg',
              selected: strokeWidth == 15.0,
              enable: _isEraser == false,
              onPressed: () {
                setState(() {
                  _isEraser = false;
                  strokeWidth = 15.0;
                });
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                color: Color(0xFF3C455D),
                height: 1,
              ),
            ),
            IconButton(
              icon: 'assets/images/ic_annotation_minimize.svg',
              selected: false,
              onPressed: _collapse,
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
          const Gap(8),
          IconButton(
            icon: 'assets/images/ic_annotation_close.svg',
            selected: false,
            onPressed: _exit,
          ),
          const Gap(16),
          SvgPicture.asset('assets/images/ic_annotation_drag.svg',width: 20, height: 10,),
        ],
      ),
    );
  }
}


class IconButton extends StatelessWidget {
  const IconButton(
      {super.key, this.onPressed, required this.selected, required this.icon, this.enable = true});

  final String icon;
  final VoidCallback? onPressed;
  final bool selected;
  final bool enable;

  @override
  Widget build(BuildContext context) {
    bool tapDown = false;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return GestureDetector(
          onTapDown: (_) {
            setState(() {
              tapDown = true;
            });
          },
          onTapUp: (_) {
            setState(() {
              tapDown = false;
            });
          },
          onTap: onPressed,
          child: Opacity(
            opacity: enable ? 1 : 0.32,
            child: Container(
              width: 36,
              height: 36,
              decoration: ShapeDecoration(
                color: (tapDown || selected) ? const Color(0xFF5D80ED) : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: SvgPicture.asset(icon),
            ),
          ),
        );
      },
    );
  }
}

class ColorBar extends StatefulWidget {
  const ColorBar({super.key, required this.callback});
  final ColorSelectCallback callback;

  @override
  State<ColorBar> createState() => _ColorBarState();
}

class _ColorBarState extends State<ColorBar> {
  Color penColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return ColorBoxGroup(
      width: 30,
      height: 30,
      spacing: 10,
      selectedBorderWidth: 2,
      selectedBorderColor: Colors.white,
      groupValue: penColor,
      colors: const [
        Colors.red,
        Colors.blue,
        Colors.yellow,
        Colors.black,
        Colors.white,
      ],
      onTap: (color){
        setState(() {
          penColor = color;
          widget.callback.call(color);
        });
      },
    );
  }
}

