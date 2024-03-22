import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_overlay_tab.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
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
  bool _isInChildDialog = false;

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
    if (_isInChildDialog) {
      return const SizedBox();
    }
    return MenuDialog(
      backgroundColor: HybridConnectionList().isMirroring()
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
                    Provider.of<MirrorStateProvider>(context).deviceName,
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
          Row(
            children: [
              const Icon(Icons.pin, size: 32.0),
              const SizedBox(width: 20),
              Text(
                S.of(context).main_settings_pin_visible,
                style: const TextStyle(fontSize: 18),
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.fitHeight,
                child: FocusIconButton(
                  childNotFocus: FutureBuilder(
                    future: AppOverlayTab().getVisibility(),
                    builder: (context, snapshot) {
                      bool isRunning = false;
                      if (snapshot.hasData) {
                        isRunning = snapshot.data as bool;
                      }
                      return Image(
                        image: Svg(isRunning
                            ? 'assets/images/ic_activate_on.svg'
                            : 'assets/images/ic_activate_off.svg'),
                      );
                    },
                  ),
                  splashRadius: 20,
                  focusColor: Colors.grey,
                  onClick: () {
                    AppPreferences()
                        .set(showOverlayTab: !AppPreferences().showOverlayTab);
                    AppOverlayTab()
                        .setVisibility(AppPreferences().showOverlayTab);
                    setState(() {});
                  },
                ),
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
    _isInChildDialog = true;
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
        _isInChildDialog = false;
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
