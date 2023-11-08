import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';

class PresentIdleButton extends StatefulWidget {
  const PresentIdleButton({Key? key, required this.onPressed}) : super(key: key);

  final VoidCallback? onPressed;

  @override
  State<PresentIdleButton> createState() => PresentIdleButtonState();
}

class PresentIdleButtonState extends State<PresentIdleButton> {
  bool isButtonEnabled = false;

  void setEnable(bool presentBtnEnable, {String? displayCode, String? password}) {
    setState(() {
      // update the button state
      isButtonEnabled = presentBtnEnable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isButtonEnabled ? widget.onPressed : null,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: const Color.fromARGB(255, 215, 229, 253),
        backgroundColor: const Color.fromARGB(255, 41, 121, 255), // isButtonEnabled?
        fixedSize: const Size(250, 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: Text(
        S.of(context).main_present,
        style: const TextStyle(
          color: Colors.white, //isButtonEnabled? Colors.white : const Color.fromARGB(255, 153, 153, 153),
          fontSize: 14,
        ),
      ),
    );
  }
}