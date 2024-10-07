import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:flutter/material.dart';

import 'custom_icons_icons.dart';

class V3PresentIdleButton extends StatefulWidget {
  const V3PresentIdleButton({
    super.key,
    this.fixedSize,
    required this.buttonText,
    required this.onPressed,
  });

  final VoidCallback? onPressed;
  final Size? fixedSize;
  final String buttonText;

  @override
  State<V3PresentIdleButton> createState() => V3PresentIdleButtonState();
}

class V3PresentIdleButtonState extends State<V3PresentIdleButton>
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
    setState(() {
      // update the button state
      isButtonEnabled = presentBtnEnable;
    });
  }

  void setLoadingState(bool loading) {
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
        disabledBackgroundColor: context.tokens.color.vsdswColorDisabled,
        backgroundColor: context.tokens.color.vsdswColorPrimary,
        fixedSize: widget.fixedSize,
        shape: RoundedRectangleBorder(
          borderRadius: context.tokens.radii.vsdswRadiusFull,
        ),
        shadowColor: Colors.grey,
        elevation: 8,
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
              widget.buttonText,
              style: TextStyle(
                color: context.tokens.color.vsdswColorOnDisabled,
                fontSize: AppConstants.fontSizeNormal,
              ),
            ),
    );
  }
}
