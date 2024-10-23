import 'dart:io';

import 'package:android_window/android_window.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:display_cast_flutter/annotation/draggable_widget.dart';
import 'package:flutter/material.dart';

import 'color_bar.dart';
import 'drawing_painter.dart';
import 'icon_button.dart';

class CanvasWidgetAndroid extends StatelessWidget {
  final WindowController? windowController;
  final Map? args;

  const CanvasWidgetAndroid({
    super.key,
    this.windowController,
    this.args,
  });

  @override
  Widget build(BuildContext context) {
    final Size physicalSize = WidgetsBinding.instance.platformDispatcher.views.last.physicalSize;
    return MaterialApp(
      title: 'Annotation App',
      debugShowCheckedModeBanner: false,
      home: _CanvasPage(
        windowController: windowController,
        physicalSize: physicalSize,
      ),
    );
  }
}

class _CanvasPage extends StatefulWidget {
  final WindowController? windowController;
  final Size physicalSize;

  const _CanvasPage({this.windowController, required this.physicalSize});

  @override
  State<_CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<_CanvasPage> {
  final List<DrawingPoint?> _points = [];
  bool _isEraser = false;
  bool _isCollapsed = false;
  bool _selectingColor = false;
  bool _selectingStrokeWidth = false;
  Color _penColor = Colors.red;
  double _strokeWidth = 2.0;
  Offset panelOffset = Offset.zero;

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
      ..color = _isEraser ? Colors.transparent : _penColor
      ..strokeWidth = _isEraser ? 20.0 : _strokeWidth
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
    AndroidWindow.resize(76, 76);
    await Future.delayed(const Duration(milliseconds: 150));
    setState(() {
      _isCollapsed = true;
    });
  }

  void _exit() async {
    AndroidWindow.close();
  }

  @override
  void initState() {
    if (Platform.isAndroid) {
      // final dpSize = widget.physicalSize /
      //     WidgetsBinding
      //         .instance.platformDispatcher.views.first.devicePixelRatio;
      // panelOffset = Offset((dpSize.width - 316) / 2, dpSize.height - 100);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AndroidWindow(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            if (!_isCollapsed) ...[
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
                position: panelOffset,
                child: _buildAndroidPanel(),
              ),
            ] else ...[
              Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: const Color(0xff20273E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                child: AnnotationIconButton(
                  selected: false,
                  size: 32,
                  icon: 'assets/images/ic_annotation_pen.svg',
                  onPressed: () async {
                    if (_isCollapsed) {
                      AndroidWindow.resize(3000, 3000);
                    } else {
                      AndroidWindow.resize(76, 76);
                    }
                    await Future.delayed(const Duration(milliseconds: 150));
                    setState(() {
                      _isCollapsed = !_isCollapsed;
                    });
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAndroidPanel() {
    if (_selectingColor) {
      return Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 26),
        decoration: ShapeDecoration(
          color: const Color(0xFF20273E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorBar(
              penColor: _penColor,
              size: 32,
              spacing: 28,
              callback: (Color color) {
                setState(() {
                  _selectingColor = false;
                  _penColor = color;
                });
              },
            ),
          ],
        ),
      );
    }
    if (_selectingStrokeWidth) {
      return Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 68),
        decoration: ShapeDecoration(
          color: const Color(0xFF20273E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnnotationIconButton(
              icon: 'assets/images/ic_annotation_stroke_thin.svg',
              size: 60,
              selected: _strokeWidth == 2.0,
              enable: _isEraser == false,
              circleStyle: true,
              onPressed: () {
                setState(() {
                  _isEraser = false;
                  _selectingStrokeWidth = false;
                  _strokeWidth = 2.0;
                });
              },
            ),
            AnnotationIconButton(
              icon: 'assets/images/ic_annotation_stroke_medium.svg',
              size: 60,
              selected: _strokeWidth == 8.0,
              enable: _isEraser == false,
              circleStyle: true,
              onPressed: () {
                setState(() {
                  _isEraser = false;
                  _selectingStrokeWidth = false;
                  _strokeWidth = 8.0;
                });
              },
            ),
            AnnotationIconButton(
              icon: 'assets/images/ic_annotation_stroke_thick.svg',
              size: 60,
              selected: _strokeWidth == 15.0,
              enable: _isEraser == false,
              circleStyle: true,
              onPressed: () {
                setState(() {
                  _isEraser = false;
                  _selectingStrokeWidth = false;
                  _strokeWidth = 15.0;
                });
              },
            ),
          ],
        ),
      );
    }
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: ShapeDecoration(
        color: const Color(0xFF20273E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnnotationIconButton(
            icon: 'assets/images/ic_annotation_pen.svg',
            size: 60,
            iconSize: 32,
            circleStyle: true,
            selected: _isEraser == false,
            onPressed: _collapse,
          ),
          AnnotationIconButton(
            icon: 'assets/images/ic_annotation_eraser.svg',
            size: 60,
            iconSize: 32,
            circleStyle: true,
            selected: _isEraser,
            onPressed: _setEraserMode,
          ),
          AnnotationIconButton(
            icon: 'assets/images/ic_annotation_trash.svg',
            size: 60,
            iconSize: 32,
            circleStyle: true,
            selected: false,
            onPressed: _clearAll,
          ),
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Container(
                width: 24,
                height: 24,
                decoration: ShapeDecoration(
                  color: _penColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99)),
                ),
              ),
            ),
            onTap: () {
              setState(() {
                _isEraser = false;
                _selectingColor = true;
              });
            },
          ),
          AnnotationIconButton(
            icon:
                'assets/images/ic_annotation_stroke_${_strokeWidth == 2.0 ? 'thin' : _strokeWidth == 8.0 ? 'medium' : 'thick'}.svg',
            selected: false,
            circleStyle: true,
            onPressed: () {
              setState(() {
                _isEraser = false;
                _selectingStrokeWidth = true;
              });
            },
          ),
          AnnotationIconButton(
            icon: 'assets/images/ic_annotation_close.svg',
            circleStyle: true,
            iconSize: 32,
            size: 60,
            selected: false,
            onPressed: _exit,
          ),
        ],
      ),
    );
  }
}
