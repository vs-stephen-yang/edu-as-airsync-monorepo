import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class GlobalToast {
  GlobalToast._();

  /// 將此 key 接到 MaterialApp.navigatorKey
  /// static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  /// 這邊main_common已經使用NavigationService.navigationKey,overlay就直接從NavigationService.navigationKey拿。

  static Duration animationIn = const Duration(milliseconds: 180);
  static Duration animationOut = const Duration(milliseconds: 150);

  static final List<_ToastRequest> _queue = <_ToastRequest>[];
  static bool _isShowing = false;
  static int _seq = 0;

  static Future<void> show(
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    double? radius,
    EdgeInsets margin =
        const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    IconData? icon,
    double maxWidth = 242,
  }) async {
    _queue.add(
      _ToastRequest(
        id: ++_seq,
        message: message,
        duration: duration,
        backgroundColor: backgroundColor,
        textColor: textColor,
        margin: margin,
        padding: padding,
        icon: icon,
        maxWidth: maxWidth,
      ),
    );
    _dequeue();
  }

  static void _dequeue() {
    if (_isShowing || _queue.isEmpty) return;

    final overlay = NavigationService.navigationKey.currentState?.overlay;
    if (overlay == null) {
      debugPrint(
          'Toast: overlay not ready, dropping ${_queue.length} item(s).');
      _queue.clear();
      return;
    }

    _isShowing = true;
    final req = _queue.removeAt(0);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        request: req,
        onClosed: () {
          entry.remove();
          _isShowing = false;
          WidgetsBinding.instance.addPostFrameCallback((_) => _dequeue());
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _ToastRequest {
  _ToastRequest({
    required this.id,
    required this.message,
    required this.duration,
    required this.backgroundColor,
    required this.textColor,
    required this.margin,
    required this.padding,
    required this.icon,
    required this.maxWidth,
  });

  final int id;
  final String message;
  final Duration duration;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final IconData? icon;
  final double maxWidth;
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({required this.request, required this.onClosed});

  final _ToastRequest request;
  final VoidCallback onClosed;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: GlobalToast.animationIn,
      reverseDuration: GlobalToast.animationOut,
    );
    _fade = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn);

    _run();
  }

  Future<void> _run() async {
    try {
      await _controller.forward();
      await Future<void>.delayed(widget.request.duration);
      await _controller.reverse();
    } finally {
      if (mounted) widget.onClosed();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.request.backgroundColor ??
        context.tokens.color.vsdslColorSurface1000;
    final fg = widget.request.textColor ?? Colors.white;

    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: IgnorePointer(
          ignoring: false,
          child: SafeArea(
            left: false,
            right: false,
            child: FadeTransition(
              opacity: _fade,
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: widget.request.maxWidth),
                  child: DecoratedBox(
                    key: ValueKey('toast-${widget.request.id}'),
                    decoration: ShapeDecoration(
                      color: bg,
                      shape: RoundedRectangleBorder(
                        borderRadius: context.tokens.radii.vsdslRadiusXl,
                      ),
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withAlpha(46),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: widget.request.padding,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.request.icon != null) ...[
                            Icon(widget.request.icon, color: fg, size: 18),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: V3AutoHyphenatingText(
                              widget.request.message,
                              style: TextStyle(
                                  color: fg, fontSize: 14, height: 1.2),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
