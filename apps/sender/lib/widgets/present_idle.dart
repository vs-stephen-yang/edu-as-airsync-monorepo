
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/widgets/present_idle_button.dart';
import 'package:display_cast_flutter/widgets/title_bar.dart';
import 'package:display_cast_flutter/widgets/touch_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';
import 'custom_text_form_field.dart';

class PresentIdle extends StatelessWidget {
  PresentIdle({super.key});

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final codeKey = GlobalKey();
  final GlobalKey<CustomTextFormFieldState> otpKey = GlobalKey();
  final GlobalKey<PresentIdleButtonState> presentBtnKey = GlobalKey();
  final GlobalKey<TouchBackButtonState> touchBtnKey = GlobalKey();
  bool touchBackBtn = false;

  @override
  Widget build(BuildContext context) {
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context);
    bool presentBtnEnable = false;
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
          SizedBox(
            height: 66,
            child: CustomTextFormField(
              key: codeKey,
              controller: _codeController,
              // initialValue: displayCode,
              labelText: S.of(context).present_display_code,
              errorText: S.of(context).present_display_code_description,
              inputFormatter: [
                MaskedInputFormatter(
                  '000-000-000-0',
                  allowedCharMatcher: RegExp('[1-9]'),
                )
              ],
              onChanged: (text) {
                if (text.length >= 11 && _otpController.text.length == 4) {
                  presentBtnEnable = true;
                } else {
                  presentBtnEnable = false;
                }
                presentBtnKey.currentState?.setEnable(presentBtnEnable, displayCode: text, password: _otpController.text );
              },
            ),
          ),
          const Padding(padding: EdgeInsets.all(10)),
          SizedBox(
            height: 66,
            child: CustomTextFormField(
              key: otpKey,
              controller: _otpController,
              // initialValue: otp,
              labelText: S.of(context).present_otp_code,
              errorText: S.of(context).present_otp_code_description,
              inputFormatter: [
                MaskedInputFormatter(
                  '0000',
                  allowedCharMatcher: RegExp('[1-9]'),
                )
              ],
              isPassword: true,
              onChanged: (text) {
                if (_codeController.text.length >= 11 && text.length == 4) {
                  presentBtnEnable = true;
                } else {
                  presentBtnEnable = false;
                }
                presentBtnKey.currentState?.setEnable(presentBtnEnable, displayCode: _codeController.text, password: text );
              },
            ),
          ),
          const Padding(padding: EdgeInsets.all(10)),
          PresentIdleButton(key: presentBtnKey, onPressed: () async {
            await presentStateProvider.presentEnd(goIdleState: false);

            var displayCode = _codeController.text.replaceAll('-', '');
            int moderator = await presentStateProvider.checkModeratorOTP(
                displayCode: displayCode, otp: _otpController.text);
            if (moderator > 204 ||
                presentStateProvider.state == ViewState.moderatorIdle) {
              switch (moderator) {
                case 403:
                // 403 -> Reach maximum presenters
                  otpKey.currentState
                      ?.setErrorMsg('Reach maximum presenters');
                  break;
                case 404:
                // 404 -> sendToV1
                  await presentStateProvider.presentToV1(
                      displayCode: displayCode,
                      otp: _otpController.text,
                      callback: (result) async {
                        // handle UI
                        if (result == 'connect') {
                          // web: open a new window
                        } else if (result == 'denied') {
                          otpKey.currentState
                              ?.setErrorMsg('Invalid password');
                        } else if (result == 'blocked') {
                          otpKey.currentState?.setErrorMsg(
                              'Display host is connected by another client. Please try again later');
                        } else if (result == 'timeout') {
                          otpKey.currentState?.setErrorMsg(
                              'Your connection has been terminated because no stream was provided for more than 30 seconds. Please try to reconnect.');
                        }
                      });
                  break;
                case 406:
                // Display's moderator mode is on,  but the otp is wrong
                // 406 -> Invalid one time password
                  otpKey.currentState
                      ?.setErrorMsg('Invalid one time password');
                  break;
              }
              return;
            }

            bool display = await presentStateProvider.checkDisplayOTP(
                displayCode: displayCode, otp: _otpController.text);
            if (display) {
              presentStateProvider.presentTo(
                displayCode: displayCode,
                otp: _otpController.text,
              );
            }
          }),
          const Padding(
            padding: EdgeInsets.all(8.0),
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
            padding: EdgeInsets.all(8.0),
            child: Divider(color: Colors.white10),
          ),
        ],
      ),
    );
  }
}

