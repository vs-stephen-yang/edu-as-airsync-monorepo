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
    // PresentStateProvider presentStateProvider = Provider.of<PresentStateProvider>(context);
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
              displayCode = result.displayCode.replaceAll('-', '');
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
              print('zz presentBtnEnable $presentBtnEnable');
              if (!presentBtnEnable) return;
              await channelProvider.presentEnd(goIdleState: false);
              // await presentStateProvider.presentEnd(goIdleState: false);

              displayCode = displayCode.replaceAll('-', '');
              channelProvider.presentInternetMode(displayCode, password);
              // int moderator = await presentStateProvider.checkModeratorOTP(
              //     displayCode: displayCode, otp: password);
              // if (moderator > 204 ||
              //     presentStateProvider.state == ViewState.moderatorIdle) {
              //   switch (moderator) {
              //     case 403:
              //     // 403 -> Reach maximum presenters
              //       fieldKey.currentState?.setOtpErrorMsg(S.of(context).main_display_code_exceed);
              //       break;
              //     case 404:
              //     // 404 -> sendToV1
              //       await presentStateProvider.presentToV1(
              //           displayCode: displayCode,
              //           otp: password,
              //           callback: (result) async {
              //             // handle UI
              //             if (result == 'connect') {
              //               // web: open a new window
              //             } else if (result == 'denied') {
              //               fieldKey.currentState
              //                   ?.setOtpErrorMsg('Invalid password');
              //             } else if (result == 'blocked') {
              //               fieldKey.currentState?.setOtpErrorMsg(
              //                   'Display host is connected by another client. Please try again later');
              //             } else if (result == 'timeout') {
              //               fieldKey.currentState?.setOtpErrorMsg(
              //                   'Your connection has been terminated because no stream was provided for more than 30 seconds. Please try to reconnect.');
              //             }
              //           });
              //       break;
              //     case 406:
              //     // Display's moderator mode is on,  but the otp is wrong
              //     // 406 -> Invalid one time password
              //       fieldKey.currentState
              //           ?.setOtpErrorMsg(S.of(context).main_password_invalid);
              //       break;
              //   }
              //   return;
              // }
              //
              // bool display = await presentStateProvider.checkDisplayOTP(
              //     displayCode: displayCode, otp: password);
              // if (display) {
              //   DataDisplayCode.getInstance().save(displayCodeOriginal);
              //   presentStateProvider.presentTo(
              //     displayCode: displayCode,
              //     otp: password,
              //   );
              // }
            }),
          ),
        ],
      ),
    );
  }
}
