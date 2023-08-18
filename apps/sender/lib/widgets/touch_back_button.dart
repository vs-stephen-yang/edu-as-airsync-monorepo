import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class TouchBackButton extends StatefulWidget {
  const TouchBackButton({Key? key, required this.onPressed, required this.initialValue}) : super(key: key);

  final ValueChanged<bool> onPressed;
  final bool initialValue;

  @override
  State<TouchBackButton> createState() => TouchBackButtonState();
}

class TouchBackButtonState extends State<TouchBackButton> {
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    isButtonEnabled = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return
      IconButton(
        icon: Image(
          image: isButtonEnabled? const Svg(
              'assets/images/ic_activate_on.svg') : const Svg(
              'assets/images/ic_activate_off.svg'),),
        splashRadius: 20,
        focusColor: Colors.grey,
        onPressed: () {
          isButtonEnabled = !isButtonEnabled;
          widget.onPressed(isButtonEnabled);
          setState(() {});
        },
      );
  }
}