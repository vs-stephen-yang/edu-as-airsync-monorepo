
import 'package:flutter/material.dart';

import 'color_box.dart';

class ColorBar extends StatefulWidget {
  const ColorBar({
    super.key,
    required this.callback,
    this.penColor,
    this.spacing = 25,
    this.size = 24,
  });

  final ColorSelectCallback callback;
  final Color? penColor;
  final double spacing;
  final double size;

  @override
  State<ColorBar> createState() => _ColorBarState();
}

class _ColorBarState extends State<ColorBar> {
  Color penColor = Colors.red;

  @override
  void initState() {
    penColor = widget.penColor ?? Colors.red;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ColorBoxGroup(
      width: widget.size,
      height: widget.size,
      spacing: widget.spacing,
      selectedBorderWidth: 2,
      selectedBorderColor: Colors.white,
      groupValue: penColor,
      colors: const [
        Colors.red,
        Colors.blue,
        Colors.yellow,
        Colors.black,
        Colors.white,
      ],
      onTap: (color){
        setState(() {
          penColor = color;
          widget.callback.call(color);
        });
      },
    );
  }
}