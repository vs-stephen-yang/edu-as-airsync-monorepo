import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/main_common.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/material.dart';

class LanguageSelection extends StatefulWidget {
  const LanguageSelection({Key? key}) : super(key: key);

  @override
  _LanguageSelectionState createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: ControlSocket().isPresenting()
            ? AppColors.primary_grey_tran
            : AppColors.primary_grey,
      ),
      child: Column(
        children: [
          Container(
            // alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.06,
            margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            color: Colors.transparent,
            child: Row(
              children: [
                FittedBox(
                  fit: BoxFit.fitHeight,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppColors.primary_white),
                    onPressed: () {
                      StreamFunction.showLanguage.value = false;
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
                            color: AppColors.primary_white),
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
                return InkWell(
                  onTap: () {
                    setState(() {
                      MyApp.setNewLocale(context, index);
                    });
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.07,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                        color: (AppPreferences().language ==
                                AppPreferences.localeMap.keys.elementAt(index))
                            ? AppColors.primary_blue
                            : AppColors.primary_grey_dark),
                    child: Text(
                      AppPreferences.localeMap.keys.elementAt(index),
                      style: const TextStyle(color: AppColors.primary_white),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(height: 10, color: Colors.transparent);
              },
            ),
          ),
        ],
      ),
    );
  }
}
