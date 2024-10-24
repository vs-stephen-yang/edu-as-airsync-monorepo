import 'dart:io';

import 'package:flutter/cupertino.dart';

class DraggableWidget extends StatefulWidget {
  const DraggableWidget({super.key, required this.child, this.onMoveEnd, this.position = Offset.zero, this.onMoveStart});
  final Widget child;
  final Function(Offset offset)? onMoveEnd;
  final VoidCallback? onMoveStart;
  final Offset position;

  @override
  DraggableWidgetState createState() => DraggableWidgetState();
}

class DraggableWidgetState extends State<DraggableWidget> {

  double _xPosition = 0;
  double _yPosition = 0;

  double _initialX = 0.0;
  double _initialY = 0.0;

  double _initialChildX = 0.0;
  double _initialChildY = 0.0;

  @override
  void initState() {
    _xPosition = widget.position.dx;
    _yPosition = widget.position.dy;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DraggableWidget oldWidget) {
    if (Platform.isAndroid && widget.position.dy != _yPosition) {
      _xPosition = widget.position.dx;
      _yPosition = widget.position.dy;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: Platform.isAndroid ? 0 : _xPosition,
      top: _yPosition,
      child: GestureDetector(
        onPanStart: (details) {
          _initialX = details.globalPosition.dx;
          _initialY = details.globalPosition.dy;
          _initialChildX = _xPosition;
          _initialChildY = _yPosition;
          widget.onMoveStart?.call();
        },
        onPanUpdate: (details) {
          setState(() {
            _xPosition = _initialChildX + (details.globalPosition.dx - _initialX);
            _yPosition = _initialChildY + (details.globalPosition.dy - _initialY);
          });
        },
        onPanEnd: (details){
          widget.onMoveEnd?.call(Offset(_xPosition, _yPosition));
        },
        child: widget.child,
      ),
    );
  }
}