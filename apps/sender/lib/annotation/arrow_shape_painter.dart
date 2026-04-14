import 'package:flutter/material.dart';

class ArrowShape extends StatelessWidget {
  const ArrowShape({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArrowShapePainter(),
      child: child,
    );
  }
}

class ArrowShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.white // 邊框顏色
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0; // 邊框寬度

    final fillPaint = Paint()
      ..color = const Color(0xFF20273E) // 填充顏色
      ..style = PaintingStyle.fill;

    const double radius = 20.0; // 圓角半徑
    const double arrowWidth = 20.0; // 小三角的寬度
    const double arrowHeight = 10.0; // 小三角的高度
    final double arrowOffset = 0.5 * (size.width - arrowWidth); // 三角形在底部中心

    // Path 用於繪製形狀
    final path = Path()
      ..moveTo(radius, 0) // 起始於左上角，略過圓角半徑部分
      ..lineTo(size.width - radius, 0) // 畫上邊（略過右上角圓角半徑）
      ..arcToPoint(Offset(size.width, radius),
          radius: const Radius.circular(radius)) // 右上圓角
      ..lineTo(size.width, size.height - radius - arrowHeight) // 右邊直線
      ..arcToPoint(
        Offset(size.width - radius, size.height - arrowHeight),
        radius: const Radius.circular(radius),
      ) // 右下圓角
      ..lineTo(arrowOffset + arrowWidth, size.height - arrowHeight) // 底部直線，右邊
      ..lineTo(arrowOffset + arrowWidth / 2, size.height) // 畫出箭頭的右邊
      ..lineTo(arrowOffset, size.height - arrowHeight) // 畫出箭頭的左邊
      ..lineTo(radius, size.height - arrowHeight) // 底部直線，左邊
      ..arcToPoint(
        Offset(0, size.height - radius - arrowHeight),
        radius: const Radius.circular(radius),
      ) // 左下圓角
      ..lineTo(0, radius) // 左邊直線
      ..arcToPoint(const Offset(radius, 0),
          radius: const Radius.circular(radius)); // 左上圓角

    // 畫邊框
    canvas.drawPath(path, borderPaint);

    // 畫填充
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
