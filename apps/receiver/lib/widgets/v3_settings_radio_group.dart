import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_setting_menu_list_item_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

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
    required this.hasSubFocusItem,
    required this.focusOnInit,
    this.label,
    this.identifier,
  });

  final String initSelectedValue;
  final List<V3SettingsRadioGroupItem> radioList;
  final ValueChanged<String> onChanged;
  final bool hasSubFocusItem;
  final bool focusOnInit;
  final String? label;
  final String? identifier;

  @override
  V3SettingsRadioGroupState createState() => V3SettingsRadioGroupState();
}

class V3SettingsRadioGroupState extends State<V3SettingsRadioGroup> {
  late String _selectedRadio;

  @override
  void initState() {
    super.initState();
    _selectedRadio = widget.initSelectedValue;
    if (widget.focusOnInit) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Provider.of<SettingsProvider>(context, listen: false)
            .subFocusNode
            ?.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.radioList.map<Widget>((V3SettingsRadioGroupItem key) {
          return Column(
            children: [
              V3SettingMenuListItemFocus(
                label: sprintf(widget.label ?? '', [key.title]),
                identifier: "${widget.identifier}_${key.title}",
                focusNode:
                    (key == widget.radioList.first) && widget.hasSubFocusItem
                        ? settingsProvider.subFocusNode
                        : null,
                onTap: settingsProvider.isConnectivityLock
                    ? null
                    : () {
                        if (!mounted) return;
                        setState(() {
                          _selectedRadio = key.value;
                          widget.onChanged(key.value);
                        });
                      },
                child: Container(
                  padding: EdgeInsets.only(
                    top: context.tokens.spacing.vsdslSpacingSm.bottom,
                    bottom: context.tokens.spacing.vsdslSpacingSm.bottom,
                  ),
                  alignment: Alignment.centerLeft,
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            excludeFromSemantics: true,
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
                          Expanded(
                            child: V3AutoHyphenatingText(
                              key.title,
                              style: TextStyle(
                                fontSize: 12,
                                color: context
                                    .tokens.color.vsdslColorOnSurfaceInverse,
                              ),
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
                              Gap(context.tokens.spacing.vsdslSpacingXs.right),
                              Expanded(
                                child: V3AutoHyphenatingText(
                                  key.subtitle!,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: context.tokens.color
                                        .vsdslColorOnSurfaceInverse,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
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
