import 'package:android_window/android_window.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
        sizeList: [physicalSize.width, physicalSize.height],
      ),
    );
  }
}

class _CanvasPage extends StatefulWidget {
  final WindowController? windowController;
  final Size initPhysicalSize;
  final List<double> sizeList;

  const _CanvasPage(
      {this.windowController,
      required this.initPhysicalSize,
      required this.sizeList});

  @override
  State<_CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<_CanvasPage> with WidgetsBindingObserver {
  final List<DrawingPoint?> _points = [];
  bool _isEraser = false;
  bool _isCollapsed = false;
  Color _penColor = Colors.red;
  double _strokeWidth = 2.0;
  OverlayEntry? _overlayEntry;
  GlobalKey colorKey = GlobalKey();
  GlobalKey strokeKey = GlobalKey();

  void _setEraserMode() {
    trackEvent('click_eraser', EventCategory.annotation);

    if (!mounted) return;
    setState(() {
      _isEraser = true;
    });
  }

  void _clearAll() {
    trackEvent('click_clean', EventCategory.annotation);

    if (!mounted) return;
    setState(() {
      _points.clear();
    });
  }

  void _addPoint(Offset offset) {
    Paint paint = Paint()
      ..color = _isEraser ? Colors.transparent : _penColor
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;
    if (_isEraser) {
      paint.blendMode = BlendMode.clear;
    }
    if (!mounted) return;
    setState(() {
      _points.add(DrawingPoint(offset: offset, paint: paint));
    });
  }

  void _endDrawing() {
    if (!mounted) return;
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
    if (!mounted) return;
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
    if (!mounted) return;
    setState(() {
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
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildAndroidPanel(),
              )
            ] else ...[
              Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD3D6E1), width: 2),
                  color: const Color(0xFF20273E),
                  borderRadius: const BorderRadius.all(Radius.circular(40)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnnotationIconButton(
                        selected: false,
                        size: 32,
                        icon: 'assets/images/v3_ic_annotation_pen_disable.svg',
                        onPressed: () async {
                          _removeOverlay();
                          await Future.delayed(
                              const Duration(milliseconds: 150));
                          if (!mounted) return;
                          setState(() {
                            _isCollapsed = false;
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            AndroidWindow.resize(5000, 3000);
                          });
                        }),
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
      alignment: Alignment.topCenter,
      width: 360,
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFD3D6E1),
            width: 2,
          ),
          left: BorderSide(
            color: Color(0xFFD3D6E1),
            width: 2,
          ),
          right: BorderSide(
            color: Color(0xFFD3D6E1),
            width: 2,
          ),
        ),
        color: Color(0xFF20273E),
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(40), topLeft: Radius.circular(40)),
      ),
      child: Row(
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
          GestureDetector(
            key: colorKey,
            child: Container(
              alignment: Alignment.center,
              width: 60,
              height: 60,
              decoration: ShapeDecoration(
                color: _isEraser ? Colors.transparent : _penColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99)),
              ),
              child: SvgPicture.asset(
                'assets/images/${_isEraser ? 'v3_ic_annotation_pen_disable' : 'v3_ic_annotation_pen'}.svg',
                width: _isEraser ? 32 : 60,
                height: _isEraser ? 32 : 60,
              ),
            ),
            onTap: () {
              _createOverlayEntry(colorKey, createSelectColor(), 170);
              trackEvent('click_pen', EventCategory.annotation);

              if (!mounted) return;
              setState(() {
                _isEraser = false;
              });
            },
          ),
          AnnotationIconButton(
            icon:
                'assets/images/${_isEraser ? 'v3_ic_annotation_eraser' : 'v3_ic_annotation_eraser_disable'}.svg',
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
          AnnotationIconButton(
            key: strokeKey,
            icon:
                'assets/images/v3_ic_annotation_stroke_${_strokeWidth == 2.0 ? 'thin' : _strokeWidth == 5.0 ? 'medium' : 'thick'}.svg',
            selected: false,
            size: 60,
            circleStyle: true,
            onPressed: () {
              _createOverlayEntry(strokeKey, createSelectStrokeWidth(), 100);
            },
          ),
        ],
      ),
    );
  }

  Widget createSelectStrokeWidth() {
    return ArrowShape(
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
        height: 64,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnnotationIconButton(
              icon: 'assets/images/v3_ic_annotation_stroke_thin.svg',
              size: 42,
              selected: _strokeWidth == 2.0,
              circleStyle: false,
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  _removeOverlay();
                  _strokeWidth = 2.0;
                });
              },
            ),
            AnnotationIconButton(
              icon: 'assets/images/v3_ic_annotation_stroke_medium.svg',
              size: 42,
              selected: _strokeWidth == 5.0,
              circleStyle: false,
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  _removeOverlay();
                  _strokeWidth = 5.0;
                });
              },
            ),
            AnnotationIconButton(
              icon: 'assets/images/v3_ic_annotation_stroke_thick.svg',
              size: 42,
              selected: _strokeWidth == 12.0,
              circleStyle: false,
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  _removeOverlay();
                  _strokeWidth = 12.0;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget createSelectColor() {
    return ArrowShape(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorBar(
              penColor: _penColor,
              size: 36,
              spacing: 10,
              callback: (Color color) {
                if (!mounted) return;
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
        top: offset.dy - renderBox.size.height - 25,
        left: offset.dx - childHeight / 2,
        child: child,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }
}
