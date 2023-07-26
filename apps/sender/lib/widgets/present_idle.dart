import 'dart:async';

import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:provider/provider.dart';
import 'custom_text_form_field.dart';

class PresentIdle extends StatelessWidget {
  PresentIdle({super.key, this.displayCode, this.otp}) {
    _codeController = TextEditingController(text: displayCode);
    _otpController = TextEditingController(text: otp);
  }

  late final TextEditingController _codeController;
  late final TextEditingController _otpController;
  final codeKey = GlobalKey();
  GlobalKey<CustomTextFormFieldState> otpKey = GlobalKey();

  final String? displayCode;
  final String? otp;

  @override
  Widget build(BuildContext context) {
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context);
    print('zz p ${presentStateProvider.moderator?.id}');
    return Container(
      width: 400,
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextFormField(
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
          ),
          const Padding(padding: EdgeInsets.all(10)),
          CustomTextFormField(
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
          ),
          const Padding(padding: EdgeInsets.all(10)),
          ElevatedButton(
            onPressed: () async {
              if (_codeController.text.isEmpty) {
                _showOverlayMessage(context, codeKey);
              } else if (_otpController.text.isEmpty) {
                _showOverlayMessage(context, otpKey);
              } else {
                var displayCode = _codeController.text.replaceAll('-', '');
                int moderator = await presentStateProvider.checkModeratorOTP(
                    displayCode: displayCode,
                    otp: _otpController.text);
                if (moderator > 204 || presentStateProvider.state == ViewState.moderatorIdle) {
                  switch (moderator) {
                    case 403:
                    // 403 -> Reach maximum presenters
                      otpKey.currentState?.setErrorMsg('Reach maximum presenters');
                      break;
                    case 404:
                    // 404 -> sendToV1
                      await presentStateProvider.presentToV1(displayCode: displayCode, otp: _otpController.text, callback: (result) async {
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
                    otp: _otpController.text);
                if (display) {
                  presentStateProvider.presentTo(
                    displayCode: displayCode,
                    otp: _otpController.text,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              side: const BorderSide(
                width: 1.0,
                color: Colors.blue,
              ),
            ),
            child: Text(
              S.of(context).present_start,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 14,
              ),
            ),
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

