import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class V3SettingsRadioGroupItem extends StatefulWidget {
  const V3SettingsRadioGroupItem({
    super.key,
    required this.value,
    required this.defaultSelectedState,
    required this.onChange,
  });

  final String value;
  final bool defaultSelectedState;
  final Function(bool selected) onChange;

  @override
  State<StatefulWidget> createState() => _V3SettingsRadioGroupItemState();
}

class _V3SettingsRadioGroupItemState extends State<V3SettingsRadioGroupItem> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.defaultSelectedState) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        setState(() {
          widget.onChange(hasFocus);
        });
      },
      child: Builder(builder: (context) {
        return Container(
          height: 26,
          margin: EdgeInsets.only(
              bottom: context.tokens.spacing.vsdslSpacingSm.bottom),
          child: InkWell(
            onTap: () {
              FocusScope.of(context).requestFocus(_focusNode);
            },
            child: Row(
              children: [
                Image(
                  width: 20,
                  height: 20,
                  image: _focusNode.hasFocus
                      ? const Svg(
                          'assets/images/ic_settings_radio_selected.svg')
                      : const Svg(
                          'assets/images/ic_settings_radio_unselect.svg'),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        right: context.tokens.spacing.vsdslSpacingSm.right)),
                Text(
                  widget.value,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
