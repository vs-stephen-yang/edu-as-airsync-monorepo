import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/utilities/data_display_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
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
  static const double widthTextField = 300;
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  final GlobalKey<CustomTextFormFieldState> codeKey = GlobalKey();
  final GlobalKey<CustomTextFormFieldState> otpKey = GlobalKey();
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
        // User use "TAB" key to move to OTP input text field,
        // remove display code overlay
        if (_isOverlayVisible) {
          _isOverlayVisible = false;
          _overlayEntry?.remove();
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

  /// the height of every item is 50
  /// the scroll bar should show up when over 5 items
  /// the max height of the overlay area is 200
  _createOverlayEntry(List displayList) {
    _overlayEntry = OverlayEntry(builder: (builder) {
      return Stack(
        children: <Widget>[
          // Check range outside listview
          GestureDetector(
            onTap: () {
              _isOverlayVisible = false;
              _overlayEntry?.remove();
            },
            child: Container(
              color: Colors.transparent, // 設置為透明色
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            width: widthTextField,
            height: displayList.length > 5 ? 200 : displayList.length * 50,
            child: CompositedTransformFollower(
              offset: const Offset(0, 60),
              link: _layerLink,
              child: Material(
                child: ClipRRect(
                  child: ListView.builder(
                    itemCount: displayList.length,
                    itemBuilder: (BuildContext context, int index) {
                      String displayCode =
                          displayList[index].replaceAll('-', '');
                      return Dismissible(
                        key: Key(displayList[index]),
                        background: Container(color: Colors.red),
                        onDismissed: (direction) {
                          if (!mounted) return;
                          setState(() {
                            DataDisplayCode.getInstance()
                                .remove(displayList[index]);
                            displayList.removeAt(index);
                            _isOverlayVisible = false;
                            _overlayEntry?.remove();
                          });
                        },
                        child: ListTile(
                          title: Text(displayCode),
                          onTap: () {
                            _isCodeSelectedFromHistory = true;
                            _codeController.text = displayCode;
                            _isOverlayVisible = false;
                            _overlayEntry?.remove();
                          },
                        ),
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
    Overlay.of(context).insert(_overlayEntry!);
  }

  _setTextFormFieldErrorMsg(
    GlobalKey<CustomTextFormFieldState> key,
    String text,
  ) {
    key.currentState?.setErrorMsg(text);
  }

  _showConnectErrorMessage(ChannelConnectError error) {
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

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      if (channelProvider.channelConnectError != null) {
        _showConnectErrorMessage(channelProvider.channelConnectError!);
      }
    });
    return SizedBox(
      width: widthTextField,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CompositedTransformTarget(
            link: _layerLink,
            child: CustomTextFormField(
              key: codeKey,
              controller: _codeController,
              focusNode: _codeFocusNode,
              labelText: S.of(context).main_display_code,
              errorText: S.of(context).main_display_code_description,
              maxLength: 11,
              inputFormatter: [
                if (!WebRTC.platformIsWindows && !kIsWeb)
                  UpperCaseTextFormatter(),
                if (!WebRTC.platformIsWindows && !kIsWeb)
                  MaskedInputFormatter(
                    '###########',
                    allowedCharMatcher: RegExp('[A-Za-z0-9]'),
                  ),
              ],
              onChanged: (text) {
                if (WebRTC.platformIsWindows || kIsWeb) {
                  if (text.contains(RegExp(r'[^a-zA-Z0-9]'))) {
                    setCodeErrorMsg(S.of(context).main_display_code_error);
                    _isOverlayVisible = false;
                    if (_overlayEntry != null && _overlayEntry!.mounted)
                      _overlayEntry?.remove();
                    return;
                  }
                  _codeController.value = _codeController.value.copyWith(
                    text: text.toUpperCase(),
                    selection: TextSelection.collapsed(offset: text.length),
                    composing: TextRange.empty,
                  );
                }

                _isCodeSelectedFromHistory = false;

                setCodeDescriptionMsg(
                    S.of(context).main_display_code_description);
                bool presentBtnEnable = false;
                if (text.length >= limitDisplayCodeLength &&
                    _otpController.text.length == limitOtpLength) {
                  presentBtnEnable = true;
                }
                widget.onFieldChanged(FieldResult(
                    enable: presentBtnEnable,
                    isDisplayCodeSelectedFromHistory:
                        _isCodeSelectedFromHistory,
                    displayCode: text,
                    password: _otpController.text));
              },
              onTap: () async {
                List? displayList = await DataDisplayCode.getInstance().load();
                if (!_isOverlayVisible && displayList != null) {
                  _isOverlayVisible = true;
                  _createOverlayEntry(displayList.reversed.toList());
                }
              },
              onFieldSubmitted: (text) {
                _otpFocusNode.requestFocus();
              },
            ),
          ),
          const SizedBox(height: 20),
          CustomTextFormField(
            key: otpKey,
            controller: _otpController,
            focusNode: _otpFocusNode,
            labelText: S.of(context).main_password,
            errorText: S.of(context).main_password_description,
            maxLength: 4,
            inputFormatter: [
              if (!WebRTC.platformIsWindows && !kIsWeb)
                MaskedInputFormatter(
                  '0000',
                  allowedCharMatcher: RegExp('[0-9]'),
                ),
            ],
            onChanged: (text) {
              if (WebRTC.platformIsWindows || kIsWeb) {
                if (text.contains(RegExp(r'[^0-9]'))) {
                  setOtpErrorMsg(S.of(context).main_otp_error);
                  return;
                }
              }
              setOtpDescriptionMsg(S.of(context).main_password_description);
              bool presentBtnEnable = false;
              if (_codeController.text.length >= limitDisplayCodeLength &&
                  text.length == limitOtpLength) {
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

  void setCodeDescriptionMsg(String text) {
    codeKey.currentState?.setDescriptionMsg(text);
  }

  void setCodeErrorMsg(String text) {
    codeKey.currentState?.setErrorMsg(text);
  }

  void setOtpDescriptionMsg(String text) {
    otpKey.currentState?.setDescriptionMsg(text);
  }

  void setOtpErrorMsg(String text) {
    otpKey.currentState?.setErrorMsg(text);
  }
}

class FieldResult {
  bool enable = false;
  bool isDisplayCodeSelectedFromHistory;
  String displayCode;
  String password;

  FieldResult(
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
