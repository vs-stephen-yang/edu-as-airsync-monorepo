import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/utilities/data_display_code.dart';
import 'package:display_cast_flutter/widgets/v3_custom_text_form_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class V3PresentIdleTextField extends StatefulWidget {
  const V3PresentIdleTextField(
      {super.key,
      required this.widthTextField,
      required this.onFieldChanged,
      required this.onPasswordEnterEvent});

  final double widthTextField;
  final ValueChanged<V3FieldResult> onFieldChanged;
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
  final GlobalKey<V3CustomTextFormFieldState> codeKey = GlobalKey();
  final GlobalKey<V3CustomTextFormFieldState> otpKey = GlobalKey();

  OverlayEntry? _dropDownMenuEntry;
  final LayerLink _dropDownLayerLink = LayerLink();
  bool _isDropDownMenuVisible = false;

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
        // User use "TAB" key to move to OTP input text field,
        // remove display code overlay
        if (_isDropDownMenuVisible) {
          _isDropDownMenuVisible = false;
          _dropDownMenuEntry?.remove();
        }
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
          CompositedTransformTarget(
            link: _dropDownLayerLink,
            child: _displayCodeTextFormField(context),
          ),
          const SizedBox(height: 20),
          _otpTextFormField(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  V3CustomTextFormField _displayCodeTextFormField(BuildContext context) {
    return V3CustomTextFormField(
      key: codeKey,
      controller: _codeController,
      focusNode: _codeFocusNode,
      hintText: S.of(context).main_display_code,
      maxTextLength: displayCodeMaxLength,
      inputFormatter: [
        if (!WebRTC.platformIsWindows && !kIsWeb) UpperCaseTextFormatter(),
        if (!WebRTC.platformIsWindows && !kIsWeb)
          MaskedInputFormatter(
            '###########',
            allowedCharMatcher: RegExp('[A-Za-z0-9]'),
          ),
      ],
      onFieldChanged: (text) {
        if (WebRTC.platformIsWindows || kIsWeb) {
          if (text.contains(RegExp(r'[^a-zA-Z0-9]'))) {
            _setTextFormFieldErrorMsg(
                codeKey, S.of(context).main_display_code_error);
            _isDropDownMenuVisible = false;
            if (_dropDownMenuEntry != null && _dropDownMenuEntry!.mounted) {
              _dropDownMenuEntry?.remove();
            }
            return;
          }
          _codeController.value = _codeController.value.copyWith(
            text: text.toUpperCase(),
            selection: TextSelection.collapsed(offset: text.length),
            composing: TextRange.empty,
          );
        }

        _isCodeSelectedFromHistory = false;
        bool presentBtnEnable = false;
        if (text.length >= displayCodeMinLength &&
            _otpController.text.length == otpLength) {
          presentBtnEnable = true;
        }
        widget.onFieldChanged(V3FieldResult(
            enable: presentBtnEnable,
            isDisplayCodeSelectedFromHistory: _isCodeSelectedFromHistory,
            displayCode: text,
            password: _otpController.text));
      },
      onTap: () async {
        List? displayList = await DataDisplayCode.getInstance().load();
        if (!_isDropDownMenuVisible &&
            displayList != null &&
            displayList.isNotEmpty) {
          _isDropDownMenuVisible = true;
          _dropDownMenu(displayList.reversed.toList());
        }
      },
      onFieldSubmitted: (text) {
        _otpFocusNode.requestFocus();
      },
    );
  }

  V3CustomTextFormField _otpTextFormField(BuildContext context) {
    return V3CustomTextFormField(
      key: otpKey,
      controller: _otpController,
      focusNode: _otpFocusNode,
      hintText: S.of(context).main_password,
      maxTextLength: otpLength,
      inputFormatter: [
        if (!WebRTC.platformIsWindows && !kIsWeb)
          MaskedInputFormatter(
            '0000',
            allowedCharMatcher: RegExp('[0-9]'),
          ),
      ],
      onFieldChanged: (text) {
        if (WebRTC.platformIsWindows || kIsWeb) {
          if (text.contains(RegExp(r'[^0-9]'))) {
            _setTextFormFieldErrorMsg(otpKey, S.of(context).main_otp_error);
            return;
          }
        }
        bool presentBtnEnable = false;
        if (_codeController.text.length >= displayCodeMinLength &&
            text.length == otpLength) {
          presentBtnEnable = true;
        }
        widget.onFieldChanged(V3FieldResult(
            enable: presentBtnEnable,
            isDisplayCodeSelectedFromHistory: _isCodeSelectedFromHistory,
            displayCode: _codeController.text,
            password: text));
      },
      onFieldSubmitted: (text) {
        widget.onPasswordEnterEvent(text);
      },
    );
  }

  /// the height of every item is 48
  /// the scroll bar should show up when over 5 items
  /// the max height of the overlay area is 200
  _dropDownMenu(List displayList) {
    _dropDownMenuEntry = OverlayEntry(builder: (builder) {
      return Stack(
        children: <Widget>[
          // Check range outside listview
          GestureDetector(
            onTap: () {
              _isDropDownMenuVisible = false;
              _dropDownMenuEntry?.remove();
            },
            child: Container(
              color: Colors.transparent, // 設置為透明色
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            width: widget.widthTextField,
            height: displayList.length > 4 ? 208 : displayList.length * 48,
            child: CompositedTransformFollower(
              offset: const Offset(0, 55),
              link: _dropDownLayerLink,
              child: Material(
                color: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Container(
                  color: Colors.transparent,
                  margin: const EdgeInsets.all(8),
                  child: ListView.builder(
                    itemCount: displayList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        title: Text(displayList[index]),
                        hoverColor: context.tokens.color.vsdslColorTertiary,
                        trailing: IconButton(
                          icon: const Icon(Icons.highlight_remove),
                          onPressed: () {
                            DataDisplayCode.getInstance()
                                .remove(displayList[index]);
                            displayList.removeAt(index);
                            _isDropDownMenuVisible = false;
                            _dropDownMenuEntry?.remove();
                          },
                        ),
                        onTap: () {
                          AppAnalytics.instance
                              .trackEvent('select_display_code');
                          _isCodeSelectedFromHistory = true;
                          _codeController.text = displayList[index];
                          _isDropDownMenuVisible = false;
                          _dropDownMenuEntry?.remove();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      );
    });
    Overlay.of(context).insert(_dropDownMenuEntry!);
  }

  _setTextFormFieldErrorMsg(
    GlobalKey<V3CustomTextFormFieldState> key,
    String text,
  ) {
    key.currentState?.setErrorMsg(text);
  }

  handleConnectErrorMessage(ChannelConnectError error) {
    switch (error) {
      case ChannelConnectError.instanceNotFound:
        _setTextFormFieldErrorMsg(
          codeKey,
          S.of(context).main_instance_not_found_or_offline,
        );
        break;

      case ChannelConnectError.invalidDisplayCode:
        _setTextFormFieldErrorMsg(
          codeKey,
          S.of(context).main_display_code_invalid,
        );
        break;

      case ChannelConnectError.networkError:
        _setTextFormFieldErrorMsg(
          codeKey,
          S.of(context).main_connect_network_error,
        );
        break;

      case ChannelConnectError.invalidOtp:
      case ChannelConnectError.authenticationRequired:
        _setTextFormFieldErrorMsg(
          otpKey,
          S.of(context).main_password_invalid,
        );
        break;

      case ChannelConnectError.rateLimitExceeded:
        _setTextFormFieldErrorMsg(
          codeKey,
          S.of(context).main_connect_rate_limited,
        );
        break;

      case ChannelConnectError.connectionModeUnsupported:
        _setTextFormFieldErrorMsg(
          codeKey,
          S.of(context).main_connection_mode_unsupported,
        );
        break;

      case ChannelConnectError.unknownError:
        _setTextFormFieldErrorMsg(
          otpKey,
          S.of(context).main_connect_unknown_error,
        );
        break;
    }
  }
}

class V3FieldResult {
  bool enable = false;
  bool isDisplayCodeSelectedFromHistory;
  String displayCode;
  String password;

  V3FieldResult(
      {required this.enable,
      required this.displayCode,
      required this.isDisplayCodeSelectedFromHistory,
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
