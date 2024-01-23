import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/screens/language_selection.dart';
import 'package:display_flutter/screens/sender_menu_view.dart';
import 'package:display_flutter/screens/whats_new.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final Map<SettingItems, VoidCallback?> listSettings = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      listSettings.clear();
      listSettings.putIfAbsent(
          SettingItems(
              const Image(
                  image:
                      Svg('assets/images/ic_receiver.svg', size: Size(36, 36))),
              S.of(context).main_settings_share_to_sender),
          () => () {
                _showMenuDialog(const SenderMenuView());
              });
      listSettings.putIfAbsent(
          SettingItems(
              const Icon(
                Icons.language,
                color: Colors.white,
              ),
              S.of(context).main_settings_language),
          () => () {
                AppAnalytics().trackEventAppLanguageClick();
                _showMenuDialog(const LanguageSelection());
              });
      listSettings.putIfAbsent(
          SettingItems(
              const Icon(
                Icons.campaign,
                color: Colors.white,
              ),
              S.of(context).main_settings_whats_new),
          () => () {
                AppAnalytics().trackEventAppWhatsNewsClick();
                _showMenuDialog(const WhatsNew());
              });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MenuDialog(
      backgroundColor: MirrorStateProvider.isMirroring
          ? AppColors.primary_grey_tran
          : AppColors.primary_grey,
      topTitleText: S.of(context).main_settings_title,
      content: ListView.separated(
        itemCount: listSettings.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: listSettings.values.elementAt(index),
            child: Row(
              children: [
                FocusIconButton(
                  childNotFocus: listSettings.keys.elementAt(index).icon,
                  splashRadius: 25,
                  focusColor: Colors.grey,
                  // onClick: listSettings.values.elementAt(index),
                  hasFocusSize: 36,
                  notFocusSize: 36,
                ),
                Text(
                  listSettings.keys.elementAt(index).itemName,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(height: 0, color: Colors.transparent);
        },
      ),
    );
  }

  _showMenuDialog(Widget widget) {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return widget;
      },
    );
  }
}

class SettingItems {
  // IconData iconData;
  Widget icon;
  String itemName;

  SettingItems(this.icon, this.itemName);
}
