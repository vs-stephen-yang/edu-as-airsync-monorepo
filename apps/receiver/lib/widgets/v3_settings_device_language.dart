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
                  onPressed: () {
                    settingsProvider.setPage(SettingPageState.deviceSetting);
                  },
                ),
                Padding(
                    padding: EdgeInsets.only(
                        right: context.tokens.spacing.vsdslSpacingXs.right)),
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
          top: 57,
          left: 13,
          width: 352,
          child: RadioGroup(
              defaultLanguage: languageProvider.language,
              languageList: languageProvider.localeMap,
              onChange: (String language) {
                languageProvider.setLanguage(language);
              }),
        ),
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
  final Function(String language) onChange;

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
        return Container(
          height: 26,
          margin: EdgeInsets.only(
              bottom: context.tokens.spacing.vsdslSpacingSm.bottom),
          child: InkWell(
            onTap: () {
              setState(() {
                widget.defaultLanguage = key;
                widget.onChange(key);
              });
            },
            child: Row(
              children: [
                Image(
                  width: 20,
                  height: 20,
                  image: widget.defaultLanguage == key
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
