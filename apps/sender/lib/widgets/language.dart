import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/pref_language_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Language extends StatelessWidget {
  const Language({super.key});

  @override
  Widget build(BuildContext context) {
    PrefLanguageProvider provider = Provider.of<PrefLanguageProvider>(context);
    return SizedBox(
      width: AppConstants.viewStateMenuWidth,
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Provider.of<PresentStateProvider>(context,
                                listen: false)
                            .presentSettingPage();
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  S.of(context).main_language,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: AppConstants.fontSizeTitle,
                  ),
                ),
              ),
              const Spacer(
                flex: 1,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Divider(
              color: Colors.white12,
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: provider.localeMap.length,
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: InkWell(
                    onTap: () {
                      trackEvent('click_language', EventCategory.setting);

                      provider.setLanguage(
                          provider.localeMap.keys.elementAt(index));
                    },
                    child: Text(
                      provider.localeMap.keys.elementAt(index),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(height: 20, color: Colors.transparent);
              },
            ),
          ),
        ],
      ),
    );
  }
}
