import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/widgets/v3_setting_menu_sub_item_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3SettingsRadioGroupItem {
  V3SettingsRadioGroupItem({
    required this.value,
    required this.title,
    this.subtitle,
    this.subtitleIcon,
    required this.divider,
  });

  final String value;
  final String title;
  final String? subtitle;
  final Widget? subtitleIcon;
  final bool divider;
}

class V3SettingsRadioGroup extends StatefulWidget {
  const V3SettingsRadioGroup({
    super.key,
    required this.initSelectedValue,
    required this.radioList,
    required this.onChanged,
  });

  final String initSelectedValue;
  final List<V3SettingsRadioGroupItem> radioList;
  final ValueChanged<String> onChanged;

  @override
  V3SettingsRadioGroupState createState() => V3SettingsRadioGroupState();
}

class V3SettingsRadioGroupState extends State<V3SettingsRadioGroup> {
  late String _selectedRadio;

  @override
  void initState() {
    super.initState();
    _selectedRadio = widget.initSelectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.radioList.map<Widget>((V3SettingsRadioGroupItem key) {
          return Column(
            children: [
              V3SettingMenuSubItemFocus(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: context.tokens.spacing.vsdslSpacingSm.bottom / 2,
                    bottom: context.tokens.spacing.vsdslSpacingSm.bottom / 2,
                  ),
                  child: InkWell(
                    focusNode: (key == widget.radioList.first)
                        ? settingsProvider.subFocusNode
                        : null,
                    onTap: settingsProvider.isConnectivityLock
                        ? null
                        : () {
                            setState(() {
                              _selectedRadio = key.value;
                              widget.onChanged(key.value);
                            });
                          },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              _selectedRadio == key.value
                                  ? settingsProvider.isConnectivityLock
                                      ? 'assets/images/ic_settings_radio_selected_lock.svg'
                                      : 'assets/images/ic_settings_radio_selected.svg'
                                  : settingsProvider.isConnectivityLock
                                      ? 'assets/images/ic_settings_radio_unselect_lock.svg'
                                      : 'assets/images/ic_settings_radio_unselect.svg',
                              width: 20,
                              height: 20,
                            ),
                            Gap(context.tokens.spacing.vsdslSpacingSm.right),
                            AutoSizeText(
                              key.title,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                        if (key.subtitle != null)
                          Padding(
                            padding: EdgeInsets.only(
                              left: 25,
                              top: context.tokens.spacing.vsdslSpacingSm.top,
                              bottom:
                                  context.tokens.spacing.vsdslSpacingSm.bottom,
                            ),
                            child: Row(
                              children: [
                                if (key.subtitleIcon != null) key.subtitleIcon!,
                                Gap(context
                                    .tokens.spacing.vsdslSpacingXs.right),
                                Expanded(
                                  child: AutoSizeText(
                                    key.subtitle!,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: context.tokens.color
                                          .vsdslColorOnSurfaceVariant,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: (key.divider) ? 1 : 0,
                margin: EdgeInsets.only(
                  top: (key.divider)
                      ? context.tokens.spacing.vsdslSpacingSm.top
                      : 0,
                ),
                color: (key.divider)
                    ? context.tokens.color.vsdslColorOutlineVariant
                    : null,
              ),
            ],
          );
        }).toList(),
      );
    });
  }
}
