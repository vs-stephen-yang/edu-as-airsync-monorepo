import 'dart:async';

import 'package:flutter/material.dart';

/// 極隱晦的 FPS 保持器：在角落畫一個 1×1 的微透明像素，
/// 透明度在 1~2/255 間切換，確保每 ~33ms 有可見差異讓畫面更新。
class StealthFpsKeeper extends StatefulWidget {
  const StealthFpsKeeper({
    super.key,
    this.fps = 30,
    this.alignment = AlignmentDirectional.bottomEnd,
    this.logicalSize = 1.0,
    this.color = Colors.black, // 深色背景建議用黑；淺色背景可改白
    this.padding = const EdgeInsets.all(1),
    this.enabled = true,
  }) : assert(fps > 0 && fps <= 120, 'fps must be in (0, 120].');

  /// 目標更新頻率（預設 30fps）
  final double fps;

  /// 小點擺放位置（預設右下角）
  final AlignmentGeometry alignment;

  /// 小點大小（邏輯像素，預設 1）
  final double logicalSize;

  /// 小點基底顏色（會套用極低 alpha）
  final Color color;

  /// 與邊緣的間距，避免被裁切
  final EdgeInsets padding;

  /// 是否啟用
  final bool enabled;

  /// 方便直接掛到根 Overlay；回傳 OverlayEntry，可自行移除。
  static OverlayEntry attachToOverlay(
    BuildContext context, {
    double fps = 30,
    AlignmentGeometry alignment = AlignmentDirectional.bottomEnd,
    double logicalSize = 1.0,
    Color color = Colors.black,
    EdgeInsets padding = const EdgeInsets.all(1),
  }) {
    final entry = OverlayEntry(
      builder: (_) => IgnorePointer(
        ignoring: true,
        child: SizedBox.expand(
          child: _OverlayHost(key: _OverlayHost.stateKey), // 承載 keeper 的容器
        ),
      ),
    );
    final overlay = Overlay.of(context, rootOverlay: true);
    overlay.insert(entry);

    // 把 keeper 再插入到 overlay host 上（避免攔指標、避免佔位）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      (_OverlayHost.stateKey.currentState)?.setChild(
        StealthFpsKeeper(
          fps: fps,
          alignment: alignment,
          logicalSize: logicalSize,
          color: color,
          padding: padding,
        ),
      );
    });

    return entry;
  }

  @override
  State<StealthFpsKeeper> createState() => _StealthFpsKeeperState();
}

class _StealthFpsKeeperState extends State<StealthFpsKeeper> {
  Timer? _timer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _start();
  }

  @override
  void didUpdateWidget(covariant StealthFpsKeeper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fps != widget.fps || oldWidget.enabled != widget.enabled) {
      _stop();
      if (widget.enabled) _start();
    }
  }

  void _start() {
    final interval = Duration(milliseconds: (1000 / widget.fps).round());
    _timer = Timer.periodic(interval, (_) {
      if (!mounted) return;
      setState(() => _tick++); // 觸發極小幅度變化與重繪
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();

    final dot = SizedBox(
      width: widget.logicalSize,
      height: widget.logicalSize,
      child: RepaintBoundary(
        child: CustomPaint(
          isComplex: false,
          willChange: true,
          painter: _StealthDotPainter(
            tick: _tick,
            baseColor: widget.color,
          ),
        ),
      ),
    );

    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: widget.padding,
        child: ExcludeSemantics(
          child: dot,
        ),
      ),
    );
  }
}

class _StealthDotPainter extends CustomPainter {
  _StealthDotPainter({required this.tick, required this.baseColor});

  final int tick;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    // 在 1 與 2（/255）之間切換 alpha：幾乎不可見，但每幀像素確實不同。
    final int alpha = 1 + (tick & 0x01);
    final paint = Paint()..color = baseColor.withAlpha(alpha);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _StealthDotPainter oldDelegate) =>
      oldDelegate.tick != tick;
}

/// 內部用：給 attachToOverlay 占滿畫面並承載 StealthFpsKeeper。
class _OverlayHost extends StatefulWidget {
  const _OverlayHost({super.key});

  static final GlobalKey<_OverlayHostState> stateKey =
      GlobalKey<_OverlayHostState>();

  @override
  State<_OverlayHost> createState() => _OverlayHostState();
}

class _OverlayHostState extends State<_OverlayHost> {
  Widget _child = const SizedBox.shrink();

  void setChild(Widget child) => setState(() => _child = child);

  @override
  Widget build(BuildContext context) => _child;
}
