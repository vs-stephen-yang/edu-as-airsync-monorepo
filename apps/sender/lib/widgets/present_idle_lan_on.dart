
import 'package:display_cast_flutter/utilities/app_colors.dart';
import 'package:display_cast_flutter/widgets/present_idle_button.dart';
import 'package:display_cast_flutter/widgets/present_idle_pin_text.dart';
import 'package:display_cast_flutter/widgets/present_idle_textfield.dart';
import 'package:display_cast_flutter/widgets/touch_back_button.dart';
import 'package:flutter/material.dart';

class PresentIdleLanOn extends StatelessWidget {
  PresentIdleLanOn({super.key});

  final GlobalKey<PresentIdleTextFieldState> fieldKey = GlobalKey();
  final GlobalKey<PresentIdleButtonState> presentBtnKey = GlobalKey();
  final GlobalKey<TouchBackButtonState> touchBtnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    bool presentBtnEnable = false;

    return Container(
      width: 300,
      height: 360,
      decoration: BoxDecoration(
        color: AppColors.presentIdleOnBackground,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(25.0),
            child: Row(
              children: [
                Icon(Icons.lan_outlined, size: 23, color: Color.fromRGBO(77, 77, 77, 1),),
                Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Text(
                    'LAN mode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.presentIdleOnTitle,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PresentIdlePinText(
            key: fieldKey,
            onFieldChanged: (result) {
              presentBtnEnable = result.enable;
              presentBtnKey.currentState
                  ?.setEnable(result.enable, displayCode: result.displayCode);
            },
            onPasswordEnterEvent: (text) {
              if (presentBtnEnable) {
                presentBtnKey.currentState?.widget.onPressed!();
              }
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: PresentIdleButton(key: presentBtnKey, onPressed: () async {}),
          ),
        ],
      ),
    );
  }


}
