import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/pref_language_provider.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageSelection extends StatefulWidget {
  const LanguageSelection({super.key});

  @override
  State createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelection> {
  @override
  Widget build(BuildContext context) {
    return MenuDialog(
      backgroundColor: HybridConnectionList().isPresenting()
          ? AppColors.primaryGreyTran
          : AppColors.primaryGrey,
      topTitleText: S.of(context).main_language_title,
      content: Consumer<PrefLanguageProvider>(
        builder: (_, prefLanguageProvider, __) {
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: prefLanguageProvider.localeMap.length,
            itemBuilder: (BuildContext context, int index) {
              var language =
                  prefLanguageProvider.localeMap.keys.elementAt(index);
              return FocusElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: (prefLanguageProvider.language == language)
                      ? AppColors.primaryBlue
                      : AppColors.primaryGreyDark,
                  alignment: Alignment.centerLeft,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                ),
                showWhiteBorder: true,
                onClick: () {
                  if (!mounted) return;
                  setState(() {
                    if (prefLanguageProvider.language != language) {
                      prefLanguageProvider.setLanguage(language);
                    }
                  });
                },
                child: Text(language),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(height: 0, color: Colors.transparent);
            },
          );
        },
      ),
    );
  }
}
