import 'dart:math';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/utilities/data_display_code.dart';
import 'package:display_cast_flutter/widgets/v3_custom_text_form_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class PlatformDetector {
  bool get isWindows => WebRTC.platformIsWindows;

  bool get isWeb => kIsWeb;

  bool get notWindowsNeitherWeb => !isWindows && !isWeb;

  bool get windowsOrWeb => isWindows || isWeb;

  const PlatformDetector();
}

class V3PresentIdleTextField extends StatefulWidget {
  const V3PresentIdleTextField(
      {super.key,
      required this.widthTextField,
      required this.onFieldChanged,
      required this.onPasswordEnterEvent,
      this.platformDetector = const PlatformDetector(),
      this.enable = true});

  final double widthTextField;
  final ValueChanged<V3FieldResult> onFieldChanged;
  final ValueChanged<String> onPasswordEnterEvent;
  final PlatformDetector platformDetector;
  final bool enable;

  @override
  V3PresentIdleTextFieldState createState() => V3PresentIdleTextFieldState();
}

class V3PresentIdleTextFieldState extends State<V3PresentIdleTextField> {
  static const int displayCodeMinLength = 8;
  static const int otpLength = 4;

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  final GlobalKey<V3CustomTextFormFieldState> codeKey = GlobalKey();
  final GlobalKey<V3CustomTextFormFieldState> otpKey = GlobalKey();

  OverlayEntry? _dropDownMenuEntry;
  final LayerLink _dropDownLayerLink = LayerLink();
  bool _isDropDownMenuVisible = false;

  bool userDeleteSpace = false;

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
      enable: widget.enable,
      hintText: S.of(context).v3_main_display_code,
      inputFormatter: [
        if (widget.platformDetector.notWindowsNeitherWeb)
          FilteringTextInputFormatter.digitsOnly,
        if (widget.platformDetector.notWindowsNeitherWeb)
          FilteringTextInputFormatter.allow(RegExp('[0-9\\s]')),
        TextInputFormatter.withFunction((oldValue, newValue) {
          //old is  1234 5678 |9012 new is  1234 5678|9012 then result is 1234 5678| 9012
          // Web && Windows with space, otherwise without space
          final newOffset = newValue.selection.baseOffset;
          if (widget.platformDetector.windowsOrWeb &&
              ((newOffset == 9 && newValue.text.length >= 10) ||
                  (newOffset == 14 && newValue.text.length >= 15))) {
            userDeleteSpace = true;
            return newValue.copyWith();
          } else if ((newOffset == 4 && newValue.text.length >= 5) ||
              (newOffset == 8 && newValue.text.length >= 9)) {
            userDeleteSpace = true;
            return newValue.copyWith();
          }
          return newValue;
        }),
      ],
      onFieldChanged: (text) {
        if (widget.platformDetector.windowsOrWeb) {
          if (text.contains(RegExp(r'[^0-9\s]'))) {
            _setTextFormFieldErrorMsg(
                codeKey, S.of(context).v3_main_display_code_error);
            _isDropDownMenuVisible = false;
            if (_dropDownMenuEntry != null && _dropDownMenuEntry!.mounted) {
              _dropDownMenuEntry?.remove();
            }
            return;
          }
          _codeController.value = _codeController.value.copyWith(
            text: text.toUpperCase(),
            composing: TextRange.empty,
          );
        }

        int cursorPosition = _codeController.selection.baseOffset;
        String currentText = _codeController.text;

        String rawText = currentText.replaceAll(' ', '');

        _isCodeSelectedFromHistory = false;
        codeKey.currentState?.setErrorMsg('');
        bool presentBtnEnable = false;
        if (rawText.length >= displayCodeMinLength &&
            _otpController.text.length == otpLength) {
          presentBtnEnable = true;
        }
        widget.onFieldChanged(V3FieldResult(
            enable: presentBtnEnable,
            isDisplayCodeSelectedFromHistory: _isCodeSelectedFromHistory,
            displayCode: rawText,
            password: _otpController.text));

        int rawCursorPosition =
            currentText.substring(0, cursorPosition).replaceAll(' ', '').length;

        String formattedText = _getDisplayCodeVisualIdentity(rawText);

        int newPosition = rawCursorPosition;
        newPosition += (rawCursorPosition / 4).floor();

        newPosition = min(newPosition, formattedText.length);

        if (userDeleteSpace) {
          newPosition = newPosition - 1;
          userDeleteSpace = false; // reset
        }

        _codeController.value = TextEditingValue(
          text: formattedText,
          selection: TextSelection.collapsed(offset: newPosition),
        );
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
      enable: widget.enable,
      hintText: S.of(context).v3_main_password,
      maxTextLength: otpLength,
      inputFormatter: [
        if (widget.platformDetector.notWindowsNeitherWeb)
          MaskedInputFormatter(
            '0000',
            allowedCharMatcher: RegExp('[0-9]'),
          ),
      ],
      onFieldChanged: (text) {
        if (widget.platformDetector.windowsOrWeb) {
          if (text.contains(RegExp(r'[^0-9]'))) {
            _setTextFormFieldErrorMsg(otpKey, S.of(context).v3_main_otp_error);
            return;
          }
        }
        // clear error message since pass the validation.
        otpKey.currentState?.setErrorMsg('');
        bool presentBtnEnable = false;
        if (_codeController.text.length >= displayCodeMinLength &&
            text.length == otpLength) {
          presentBtnEnable = true;
        }
        widget.onFieldChanged(V3FieldResult(
            enable: presentBtnEnable,
            isDisplayCodeSelectedFromHistory: _isCodeSelectedFromHistory,
            displayCode: _codeController.text.replaceAll(' ', ''),
            password: text));
      },
      onFieldSubmitted: (text) {
        widget.onPasswordEnterEvent(text);
      },
    );
  }

  /// the height of every item is 48
  /// the scroll bar should show up when over 4 items
  /// the max height of the overlay area is 208 (4 * 48 + 8 * 2)
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
            height: min(displayList.length, 4) * 48 +
                context.tokens.spacing.vsdswSpacingXs.vertical,
            child: CompositedTransformFollower(
              offset: const Offset(0, 55),
              link: _dropDownLayerLink,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                    boxShadow: context.tokens.shadow.vsdswShadowNeutralLg,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: displayList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        dense: true,
                        // set this to using smaller height (48).
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        title: Text(
                          _getDisplayCodeVisualIdentity(displayList[index]),
                          style: const TextStyle(fontSize: 16),
                        ),
                        hoverColor: context.tokens.color.vsdswColorTertiary,
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
                          _isCodeSelectedFromHistory = true;
                          _codeController.text = _getDisplayCodeVisualIdentity(
                              displayList[index].replaceAll(' ', ''));
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

  String _getDisplayCodeVisualIdentity(String displayCode) {
    String result = displayCode;
    if (displayCode.length > 4) {
      // https://stackoverflow.com/a/56845471/13160681
      result = displayCode
          .replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ")
          .trimRight();
    }
    return result;
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
          S.of(context).v3_main_instance_not_found_or_offline,
        );
        break;

      case ChannelConnectError.invalidDisplayCode:
        _setTextFormFieldErrorMsg(
          codeKey,
          S.of(context).v3_main_display_code_invalid,
        );
        break;

      case ChannelConnectError.networkError:
        _setTextFormFieldErrorMsg(
          codeKey,
          S.of(context).v3_main_connect_network_error,
        );
        break;

      case ChannelConnectError.invalidOtp:
      case ChannelConnectError.authenticationRequired:
        _setTextFormFieldErrorMsg(
          otpKey,
          S.of(context).v3_main_password_invalid,
        );
        break;

      case ChannelConnectError.rateLimitExceeded:
        _setTextFormFieldErrorMsg(
          codeKey,
          S.of(context).v3_main_connect_rate_limited,
        );
        break;

      case ChannelConnectError.connectionModeUnsupported:
        _setTextFormFieldErrorMsg(
          codeKey,
          S.of(context).v3_main_connection_mode_unsupported,
        );
        break;

      case ChannelConnectError.unknownError:
        _setTextFormFieldErrorMsg(
          otpKey,
          S.of(context).v3_main_connect_unknown_error,
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
