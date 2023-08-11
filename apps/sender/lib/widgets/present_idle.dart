import 'dart:async';

import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/widgets/title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';
import 'custom_text_form_field.dart';
import 'focus_icon_button.dart';

class PresentIdle extends StatefulWidget {
  PresentIdle({super.key, this.displayCode, this.otp}) {
    _codeController = TextEditingController(text: displayCode);
    _otpController = TextEditingController(text: otp);
  }

  late final TextEditingController _codeController;
  late final TextEditingController _otpController;
  final String? displayCode;
  final String? otp;

  @override
  State<PresentIdle> createState() => _PresentIdleState();
}

class _PresentIdleState extends State<PresentIdle> {
  final codeKey = GlobalKey();
  final GlobalKey<CustomTextFormFieldState> otpKey = GlobalKey();
  final presentBtnKey = GlobalKey();
  bool presentBtnEnable = false;

  @override
  Widget build(BuildContext context) {
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context);
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
              controller: widget._codeController,
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
                if (text.length > 8 && widget._otpController.text.length == 4) {
                  presentBtnEnable = true;
                } else {
                  presentBtnEnable = false;
                }
                setState(() {});
              },
            ),
          ),
          const Padding(padding: EdgeInsets.all(10)),
          SizedBox(
            height: 66,
            child: CustomTextFormField(
              key: otpKey,
              controller: widget._otpController,
              // initialValue: otp,
              labelText: S.of(context).present_otp_code,
              errorText: S.of(context).present_otp_code_description,
              inputFormatter: [
                MaskedInputFormatter(
                  '0000',
                  allowedCharMatcher: RegExp('[1-9]'),
                )
              ],
              onChanged: (text) {
                if (widget._codeController.text.length > 8 && text.length == 4) {
                  presentBtnEnable = true;
                } else {
                  presentBtnEnable = false;
                }
                setState(() {});
              },
            ),
          ),
          const Padding(padding: EdgeInsets.all(10)),
          ElevatedButton(
            onPressed: () async {
              if (widget._codeController.text.isEmpty) {
                _showOverlayMessage(context, codeKey);
              } else if (widget._otpController.text.isEmpty) {
                _showOverlayMessage(context, otpKey);
              } else {
                var displayCode = widget._codeController.text.replaceAll('-', '');
                int moderator = await presentStateProvider.checkModeratorOTP(
                    displayCode: displayCode,
                    otp: widget._otpController.text);
                if (moderator > 204 || presentStateProvider.state == ViewState.moderatorIdle) {
                  switch (moderator) {
                    case 403:
                    // 403 -> Reach maximum presenters
                      otpKey.currentState?.setErrorMsg('Reach maximum presenters');
                      break;
                    case 404:
                    // 404 -> sendToV1
                      await presentStateProvider.presentToV1(displayCode: displayCode, otp: widget._otpController.text, callback: (result) async {
                        // handle UI
                        if (result == 'connect') {
                          // web: open a new window
                        } else if (result == 'denied') {
                          otpKey.currentState?.setErrorMsg('Invalid password');
                        } else if (result == 'blocked') {
                          otpKey.currentState?.setErrorMsg('Display host is connected by another client. Please try again later');
                        } else if (result == 'timeout') {
                          otpKey.currentState?.setErrorMsg('Your connection has been terminated because no stream was provided for more than 30 seconds. Please try to reconnect.');
                        }
                      });
                      break;
                    case 406:
                    // Display's moderator mode is on,  but the otp is wrong
                    // 406 -> Invalid one time password
                      otpKey.currentState?.setErrorMsg('Invalid one time password');
                      break;
                  }
                  return;
                }

                bool display = await presentStateProvider.checkDisplayOTP(
                    displayCode: displayCode,
                    otp: widget._otpController.text);
                if (display) {
                  presentStateProvider.presentTo(
                    displayCode: displayCode,
                    otp: widget._otpController.text,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: presentBtnEnable? const Color.fromARGB(255, 41, 121, 255) : const Color.fromARGB(128, 242, 242, 242),
              fixedSize: const Size(300, 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: Text(
              S.of(context).present_start,
              style: TextStyle(
                color: presentBtnEnable? Colors.white : const Color.fromARGB(255, 153, 153, 153),
                fontSize: 14,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Divider(color: Colors.white10),
          ),
          InkWell(
            onTap: () {
              // TODO: TOUCH BACK
            },
            child: Row(
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
                    child: FocusIconButton(
                      childNotFocus: const Image(
                        image: Svg(
                            'assets/images/ic_activate_off.svg'), // assets/images/ic_activate_off.svg
                      ),
                      splashRadius: 20,
                      focusColor: Colors.grey,
                      onClick: () {},
                    ),
                  ),
                )
              ],
            ),
          ),
          InkWell(
            onTap: () {
              presentStateProvider.setViewState(ViewState.settings);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
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

  void _showOverlayMessage(BuildContext context, GlobalKey widgetKey) {
    const overlayWidth = 200.0;
    const overlayHeight = 30.0;
    RenderBox renderBox =
        widgetKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);

    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        left: position.dx + (renderBox.size.width - overlayWidth) / 2,
        top: position.dy + (renderBox.size.height - overlayHeight) / 2,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Material(
            child: Container(
              alignment: Alignment.center,
              color: Colors.white,
              width: overlayWidth,
              height: overlayHeight,
              child: Row(
                children: [
                  const Icon(
                    Icons.info,
                    color: Colors.amber,
                  ),
                  Text(
                    S.of(context).present_fill_out,
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });

    Overlay.of(context).insert(overlayEntry);

    Timer(const Duration(seconds: 5), () {
      overlayEntry.remove();
    });
  }
}

