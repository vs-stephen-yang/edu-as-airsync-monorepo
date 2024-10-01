import 'dart:io';

import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/widgets/present_idle_text_field.dart';
import 'package:display_cast_flutter/widgets/v3_custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';

class V3PresentIdleTextField extends StatefulWidget {
  const V3PresentIdleTextField(
      {super.key,
      required this.widthTextField,
      required this.onFieldChanged,
      required this.onPasswordEnterEvent});

  final double widthTextField;
  final ValueChanged<FieldResult> onFieldChanged;
  final ValueChanged<String> onPasswordEnterEvent;

  @override
  V3PresentIdleTextFieldState createState() => V3PresentIdleTextFieldState();
}

class V3PresentIdleTextFieldState extends State<V3PresentIdleTextField> {
  int displayCodeMinLength = 8;
  int displayCodeMaxLength = 11;
  int otpLength = 4;

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  final GlobalKey codeKey = GlobalKey();
  final GlobalKey otpKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isOverlayVisible = false;

  bool _isCodeSelectedFromHistory = false;

  @override
  void initState() {
    super.initState();

    _codeFocusNode.addListener(() {
      if (_codeFocusNode.hasFocus) {
        _codeController.selection = TextSelection(
            baseOffset: 0, extentOffset: _codeController.text.length);
      }
    });
    _otpFocusNode.addListener(() {
      if (_otpFocusNode.hasFocus) {
        _otpController.selection = TextSelection(
            baseOffset: 0, extentOffset: _otpController.text.length);
        //TODO:
        // User use "TAB" key to move to OTP input text field,
        // remove display code overlay
        // if (_isOverlayVisible) {
        //   _isOverlayVisible = false;
        //   _overlayEntry?.remove();
        // }
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _otpController.dispose();
    _codeFocusNode.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.widthTextField,
      child: Column(
        children: [
          V3CustomTextFormField(
            key: codeKey,
            controller: _codeController,
            focusNode: _codeFocusNode,
            hintText: S.of(context).main_display_code,
            // TODO:
            // errorText: S.of(context).main_display_code_description,
            maxTextLength: displayCodeMaxLength,
            inputFormatter: [
              if (!Platform.isWindows) UpperCaseTextFormatter(),
              if (!Platform.isWindows)
                MaskedInputFormatter(
                  '###########',
                  allowedCharMatcher: RegExp('[A-Za-z0-9]'),
                ),
            ],
            onFieldChanged: (text) {
              if (Platform.isWindows) {
                if (text.contains(RegExp(r'[^a-zA-Z0-9]'))) {
                  // TODO:
                  // setCodeErrorMsg(S.of(context).main_display_code_error);
                  // _isOverlayVisible = false;
                  // if (_overlayEntry != null && _overlayEntry!.mounted) _overlayEntry?.remove();
                  // return;
                }
                _codeController.value = _codeController.value.copyWith(
                  text: text.toUpperCase(),
                  selection: TextSelection.collapsed(offset: text.length),
                  composing: TextRange.empty,
                );
              }

              _isCodeSelectedFromHistory = false;
              // TODO:
              // setCodeDescriptionMsg(S.of(context).main_display_code_description);
              bool presentBtnEnable = false;
              if (text.length >= displayCodeMinLength &&
                  _otpController.text.length == otpLength) {
                presentBtnEnable = true;
              }
              widget.onFieldChanged(FieldResult(
                  enable: presentBtnEnable,
                  isDisplayCodeSelectedFromHistory: _isCodeSelectedFromHistory,
                  displayCode: text,
                  password: _otpController.text));
            },
            onTap: () async {
              // TODO:
              // List? displayList = await DataDisplayCode.getInstance().load();
              // if (!_isOverlayVisible && displayList != null) {
              //   _isOverlayVisible = true;
              //   _createOverlayEntry(displayList.reversed.toList());
              // }
            },
            onFieldSubmitted: (text) {
              _otpFocusNode.requestFocus();
            },
          ),
          const SizedBox(height: 20),
          V3CustomTextFormField(
            key: otpKey,
            controller: _otpController,
            focusNode: _otpFocusNode,
            hintText: S.of(context).main_password,
            // TODO:
            // errorText: S.of(context).main_password_description,
            maxTextLength: otpLength,
            inputFormatter: [
              if (!Platform.isWindows)
                MaskedInputFormatter(
                  '0000',
                  allowedCharMatcher: RegExp('[0-9]'),
                ),
            ],
            onFieldChanged: (text) {
              if (Platform.isWindows) {
                if (text.contains(RegExp(r'[^0-9]'))) {
                  // TODO:
                  // setOtpErrorMsg(S.of(context).main_otp_error);
                  // return;
                }
              }
              // TODO:
              // setOtpDescriptionMsg(S.of(context).main_password_description);
              bool presentBtnEnable = false;
              if (_codeController.text.length >= displayCodeMinLength &&
                  text.length == otpLength) {
                presentBtnEnable = true;
              }
              widget.onFieldChanged(FieldResult(
                  enable: presentBtnEnable,
                  isDisplayCodeSelectedFromHistory: _isCodeSelectedFromHistory,
                  displayCode: _codeController.text,
                  password: text));
            },
            onFieldSubmitted: (text) {
              widget.onPasswordEnterEvent(text);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
