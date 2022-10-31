import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/main_common.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:flutter/material.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class LanguageSelection extends StatefulWidget {
  const LanguageSelection({Key? key}) : super(key: key);

  @override
  _LanguageSelectionState createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelection> {
  @override
  Widget build(BuildContext context) {
    return MenuDialog(
      backgroundColor: ControlSocket().isPresenting()
          ? AppColors.primary_grey_tran
          : AppColors.primary_grey,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.06,
            margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            color: Colors.transparent,
            child: Row(
              children: [
                FittedBox(
                  fit: BoxFit.fitHeight,
                  child: FocusIconButton(
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.primary_white,
                    ),
                    splashRadius: 20,
                    focusColor: Colors.grey,
                    onClick: () {
                      navService.popUntil('/home');
                    },
                  ),
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: Text(
                        S.of(context).main_language_title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary_white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: AppPreferences.localeMap.length,
              itemBuilder: (BuildContext context, int index) {
                return FocusElevatedButton(
                  child: Text(
                    AppPreferences.localeMap.keys.elementAt(index),
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    alignment: Alignment.centerLeft,
                    primary: (AppPreferences().language ==
                            AppPreferences.localeMap.keys.elementAt(index))
                        ? AppColors.primary_blue
                        : AppColors.primary_grey_dark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                  ),
                  onClick: () {
                    setState(() {
                      MyApp.setNewLocale(context, index);
                    });
                  },
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
}
