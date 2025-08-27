import 'package:flutter/material.dart';

enum StreamingLayoutMode {
  single,
  list,
  grid,
}

typedef PositionCalculator = LayoutPosition Function({
  required int index,
  required int count,
  required int? enlarged,
  required Size screenSize,
  required int pageIndex,
});

class StreamingViewConfig {
  final StreamingLayoutMode mode;
  final int Function(int count) adjustSplitCount;
  final Widget Function(int pageIndex, int dotCount, VoidCallback onNext)?
      buildPageHeaderFooter;
  final PositionCalculator positionCalculator;
  int dotCount;

  StreamingViewConfig({
    required this.mode,
    required this.adjustSplitCount,
    required this.positionCalculator,
    this.buildPageHeaderFooter,
    this.dotCount = 1,
  });
}

class LayoutPosition {
  final double? left, top, right, bottom, width, height;

  const LayoutPosition({
    this.left,
    this.top,
    this.right,
    this.bottom,
    required this.width,
    required this.height,
  });

  const LayoutPosition.zero()
      : left = 0,
        top = 0,
        right = null,
        bottom = null,
        width = 0,
        height = 0;

  factory LayoutPosition.fromGrid({
    required Offset cell,
    required double cellW,
    required double cellH,
  }) {
    double? left = cell.dx == 2 ? null : cell.dx * cellW;
    double? right = cell.dx == 2 ? 0 : null;
    double? top = cell.dy == 2 ? null : cell.dy * cellH;
    double? bottom = cell.dy == 2 ? 0 : null;
    return LayoutPosition(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: cellW,
      height: cellH,
    );
  }
}
