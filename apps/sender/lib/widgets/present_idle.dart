
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/widgets/present_idle_button.dart';
import 'package:display_cast_flutter/widgets/present_idle_textfield.dart';
import 'package:display_cast_flutter/widgets/title_bar.dart';
import 'package:display_cast_flutter/widgets/touch_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class PresentIdle extends StatelessWidget {
  PresentIdle({super.key});

  final GlobalKey<PresentIdleTextFieldState> fieldKey = GlobalKey();
  final GlobalKey<PresentIdleButtonState> presentBtnKey = GlobalKey();
  final GlobalKey<TouchBackButtonState> touchBtnKey = GlobalKey();
  bool touchBackBtn = false;

  @override
  Widget build(BuildContext context) {
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context);
    bool presentBtnEnable = false;
    String displayCode = '', password ='';
    return SizedBox(
      width: 300,
      height: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TitleBar(),
          const Padding(
            padding: EdgeInsets.only(top: 20),
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
          PresentIdleButton(key: presentBtnKey, onPressed: () async {
            await presentStateProvider.presentEnd(goIdleState: false);

            displayCode = displayCode.replaceAll('-', '');
            int moderator = await presentStateProvider.checkModeratorOTP(
                displayCode: displayCode, otp: password);
            if (moderator > 204 ||
                presentStateProvider.state == ViewState.moderatorIdle) {
              switch (moderator) {
                case 403:
                // 403 -> Reach maximum presenters
                  fieldKey.currentState?.setOtpErrorMsg('Reach maximum presenters');
                  break;
                case 404:
                // 404 -> sendToV1
                  await presentStateProvider.presentToV1(
                      displayCode: displayCode,
                      otp: password,
                      callback: (result) async {
                        // handle UI
                        if (result == 'connect') {
                          // web: open a new window
                        } else if (result == 'denied') {
                          fieldKey.currentState
                              ?.setOtpErrorMsg('Invalid password');
                        } else if (result == 'blocked') {
                          fieldKey.currentState?.setOtpErrorMsg(
                              'Display host is connected by another client. Please try again later');
                        } else if (result == 'timeout') {
                          fieldKey.currentState?.setOtpErrorMsg(
                              'Your connection has been terminated because no stream was provided for more than 30 seconds. Please try to reconnect.');
                        }
                      });
                  break;
                case 406:
                // Display's moderator mode is on,  but the otp is wrong
                // 406 -> Invalid one time password
                  fieldKey.currentState
                      ?.setOtpErrorMsg('Invalid one time password');
                  break;
              }
              return;
            }

            bool display = await presentStateProvider.checkDisplayOTP(
                displayCode: displayCode, otp: password);
            if (display) {
              presentStateProvider.presentTo(
                displayCode: displayCode,
                otp: password,
              );
            }
          }),
          const Padding(
            padding: EdgeInsets.only(top: 16), //EdgeInsets.all(8),
            child: Divider(color: Colors.white10),
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 5),
                  child: const Image(
                    height: 18,
                    image: Svg('assets/images/touch_app_black.svg'),
                  ),
                ),
              ),
              Text(
                S.of(context).touchback,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TouchBackButton(
                    key: touchBtnKey,
                    onPressed: () {
                      touchBackBtn = !touchBackBtn;
                      presentStateProvider.setTouchBack(touchBackBtn);
                      touchBtnKey.currentState?.setEnable(touchBackBtn);
                    },
                  ),
                ),
              )
            ],
          ),
          InkWell(
            onTap: () {
              presentStateProvider.setViewState(ViewState.settings);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 5),
                      child: const Icon(
                        Icons.settings,
                        size: 18,
                        color: Colors.white,
                      ),
                    )),
                Text(
                  S.of(context).setting,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const Expanded(flex: 1, child: SizedBox()),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Divider(color: Colors.white10),
          ),
        ],
      ),
    );
  }
}

