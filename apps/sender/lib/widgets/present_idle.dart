import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/widgets/present_idle_button.dart';
import 'package:display_cast_flutter/widgets/present_idle_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';

class PresentIdle extends StatelessWidget {
  PresentIdle({super.key});

  final GlobalKey<PresentIdleTextFieldState> fieldKey = GlobalKey();
  final GlobalKey<PresentIdleButtonState> presentBtnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    bool presentBtnEnable = false;
    String displayCode = '', password = '';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
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
              presentBtnKey.currentState?.onButtonPressed();
            }
          },
        ),
        PresentIdleButton(
          key: presentBtnKey,
          onPressed: () async {
            if (!presentBtnEnable) return;
            await channelProvider.presentEnd(goIdleState: false);

            channelProvider.startConnect(
              formattedDisplayCode: displayCode,
              otp: password,
            );
          },
        ),
        const SizedBox(
          height: 20,
        ),
        InkWell(
          onTap: () {
            channelProvider.presentSettingPage();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 5),
                child: const Icon(
                  Icons.settings,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              Text(
                S.of(context).main_setting,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppConstants.fontSize_normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
