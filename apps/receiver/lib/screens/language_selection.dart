import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/main_common.dart';
import 'package:display_flutter/model/rtc_connector_list.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:flutter/material.dart';

class LanguageSelection extends StatefulWidget {
  const LanguageSelection({super.key});

  @override
  State createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelection> {
  @override
  Widget build(BuildContext context) {
    return MenuDialog(
      backgroundColor: RtcConnectorList.getInstance().isPresenting()
          ? AppColors.primary_grey_tran
          : AppColors.primary_grey,
      topTitleText: S.of(context).main_language_title,
      content: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: AppPreferences.localeMap.length,
        itemBuilder: (BuildContext context, int index) {
          return FocusElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: (AppPreferences().language ==
                      AppPreferences.localeMap.keys.elementAt(index))
                  ? AppColors.primary_blue
                  : AppColors.primary_grey_dark,
              alignment: Alignment.centerLeft,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            ),
            showWhiteBorder: true,
            onClick: () {
              setState(() {
                MyApp.setNewLocale(context, index);
              });
            },
            child: Text(AppPreferences.localeMap.keys.elementAt(index)),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(height: 0, color: Colors.transparent);
        },
      ),
    );
  }
}
