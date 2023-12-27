import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/app_colors.dart';
import 'package:display_cast_flutter/widgets/present_idle_button.dart';
import 'package:display_cast_flutter/widgets/present_idle_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PresentIdleNetOn extends StatelessWidget {
  PresentIdleNetOn({super.key});

  final GlobalKey<PresentIdleTextFieldState> fieldKey = GlobalKey();
  final GlobalKey<PresentIdleButtonState> presentBtnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {

    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);

    bool presentBtnEnable = false;
    String displayCode = '', password = '';

    return Container(
      width: 300,
      height: 360,
      decoration: BoxDecoration(
        color: AppColors.presentIdleOnBackground,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/ic_net_on.png',
                  height: 23,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Text(
                    'Internet mode',
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
          PresentIdleTextField(
            key: fieldKey,
            onFieldChanged: (result) {
              presentBtnEnable = result.enable;
              displayCode = result.displayCode;
              password = result.password;
              presentBtnKey.currentState?.setEnable(result.enable,
                  displayCode: result.displayCode, password: result.password);
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
            child: PresentIdleButton(key: presentBtnKey, onPressed: () async {
              if (!presentBtnEnable) return;
              await channelProvider.presentEnd(goIdleState: false);

              channelProvider.presentInternetMode(displayCode, password);
            }),
          ),
        ],
      ),
    );
  }
}
