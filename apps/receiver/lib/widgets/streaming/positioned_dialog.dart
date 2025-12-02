import 'package:flutter/material.dart';

/// 支援精確定位的對話框包裝器
///
/// 用於 Moderator / Shortcuts 對話框的動態定位
class PositionedDialog extends StatelessWidget {
  final Widget child;
  final Offset position;
  final Size? dialogSize;

  const PositionedDialog({
    super.key,
    required this.child,
    required this.position,
    this.dialogSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          width: dialogSize?.width,
          height: dialogSize?.height,
          child: child,
        ),
      ],
    );
  }
}

/// 提供對話框尺寸的 InheritedWidget
///
/// 用於讓對話框內容知道自己應該使用的尺寸
class DialogSizeProvider extends InheritedWidget {
  final Size size;

  const DialogSizeProvider({
    super.key,
    required this.size,
    required super.child,
  });

  static Size? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DialogSizeProvider>()
        ?.size;
  }

  @override
  bool updateShouldNotify(DialogSizeProvider oldWidget) {
    return size != oldWidget.size;
  }
}
