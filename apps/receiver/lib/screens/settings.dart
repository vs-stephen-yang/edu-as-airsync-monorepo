import 'dart:math';

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/screens/language_selection.dart';
import 'package:display_flutter/screens/sender_menu_view.dart';
import 'package:display_flutter/screens/whats_new.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/instance_name_editor_dialog.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final List<SettingItems> _listSettings = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _addSettingsToList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String postName = context.read<ChannelProvider>().displayCode;
    postName = postName.substring(max(postName.length - 5, 0));
    return MenuDialog(
      backgroundColor: MirrorStateProvider.isMirroring
          ? AppColors.primary_grey_tran
          : AppColors.primary_grey,
      topTitleText: S.of(context).main_settings_title,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).main_settings_device_name),
                  Text(
                    '${AppPreferences().instanceName}-$postName',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Spacer(),
              FocusIconButton(
                icons: Icons.edit,
                splashRadius: 20,
                focusColor: Colors.grey,
                onClick: () {
                  setState(() {
                    _callInstanceNameEditorDialog();
                  });
                },
              ),
            ],
          ),
          Container(
            height: 2,
            color: Colors.black26,
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _listSettings.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  onTap: _listSettings[index].callback,
                  leading: _listSettings[index].icon,
                  title: Text(
                    _listSettings[index].itemName,
                    style: const TextStyle(fontSize: 18),
                  ),
                  contentPadding: EdgeInsets.zero,
                  visualDensity:
                      const VisualDensity(horizontal: 0, vertical: -4),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(height: 0, color: Colors.transparent);
              },
            ),
          ),
        ],
      ),
    );
  }

  _addSettingsToList() {
    _listSettings.clear();
    _listSettings.add(
      SettingItems(
        const Image(
          image: Svg('assets/images/ic_receiver.svg'),
          width: 32, // define size for placeholder
          height: 32, // define size for placeholder
        ),
        S.of(context).main_settings_share_to_sender,
        () {
          _showMenuDialog(const SenderMenuView());
        },
      ),
    );
    _listSettings.add(
      SettingItems(
        const Icon(Icons.language, size: 32.0),
        S.of(context).main_settings_language,
        () {
          AppAnalytics().trackEventAppLanguageClick();
          _showMenuDialog(const LanguageSelection());
        },
      ),
    );
    _listSettings.add(
      SettingItems(
        const Icon(Icons.campaign, size: 32.0),
        S.of(context).main_settings_whats_new,
        () {
          AppAnalytics().trackEventAppWhatsNewsClick();
          _showMenuDialog(const WhatsNew());
        },
      ),
    );
  }

  _callInstanceNameEditorDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const InstanceNameEditorDialog();
        }).then((_) {
      setState(() {});
    });
  }

  _showMenuDialog(Widget widget) async {
    FocusScope.of(context).unfocus();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return widget;
      },
    ).then((_) {
      setState(() {
        // After change language, the settings list need re-create
        // to using new language text.
        _addSettingsToList();
        FocusScope.of(context).requestFocus();
      });
    });
  }
}

class SettingItems {
  // IconData iconData;
  Widget icon;
  String itemName;
  VoidCallback? callback;

  SettingItems(this.icon, this.itemName, this.callback);
}
