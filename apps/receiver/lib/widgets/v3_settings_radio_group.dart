import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class V3SettingsRadioGroup extends StatefulWidget {
  const V3SettingsRadioGroup(
      {super.key,
      required this.defaultLanguage,
      required this.languageList,
      required this.onChange});

  final String defaultLanguage;
  final Map<String, Locale> languageList;
  final Function(String language) onChange;

  @override
  V3SettingsRadioGroupState createState() => V3SettingsRadioGroupState();
}

class V3SettingsRadioGroupState extends State<V3SettingsRadioGroup> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.defaultLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.languageList.keys.toList().map<Widget>((String key) {
        return Container(
          height: 26,
          margin: EdgeInsets.only(
              bottom: context.tokens.spacing.vsdslSpacingSm.bottom),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedLanguage = key;
                widget.onChange(key);
              });
            },
            child: Row(
              children: [
                Image(
                  width: 20,
                  height: 20,
                  image: _selectedLanguage == key
                      ? const Svg(
                          'assets/images/ic_settings_radio_selected.svg')
                      : const Svg(
                          'assets/images/ic_settings_radio_unselect.svg'),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        right: context.tokens.spacing.vsdslSpacingSm.right)),
                Text(
                  key,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
