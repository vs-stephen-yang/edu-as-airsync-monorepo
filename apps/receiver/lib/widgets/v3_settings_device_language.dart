import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/pref_language_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3SettingsDeviceLanguage extends StatelessWidget {
  const V3SettingsDeviceLanguage({super.key});

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    PrefLanguageProvider languageProvider =
        Provider.of<PrefLanguageProvider>(context, listen: false);
    return Stack(
      children: [
        Positioned(
            left: 0,
            top: 0,
            child: Row(
              children: [
                IconButton(
                  icon: const Image(
                    image: Svg('assets/images/ic_arrow_left.svg'),
                    width: 21,
                    height: 21,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    settingsProvider.setPage(SettingPageState.deviceSetting);
                  },
                ),
                Text(
                  S.of(context).main_language_title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            )),
        Positioned(
          top: 53,
          width: 352,
          child: RadioGroup(
              defaultLanguage: languageProvider.language,
              languageList: languageProvider.localeMap,
              onChange: (String? language) {}),
        ),
        // RadioGroup(
        //   defaultLanguage: languageProvider.language,
        //   onChange: (String? language) {
        //
        // }, ),
      ],
    );
  }
}

class RadioGroup extends StatefulWidget {
  RadioGroup(
      {super.key,
      required this.defaultLanguage,
      required this.languageList,
      required this.onChange});

  String defaultLanguage;
  final Map<String, Locale> languageList;
  final Function(String? language) onChange;

  @override
  _RadioGroupState createState() => _RadioGroupState();
}

class _RadioGroupState extends State<RadioGroup> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.languageList.keys.toList().map<Widget>((String key) {
        return RadioListTile(
          title: Text(
            key,
            style: TextStyle(fontSize: 12),
          ),
          value: key,
          groupValue: widget.defaultLanguage,
          // activeColor: const Color(0xFF3C5AAA),
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return context.tokens.color.vsdslColorSecondary; // 设置选中时的填充颜色
            }
            return Colors.white; // 设置未选中时的填充颜色
          }),
          dense: true,
          visualDensity: VisualDensity(horizontal: -3, vertical: -4),
          // contentPadding: EdgeInsets.all(0),
          onChanged: (String? value) {
            setState(() {
              if (value != null) {
                widget.defaultLanguage = value;
                widget.onChange(value);
              }
            });
          },
        );
      }).toList(),
    );
  }
}
