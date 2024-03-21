import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';

class TouchBackButton extends StatefulWidget {
  const TouchBackButton(
      {super.key, required this.onPressed, required this.initialValue});

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
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 38.0, top: 8.0),
        child: Row(
          children: [
            const SizedBox(
              width: 26,
              child: Image(
                height: 20,
                image: Svg('assets/images/touch_app_black.svg'),
              ),
            ),
            const Padding(padding: EdgeInsets.only(left: 8)),
            Text(
              S.of(context).main_touch_back,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppConstants.fontSize_normal,
              ),
            ),
            IconButton(
              icon: Image(
                image: isButtonEnabled
                    ? const Svg('assets/images/ic_activate_on.svg')
                    : const Svg('assets/images/ic_activate_off.svg'),
              ),
              splashRadius: 20,
              focusColor: Colors.grey,
              onPressed: () {
                isButtonEnabled = !isButtonEnabled;
                widget.onPressed(isButtonEnabled);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
