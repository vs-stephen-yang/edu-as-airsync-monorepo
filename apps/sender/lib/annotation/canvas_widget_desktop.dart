import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:display_cast_flutter/annotation/draggable_widget.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:system_tray/system_tray.dart';

import 'color_bar.dart';
import 'drawing_painter.dart';
import 'icon_button.dart';

class CanvasWidgetDesktop extends StatelessWidget {
  final WindowController? windowController;
  final Map? args;

  const CanvasWidgetDesktop({
    super.key,
    this.windowController,
    this.args,
  });

  @override
  Widget build(BuildContext context) {
    final Size physicalSize =
        WidgetsBinding.instance.platformDispatcher.views.last.physicalSize;
    return MaterialApp(
      title: 'Annotation App',
      debugShowCheckedModeBanner: false,
      home: _DesktopCanvasPage(
        windowController: windowController,
        physicalSize: physicalSize,
      ),
    );
  }
}

class _DesktopCanvasPage extends StatefulWidget {
  final WindowController? windowController;
  final Size physicalSize;

  const _DesktopCanvasPage({this.windowController, required this.physicalSize});

  @override
  State<_DesktopCanvasPage> createState() => _DesktopCanvasPageState();
}

class _DesktopCanvasPageState extends State<_DesktopCanvasPage> {
  final List<DrawingPoint?> _points = [];
  final List<DrawingPoint?> _pointSave = [];
  bool _isEraser = false;
  bool _onMinimize = false;
  Color _penColor = Colors.red;
  double _strokeWidth = 2.0;
  SystemTray _systemTray = SystemTray();

  Future<void> showSystemTray() async {
    await _systemTray.initSystemTray(
        title: "",
        iconPath: Platform.isWindows
            ? 'assets/images/ic_logo_airsync_icon.ico'
            : 'assets/images/ic_logo_airsync_icon.png');
    _systemTray.registerSystemTrayEventHandler((eventName) async {
      if (eventName == kSystemTrayEventClick) {
        await widget.windowController!.show();
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        setState(() {
          _points.addAll(_pointSave);
          _pointSave.clear();
        });
      }
    });
  }

  void _setDrawMode() {
    trackEvent('click_pen', EventCategory.annotation);

    if (!mounted) return;
    setState(() {
      _isEraser = false;
      refreshCheck();
    });
  }

  void _setEraserMode() {
    trackEvent('click_eraser', EventCategory.annotation);

    if (!mounted) return;
    setState(() {
      _isEraser = true;
      refreshCheck();
    });
  }

  void _clearAll() {
    trackEvent('click_clean', EventCategory.annotation);
    if (!mounted) return;
    setState(() {
      _points.clear();
      refreshCheck();
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

  Future<void> _endDrawing() async {
    if (!mounted) return;
    setState(() {
      _points.add(null);
      refreshCheck();
    });
  }

  void _collapse() async {
    await _systemTray.destroy();
    _systemTray = SystemTray();
    await showSystemTray();
    await Future.delayed(const Duration(milliseconds: 200));
    _onMinimize = true;
    await widget.windowController!.hide();
  }

  void _exit() async {
    await _systemTray.destroy();
    await widget.windowController!.close();
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
                ? (detail) async {
                    await refreshScreen();
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
          const Gap(24),
          AnnotationIconButton(
            icon: 'assets/images/v3_ic_annotation_pen_disable.svg',
            selected: _isEraser == false,
            onPressed: _setDrawMode,
          ),
          const Gap(8),
          AnnotationIconButton(
            icon: 'assets/images/v3_ic_annotation_eraser.svg',
            selected: _isEraser,
            onPressed: _setEraserMode,
          ),
          const Gap(8),
          AnnotationIconButton(
            icon: 'assets/images/v3_ic_annotation_trash.svg',
            selected: false,
            onPressed: _clearAll,
          ),
          const Gap(8),
          ColorBar(
            penColor: _penColor,
            callback: (Color color) {
              trackEvent('click_pen', EventCategory.annotation);

              _isEraser = false;
              _penColor = color;
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              color: Color(0xFF3C455D),
              height: 1,
            ),
          ),
          AnnotationIconButton(
            icon: 'assets/images/v3_ic_annotation_stroke_thin.svg',
            selected: _strokeWidth == 2.0,
            onPressed: () {
              if (!mounted) return;
              setState(() {
                _strokeWidth = 2.0;
                refreshCheck();
              });
            },
          ),
          const Gap(8),
          AnnotationIconButton(
            icon: 'assets/images/v3_ic_annotation_stroke_medium.svg',
            selected: _strokeWidth == 5.0,
            onPressed: () {
              if (!mounted) return;
              setState(() {
                _strokeWidth = 5.0;
                refreshCheck();
              });
            },
          ),
          const Gap(8),
          AnnotationIconButton(
            icon: 'assets/images/v3_ic_annotation_stroke_thick.svg',
            selected: _strokeWidth == 12.0,
            onPressed: () {
              if (!mounted) return;
              setState(() {
                _strokeWidth = 12.0;
                refreshCheck();
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
          AnnotationIconButton(
            icon: 'assets/images/v3_ic_annotation_minimize.svg',
            selected: false,
            onPressed: _collapse,
          ),
          const Gap(8),
          AnnotationIconButton(
            icon: 'assets/images/v3_ic_annotation_close.svg',
            selected: false,
            onPressed: _exit,
          ),
          const Gap(24),
        ],
      ),
    );
  }

  void refreshCheck() {
    if (Platform.isMacOS && _onMinimize) {
      _onMinimize = false;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await refreshScreen();
      });
    }
  }

  Future<void> refreshScreen() async {
    // mac如果設定透明背景會有殘影，需要刷新整個視窗殘影才能消失(刷新flutter層Widget無效)。
    if (!mounted) return;
    setState(() {
      _pointSave.addAll(_points.toList());
      _points.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // delay是為了畫面顯示完整後才動作。
        await Future.delayed(const Duration(milliseconds: 50));
        await widget.windowController!.hide();
        await Future.delayed(const Duration(milliseconds: 50));
        await widget.windowController!.show();
        await Future.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;
        setState(() {
          _points.addAll(_pointSave);
          _pointSave.clear();
        });
      });
    });
  }
}
