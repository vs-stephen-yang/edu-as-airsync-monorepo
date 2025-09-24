import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:flutter/material.dart';

import 'custom_icons_icons.dart';

class PresentIdleButton extends StatefulWidget {
  const PresentIdleButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  State<PresentIdleButton> createState() => PresentIdleButtonState();
}

class PresentIdleButtonState extends State<PresentIdleButton>
    with TickerProviderStateMixin {
  bool isButtonEnabled = false;
  bool isButtonLoading = false;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: false);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void setEnable(bool presentBtnEnable,
      {String? displayCode, String? password}) {
    if (!mounted) return;
    setState(() {
      // update the button state
      isButtonEnabled = presentBtnEnable;
    });
  }

  void setLoadingState(bool loading) {
    if (!mounted) return;
    setState(() {
      isButtonLoading = loading;
    });
  }

  onButtonPressed() {
    if (!isButtonLoading) {
      setLoadingState(true);
      widget.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isButtonEnabled ? onButtonPressed : null,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: const Color.fromARGB(255, 215, 229, 253),
        backgroundColor: const Color.fromARGB(255, 41, 121, 255),
        // isButtonEnabled?
        fixedSize: const Size(300, 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: isButtonLoading
          ? RotationTransition(
              turns: _animation,
              child: const Icon(
                CustomIcons.loading,
                color: Colors.white,
              ),
            )
          : Text(
              S.of(context).main_present,
              style: const TextStyle(
                color: Colors.white,
                //isButtonEnabled? Colors.white : const Color.fromARGB(255, 153, 153, 153),
                fontSize: AppConstants.fontSizeNormal,
              ),
            ),
    );
  }
}
