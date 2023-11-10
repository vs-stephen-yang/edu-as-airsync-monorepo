
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:provider/provider.dart';

import 'custom_text_form_field.dart';

class PresentIdlePinText extends StatefulWidget {
  const PresentIdlePinText({super.key, required this.onFieldChanged, required this.onPasswordEnterEvent});

  final ValueChanged<FieldResult> onFieldChanged;
  final ValueChanged<String> onPasswordEnterEvent;

  @override
  State<StatefulWidget> createState() => PresentIdlePinTextState();

}

class PresentIdlePinTextState extends State<PresentIdlePinText> {

  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final GlobalKey<CustomTextFormFieldState> codeKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();

    _codeFocusNode.addListener(() {
      if (_codeFocusNode.hasFocus) {
        _codeController.selection = TextSelection(baseOffset: 0, extentOffset: _codeController.text.length);
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
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
          width: 250,
          height: 66,
          child: CompositedTransformTarget(
            link: _layerLink,
            child: CustomTextFormField(
              key: codeKey,
              controller: _codeController,
              focusNode: _codeFocusNode,
              labelText: 'PIN code',
              errorText: S.of(context).main_display_code_description,
              inputFormatter: [
                MaskedInputFormatter(
                  '0000',
                  allowedCharMatcher: RegExp('[1-9]'),
                )
              ],
              onChanged: (text) {
                bool presentBtnEnable = false;
                if (text.length == 4) {
                  presentBtnEnable = true;
                }
                widget.onFieldChanged(FieldResult(enable: presentBtnEnable, displayCode: text));
              },
              onFieldSubmitted: (text) {

              },
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.all(10)),
      ],
    );
  }

  void setOtpErrorMsg(String text) {

  }
}

class FieldResult {
  bool enable = false;
  String displayCode;

  FieldResult({required this.enable, required this.displayCode});
}