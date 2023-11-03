import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';

class PresentIdleButton extends StatefulWidget {
  const PresentIdleButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  State<PresentIdleButton> createState() => PresentIdleButtonState();
}

class PresentIdleButtonState extends State<PresentIdleButton> {
  bool isButtonEnabled = false;

  void setEnable(bool presentBtnEnable,
      {String? displayCode, String? password}) {
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
        disabledBackgroundColor: const Color.fromARGB(128, 242, 242, 242),
        // isButtonEnabled?
        backgroundColor: const Color.fromARGB(255, 41, 121, 255),
        fixedSize: const Size(300, 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: Text(
        S.of(context).main_present,
        style: TextStyle(
          color: isButtonEnabled
              ? Colors.white
              : const Color.fromARGB(255, 153, 153, 153),
          fontSize: 14,
        ),
      ),
    );
  }
}
