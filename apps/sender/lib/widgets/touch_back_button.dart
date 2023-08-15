import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class TouchBackButton extends StatefulWidget {
  const TouchBackButton({Key? key, required this.onPressed}) : super(key: key);

  final VoidCallback? onPressed;

  @override
  State<TouchBackButton> createState() => TouchBackButtonState();
}

class TouchBackButtonState extends State<TouchBackButton> {
  bool isButtonEnabled = false;

  void setEnable(bool touchBtnEnable) {
    setState(() {
      // update the button state
      isButtonEnabled = touchBtnEnable;
    });
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
        onPressed: widget.onPressed,
      );
  }
}