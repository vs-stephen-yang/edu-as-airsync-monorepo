import 'dart:io';

import 'package:flutter/cupertino.dart';

class DraggableWidget extends StatefulWidget {
  const DraggableWidget(
      {super.key,
      required this.child,
      this.onMoveEnd,
      this.position = Offset.zero,
      this.onMoveStart});

  final Widget child;
  final Function(Offset offset)? onMoveEnd;
  final VoidCallback? onMoveStart;
  final Offset position;

  @override
  DraggableWidgetState createState() => DraggableWidgetState();
}

class DraggableWidgetState extends State<DraggableWidget> {
  final GlobalKey childKey = GlobalKey();
  double _xPosition = 0;
  double _yPosition = 0;

  double _initialX = 0.0;
  double _initialY = 0.0;

  double _initialChildX = 0.0;
  double _initialChildY = 0.0;
  Size screenSize = Size.zero;

  @override
  void initState() {
    _xPosition = widget.position.dx;
    _yPosition = widget.position.dy;
    screenSize = WidgetsBinding
            .instance.platformDispatcher.views.first.physicalSize /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
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
      left: _xPosition,
      top: _yPosition,
      child: GestureDetector(
        key: childKey,
        onPanStart: (details) {
          _initialX = details.globalPosition.dx;
          _initialY = details.globalPosition.dy;
          _initialChildX = _xPosition;
          _initialChildY = _yPosition;
          widget.onMoveStart?.call();
        },
        onPanUpdate: (details) {
          if (!mounted) return;
          setState(() {
            _xPosition =
                _initialChildX + (details.globalPosition.dx - _initialX);
            _yPosition =
                _initialChildY + (details.globalPosition.dy - _initialY);
            checkPosition();
          });
        },
        onPanEnd: (details) {
          widget.onMoveEnd?.call(Offset(_xPosition, _yPosition));
        },
        child: widget.child,
      ),
    );
  }

  checkPosition() {
    final size = getChildSize();
    if (_yPosition < 0) {
      _yPosition = 0;
    } else if (_yPosition + size.height > screenSize.height) {
      _yPosition = screenSize.height - size.height;
    }
    if (_xPosition < 0) {
      _xPosition = 0;
    } else if (_xPosition + size.width > screenSize.width) {
      _xPosition = screenSize.width - size.width;
    }
  }

  Size getChildSize() {
    final RenderBox renderBox =
        childKey.currentContext?.findRenderObject() as RenderBox;
    return renderBox.size;
  }
}
