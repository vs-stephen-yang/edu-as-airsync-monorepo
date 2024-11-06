import 'package:android_window/android_window.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:display_cast_flutter/annotation/draggable_widget.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:flutter/material.dart';

import 'arrow_shape_painter.dart';
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
    final Size physicalSize =
        WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
    return MaterialApp(
      title: 'Annotation App',
      debugShowCheckedModeBanner: false,
      home: _CanvasPage(
        windowController: windowController,
        initPhysicalSize: physicalSize,
      ),
    );
  }
}

class _CanvasPage extends StatefulWidget {
  final WindowController? windowController;
  final Size initPhysicalSize;

  const _CanvasPage({this.windowController, required this.initPhysicalSize});

  @override
  State<_CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<_CanvasPage> with WidgetsBindingObserver {
  final List<DrawingPoint?> _points = [];
  bool _isEraser = false;
  bool _isCollapsed = false;
  Color _penColor = Colors.red;
  double _strokeWidth = 2.0;
  Offset panelOffset = Offset.zero;
  GlobalKey colorKey = GlobalKey();
  GlobalKey strokeKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  void _setEraserMode() {
    trackEvent('click_eraser', EventCategory.annotation);

    setState(() {
      _isEraser = true;
    });
  }

  void _setPenMode() {
    trackEvent('click_pen', EventCategory.annotation);

    setState(() {
      _isEraser = false;
    });
  }

  void _clearAll() {
    trackEvent('click_clean', EventCategory.annotation);

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
    final pixelRatio =
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    final int width = (78 * pixelRatio).toInt();
    final int height = (104 * pixelRatio).toInt();
    AndroidWindow.resize(width, height);
    _removeOverlay();
    await Future.delayed(const Duration(milliseconds: 150));
    setState(() {
      _isCollapsed = true;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeMetrics() {
    setState(() {
      panelOffset = Offset.zero;
      _removeOverlay();
    });
    super.didChangeMetrics();
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
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
                onMoveEnd: (offset) {
                  panelOffset = offset;
                  _removeOverlay();
                },
              ),
            ] else ...[
              Container(
                width: 76,
                alignment: Alignment.center,
                decoration: const ShapeDecoration(
                  color: Color(0xFF20273E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(40),
                        bottomRight: Radius.circular(40)),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnnotationIconButton(
                      selected: false,
                      size: 32,
                      icon: 'assets/images/v3_ic_annotation_pen.svg',
                      onPressed: () async {
                        if (_isCollapsed) {
                          AndroidWindow.resize(3000, 3000);
                        } else {
                          AndroidWindow.resize(76, 76);
                        }
                        _removeOverlay();
                        await Future.delayed(const Duration(milliseconds: 150));
                        setState(() {
                          _isCollapsed = !_isCollapsed;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAndroidPanel() {
    return Container(
      width: 78,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: const ShapeDecoration(
        color: Color(0xFF20273E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(40), bottomRight: Radius.circular(40)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnnotationIconButton(
            icon: 'assets/images/v3_ic_annotation_shrink.svg',
            size: 60,
            iconSize: 32,
            circleStyle: true,
            selected: false,
            onPressed: _collapse,
          ),
          AnnotationIconButton(
            icon: 'assets/images/v3_ic_annotation_pen.svg',
            size: 60,
            iconSize: 32,
            circleStyle: true,
            selected: _isEraser == false,
            onPressed: _setPenMode,
          ),
          AnnotationIconButton(
            icon: 'assets/images/v3_ic_annotation_eraser.svg',
            size: 60,
            iconSize: 32,
            circleStyle: true,
            selected: _isEraser,
            onPressed: _setEraserMode,
          ),
          AnnotationIconButton(
            icon: 'assets/images/v3_ic_annotation_trash.svg',
            size: 60,
            iconSize: 32,
            circleStyle: true,
            selected: false,
            onPressed: _clearAll,
          ),
          GestureDetector(
            key: colorKey,
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
              _createOverlayEntry(colorKey, createSelectColor(), 150);
              setState(() {
                _isEraser = false;
              });
            },
          ),
          AnnotationIconButton(
            key: strokeKey,
            icon:
                'assets/images/v3_ic_annotation_stroke_${_strokeWidth == 2.0 ? 'thin' : _strokeWidth == 8.0 ? 'medium' : 'thick'}.svg',
            selected: false,
            size: 60,
            circleStyle: true,
            onPressed: () {
              _createOverlayEntry(strokeKey, createSelectStrokeWidth(), 110);
              setState(() {
                _isEraser = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget createSelectStrokeWidth() {
    return ArrowShape(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnnotationIconButton(
                  icon: 'assets/images/v3_ic_annotation_stroke_thin.svg',
                  size: 42,
                  selected: _strokeWidth == 2.0,
                  enable: _isEraser == false,
                  circleStyle: true,
                  onPressed: () {
                    setState(() {
                      _removeOverlay();
                      _isEraser = false;
                      _strokeWidth = 2.0;
                    });
                  },
                ),
                AnnotationIconButton(
                  icon: 'assets/images/v3_ic_annotation_stroke_medium.svg',
                  size: 42,
                  selected: _strokeWidth == 8.0,
                  enable: _isEraser == false,
                  circleStyle: true,
                  onPressed: () {
                    setState(() {
                      _removeOverlay();
                      _isEraser = false;
                      _strokeWidth = 8.0;
                    });
                  },
                ),
                AnnotationIconButton(
                  icon: 'assets/images/v3_ic_annotation_stroke_thick.svg',
                  size: 42,
                  selected: _strokeWidth == 15.0,
                  enable: _isEraser == false,
                  circleStyle: true,
                  onPressed: () {
                    setState(() {
                      _removeOverlay();
                      _isEraser = false;
                      _strokeWidth = 15.0;
                    });
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget createSelectColor() {
    return ArrowShape(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorBar(
              penColor: _penColor,
              size: 36,
              spacing: 28,
              callback: (Color color) {
                setState(() {
                  _removeOverlay();
                  _penColor = color;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _createOverlayEntry(GlobalKey key, Widget child, double childHeight) {
    _removeOverlay();
    RenderBox renderBox = key.currentContext?.findRenderObject() as RenderBox;
    var offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + renderBox.size.width + 10,
        top: offset.dy - childHeight / 2,
        child: child,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }
}
