import 'dart:async';

import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:provider/provider.dart';

class PresentIdle extends StatelessWidget {
  PresentIdle({super.key});

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final codeKey = GlobalKey();
  final otpKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context);
    return Container(
      width: 400,
      height: 280,
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextFormField(
            key: codeKey,
            controller: _codeController,
            labelText: S.of(context).present_display_code,
            errorText: S.of(context).present_display_code_description,
            inputFormatter: [
              MaskedInputFormatter(
                '000-000-000-0',
                allowedCharMatcher: RegExp('[1-9]'),
              )
            ],
          ),
          CustomTextFormField(
            key: otpKey,
            controller: _otpController,
            labelText: S.of(context).present_otp_code,
            errorText: S.of(context).present_otp_code_description,
            inputFormatter: [
              MaskedInputFormatter(
                '0000',
                allowedCharMatcher: RegExp('[1-9]'),
              )
            ],
          ),
          ElevatedButton(
            onPressed: () {
              if (_codeController.text.isEmpty) {
                _showOverlayMessage(context, codeKey);
              } else if (_otpController.text.isEmpty) {
                _showOverlayMessage(context, otpKey);
              } else {
                presentStateProvider.presentTo(
                  displayCode: _codeController.text,
                  otp: _otpController.text,
                );
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

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField(
      {this.controller,
      this.labelText,
      this.errorText,
      this.inputFormatter,
      super.key});

  final TextEditingController? controller;
  final String? labelText;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatter;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyleBlue = const TextStyle(color: Colors.blue);
    TextStyle textStyleGrey = const TextStyle(color: Colors.grey);
    TextStyle textStyleWhite = const TextStyle(color: Colors.white);
    OutlineInputBorder outlineInputBorderBlue = const OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: Colors.blue),
    );
    OutlineInputBorder outlineInputBorderGrey = const OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: Colors.grey),
    );
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: textStyleGrey,
        floatingLabelStyle:
            MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
          return states.contains(MaterialState.focused)
              ? textStyleBlue
              : textStyleGrey;
        }),
        errorText: errorText,
        errorStyle: textStyleGrey,
        border: outlineInputBorderBlue,
        enabledBorder: outlineInputBorderGrey,
        errorBorder: outlineInputBorderGrey,
        focusedErrorBorder: outlineInputBorderBlue,
      ),
      style: textStyleWhite,
      inputFormatters: inputFormatter,
      // onChanged: (_) {},
    );
  }
}
