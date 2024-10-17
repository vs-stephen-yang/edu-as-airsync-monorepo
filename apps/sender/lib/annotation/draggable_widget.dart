import 'package:flutter/cupertino.dart';

class DraggableWidget extends StatefulWidget {
  const DraggableWidget({super.key, required this.child, required this.onChanged});
  final Widget child;
  final VoidCallback? onChanged;

  @override
  DraggableWidgetState createState() => DraggableWidgetState();
}

class DraggableWidgetState extends State<DraggableWidget> {

  double _xPosition = 0;
  double _yPosition = 0;

  double _initialX = 0.0;
  double _initialY = 0.0;

  double _initialImageX = 0.0;
  double _initialImageY = 0.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _xPosition,
      top: _yPosition,
      child: GestureDetector(
        onPanStart: (details) {
          _initialX = details.globalPosition.dx;
          _initialY = details.globalPosition.dy;
          _initialImageX = _xPosition;
          _initialImageY = _yPosition;
        },
        onPanUpdate: (details) {
          // setState(() {
            _xPosition = _initialImageX + (details.globalPosition.dx - _initialX);
            _yPosition = _initialImageY + (details.globalPosition.dy - _initialY);
          // });
          widget.onChanged?.call();
        },
        child: widget.child,
      ),
    );
  }
}