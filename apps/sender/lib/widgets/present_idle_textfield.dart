import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/data_display_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:provider/provider.dart';

import 'custom_text_form_field.dart';

class PresentIdleTextField extends StatefulWidget {
  const PresentIdleTextField(
      {super.key,
      required this.onFieldChanged,
      required this.onPasswordEnterEvent});

  final ValueChanged<FieldResult> onFieldChanged;
  final ValueChanged<String> onPasswordEnterEvent;

  @override
  State<StatefulWidget> createState() => PresentIdleTextFieldState();
}

class PresentIdleTextFieldState extends State<PresentIdleTextField> {
  static const int limitDisplayCodeLength = 1;
  static const int limitOtpLength = 4;
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  final GlobalKey<CustomTextFormFieldState> codeKey = GlobalKey();
  final GlobalKey<CustomTextFormFieldState> otpKey = GlobalKey();
  late OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isOverlayVisible = false;

  @override
  void initState() {
    super.initState();

    _codeFocusNode.addListener(() {
      if (_codeFocusNode.hasFocus) {
        _codeController.selection = TextSelection(
            baseOffset: 0, extentOffset: _codeController.text.length);
      } else {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (_isOverlayVisible) {
            _isOverlayVisible = false;
            _overlayEntry.remove();
          }
        });
      }
    });
    _otpFocusNode.addListener(() {
      if (_otpFocusNode.hasFocus) {
        _otpController.selection = TextSelection(
            baseOffset: 0, extentOffset: _otpController.text.length);
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

  /// the height of every item is 40
  /// the scroll bar should show up when over 5 items
  /// the max height of the overlay area is 200
  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(builder: (builder) {
      return Stack(
        children: <Widget>[
          // Check range outside listview
          Positioned(
              width: 250,
              height: DataDisplayCode.getInstance().displayCodeList!.length > 5
                  ? 200
                  : DataDisplayCode.getInstance().displayCodeList!.length * 40,
              child: CompositedTransformFollower(
                offset: const Offset(0, 50),
                link: _layerLink,
                child: Material(
                  child: DataDisplayCode.getInstance().displayCodeList == null
                      ? const SizedBox()
                      : Scrollbar(
                          child: ListView.builder(
                          itemCount: DataDisplayCode.getInstance()
                              .displayCodeList!
                              .length,
                          itemBuilder: (BuildContext context, int index) {
                            List list =
                                DataDisplayCode.getInstance().displayCodeList!;
                            return InkWell(
                              child: Container(
                                  height: 40,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 15),
                                  color: Colors.black12,
                                  child: Text(list[index])),
                              onTap: () {
                                _codeController.text = list[index];
                                if (_isOverlayVisible) {
                                  _isOverlayVisible = false;
                                  _overlayEntry.remove();
                                }
                              },
                            );
                          },
                        )),
                ),
              ))
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      if (channelProvider.exceedMaximumPresenters) {
        codeKey.currentState
            ?.setErrorMsg(S.of(context).main_display_code_exceed);
      }
      if (channelProvider.invalidDisplayCode) {
        codeKey.currentState?.setErrorMsg(S.of(context).main_display_code_invalid);
      }
      if (channelProvider.invalidOtp) {
        otpKey.currentState?.setErrorMsg(S.of(context).main_password_invalid);
      }
    });
    return Column(
      children: [
        SizedBox(
          width: 250,
          height: 66,
          child: CompositedTransformTarget(
            link: _layerLink,
            child: CustomTextFormField(
              key: codeKey,
              controller: _codeController,
              focusNode: _codeFocusNode,
              // initialValue: displayCode,
              labelText: S.of(context).main_display_code,
              errorText: S.of(context).main_display_code_description,
              inputFormatter: [
                UpperCaseTextFormatter(),
                MaskedInputFormatter(
                  '###-###-###-##',
                  allowedCharMatcher: RegExp('[A-Za-z0-9]'),
                )
              ],
              onChanged: (text) {
                bool presentBtnEnable = false;
                if (text.length >= limitDisplayCodeLength &&
                    _otpController.text.length == limitOtpLength) {
                  presentBtnEnable = true;
                }
                widget.onFieldChanged(FieldResult(
                    enable: presentBtnEnable,
                    displayCode: text,
                    password: _otpController.text));
              },
              onTap: () async {
                await DataDisplayCode.getInstance().load();
                if (!_isOverlayVisible &&
                    DataDisplayCode.getInstance().displayCodeList != null) {
                  _isOverlayVisible = true;
                  _overlayEntry = _createOverlayEntry();
                  Overlay.of(context).insert(_overlayEntry);
                }
              },
              onFieldSubmitted: (text) {
                _otpFocusNode.requestFocus();
              },
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.all(10)),
        SizedBox(
          width: 250,
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
              if (_codeController.text.length >= limitDisplayCodeLength &&
                  text.length == limitOtpLength) {
                presentBtnEnable = true;
              }
              widget.onFieldChanged(FieldResult(
                  enable: presentBtnEnable,
                  displayCode: _codeController.text,
                  password: text));
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

  FieldResult(
      {required this.enable,
      required this.displayCode,
      required this.password});
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
