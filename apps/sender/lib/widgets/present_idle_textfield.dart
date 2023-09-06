
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:provider/provider.dart';

import 'custom_text_form_field.dart';

class PresentIdleTextField extends StatefulWidget {
  const PresentIdleTextField({super.key, required this.onFieldChanged, required this.onPasswordEnterEvent});

  final ValueChanged<FieldResult> onFieldChanged;
  final ValueChanged<String> onPasswordEnterEvent;

  @override
  State<StatefulWidget> createState() => PresentIdleTextFieldState();

}

class PresentIdleTextFieldState extends State<PresentIdleTextField> {

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  final GlobalKey<CustomTextFormFieldState> codeKey = GlobalKey();
  final GlobalKey<CustomTextFormFieldState> otpKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _codeFocusNode.addListener(() {
      if (_codeFocusNode.hasFocus) {
        _codeController.selection = TextSelection(baseOffset: 0, extentOffset: _codeController.text.length);
      }
    });
    _otpFocusNode.addListener(() {
      if (_otpFocusNode.hasFocus) {
        _otpController.selection = TextSelection(baseOffset: 0, extentOffset: _otpController.text.length);
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
    PresentStateProvider presentStateProvider = Provider.of<PresentStateProvider>(context);
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      if (presentStateProvider.exceedMaximumPresenters) {
        codeKey.currentState?.setErrorMsg(S.of(context).main_display_code_exceed);
      }
    });

    return Column(
      children: [
        SizedBox(
          height: 66,
          child: CustomTextFormField(
            key: codeKey,
            controller: _codeController,
            focusNode: _codeFocusNode,
            // initialValue: displayCode,
            labelText: S.of(context).main_display_code,
            errorText: S.of(context).main_display_code_description,
            inputFormatter: [
              MaskedInputFormatter(
                '000-000-000-0',
                allowedCharMatcher: RegExp('[1-9]'),
              )
            ],
            onChanged: (text) {
              bool presentBtnEnable = false;
              if (text.length >= 11 && _otpController.text.length == 4) {
                presentBtnEnable = true;
              }
              widget.onFieldChanged(FieldResult(enable: presentBtnEnable, displayCode: text, password: _otpController.text));
            },
            onFieldSubmitted: (text) {
              _otpFocusNode.requestFocus();
            },
          ),
        ),
        const Padding(padding: EdgeInsets.all(10)),
        SizedBox(
          height: 66,
          child: CustomTextFormField(
            key: otpKey,
            controller: _otpController,
            focusNode: _otpFocusNode,
            // initialValue: otp,
            labelText: S.of(context).main_password,
            errorText: S.of(context).main_password_description,
            inputFormatter: [
              MaskedInputFormatter(
                '0000',
                allowedCharMatcher: RegExp('[1-9]'),
              )
            ],
            onChanged: (text) {
              bool presentBtnEnable = false;
              if (_codeController.text.length >= 11 && text.length == 4) {
                presentBtnEnable = true;
              }
              widget.onFieldChanged(FieldResult(enable: presentBtnEnable, displayCode: _codeController.text, password: text));
            },
            onFieldSubmitted: (text) {
              widget.onPasswordEnterEvent(text);
            },
          ),
        ),
        const Padding(padding: EdgeInsets.all(10)),
      ],
    );
  }

  void setOtpErrorMsg(String text) {
    otpKey.currentState?.setErrorMsg(text);
  }
}

class FieldResult {
  bool enable = false;
  String displayCode;
  String password;

  FieldResult({required this.enable, required this.displayCode, required this.password});
}