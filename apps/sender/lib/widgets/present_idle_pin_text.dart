
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/data_display_code.dart';
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
  late OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isOverlayVisible = false;

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

  /// the height of every item is 40
  /// the scroll bar should show up when over 5 items
  /// the max height of the overlay area is 200
  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(builder: (builder) {
      return Stack(
        children: <Widget>[
          // Check range outside listview
          GestureDetector(
            onTap: () {
              _isOverlayVisible = false;
              _overlayEntry.remove();
            },
            child: Container(
              color: Colors.transparent, // 設置為透明色
              width: double.infinity,
              height: double.infinity,
            ),
          ),
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
                                  child: Text(list[index])),
                              onTap: () {
                                _codeController.text = list[index];
                                _isOverlayVisible = false;
                                _overlayEntry.remove();
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
              // initialValue: displayCode,
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
              onTap: () async {
                await DataDisplayCode.getInstance().load();
                if (!_isOverlayVisible && DataDisplayCode.getInstance().displayCodeList != null) {
                  _isOverlayVisible = true;
                  _overlayEntry = _createOverlayEntry();
                  Overlay.of(context).insert(_overlayEntry);
                }
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