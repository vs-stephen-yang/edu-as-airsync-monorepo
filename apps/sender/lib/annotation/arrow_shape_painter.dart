import 'package:flutter/material.dart';

class ArrowShape extends StatelessWidget {
  const ArrowShape({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15),
      child: CustomPaint(
        painter: ArrowShapePainter(),
        child: child,
      ),
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

    final path = Path();

    // 開始繪製路徑
    path.moveTo(size.width * 0.3, 0); // 起點（左上角帶有偏移）

    path.lineTo(size.width * 0.7, 0); // 繪製到右上角
    path.quadraticBezierTo(size.width, 0, size.width, size.height * 0.1); // 繪製右上角圓角
    path.lineTo(size.width, size.height * 0.9); // 繪製到右下角
    path.quadraticBezierTo(size.width, size.height, size.width * 0.7, size.height); // 繪製右下角圓角
    path.lineTo(size.width * 0.3, size.height); // 繪製到底部左側
    path.quadraticBezierTo(0, size.height, 0, size.height * 0.9); // 繪製左下角圓角
    path.lineTo(0, size.height * 0.5 + 10); // 繪製到箭頭下半部分
    path.lineTo(-10, size.height * 0.5); // 繪製箭頭的尖端
    path.lineTo(0, size.height * 0.5 - 10); // 繪製箭頭的上半部分
    path.lineTo(0, size.height * 0.1); // 繼續向上繪製到左上角
    path.quadraticBezierTo(0, 0, size.width * 0.3, 0); // 繪製左上角圓角

    path.close(); // 完成路徑

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