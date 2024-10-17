import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/settings_provider.dart';
import 'package:display_cast_flutter/widgets/v3_setting_language.dart';
import 'package:display_cast_flutter/widgets/v3_setting_legal_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class V3SettingMenu extends StatefulWidget {
  const V3SettingMenu({super.key});

  @override
  State<StatefulWidget> createState() => _V3SettingMenuState();
}

class _V3SettingMenuState extends State<V3SettingMenu> {
  final List<SettingsItems> _listSettings = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        SettingsProvider settingsProvider =
            Provider.of<SettingsProvider>(context, listen: false);
        settingsProvider.setPage(SettingPageState.language);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.bottomLeft,
      backgroundColor: context.tokens.color.vsdswColorSurfaceInverse,
      insetPadding: const EdgeInsets.only(left: 8, bottom: 8),
      child: SizedBox(
        width: 660,
        height: 455,
        child: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, _) {
            _addSettingsToList(context, settingsProvider);
            return Row(
              children: [
                SizedBox(
                  width: 235,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        child: ListView.separated(
                          itemCount: _listSettings.length,
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              width: 204,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shadowColor:
                                      context.tokens.color.vsdswColorPrimary,
                                  foregroundColor: context
                                      .tokens.color.vsdswColorOnSurfaceInverse,
                                  backgroundColor: SettingsProvider
                                              .currentTittlePage.index ==
                                          index
                                      ? context.tokens.color.vsdswColorPrimary
                                      : context
                                          .tokens.color.vsdswColorSurface1000,
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: context
                                        .tokens.spacing.vsdswSpacingXs.top,
                                    horizontal: context
                                        .tokens.spacing.vsdswSpacingSm.left,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  _listSettings[index].callback?.call();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      _listSettings[index].itemTitle,
                                    ),
                                    const Spacer(),
                                    if (_listSettings[index].itemIcon != null)
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: _listSettings[index].itemIcon!,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider(
                              thickness: 1,
                              height: context
                                  .tokens.spacing.vsdswSpacingSm.vertical,
                              color:
                                  context.tokens.color.vsdswColorOutlineVariant,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: CircleAvatar(
                          backgroundColor:
                              context.tokens.color.vsdswColorSurface900,
                          radius: 24,
                          child: IconButton(
                            icon: SvgPicture.asset(
                                'assets/images/v3_ic_menu_close.svg'),
                            color:
                                context.tokens.color.vsdswColorNeutralInverse,
                            onPressed: () {
                              if (navService.canPop()) {
                                navService.goBack();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  color: context.tokens.color.vsdswColorOutlineVariant,
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      switch (settingsProvider.currentPage) {
                        case SettingPageState.language:
                          return const V3SettingLanguage();
                        case SettingPageState.legalPolicy:
                          return const V3SettingsLegalPolicy();
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  _addSettingsToList(BuildContext context, SettingsProvider settingsProvider) {
    _listSettings.clear();
    _listSettings.add(
      SettingsItems(
        S.of(context).v3_setting_language,
        SvgPicture.asset('assets/images/v3_ic_arrow_right.svg'),
        () {
          settingsProvider.setPage(SettingPageState.language);
        },
      ),
    );
    _listSettings.add(
      SettingsItems(
        S.of(context).v3_setting_legal_policy,
        SvgPicture.asset('assets/images/v3_ic_arrow_right.svg'),
        () {
          settingsProvider.setPage(SettingPageState.legalPolicy);
        },
      ),
    );
    _listSettings.add(
      SettingsItems(
        S.of(context).v3_setting_knowledge_base,
        SvgPicture.asset('assets/images/v3_ic_setting_external.svg'),
        () async {
          var url = Uri.parse('https://myviewboard.com/kb/t_CN');
          await launchUrl(url);
        },
      ),
    );
    _listSettings.add(
      SettingsItems(
        S.of(context).v3_setting_check_update,
        null,
        () {
          //todo: implement ota mechanism.
        },
      ),
    );
  }
}

class SettingsItems {
  String itemTitle;
  Widget? itemIcon;
  VoidCallback? callback;

  SettingsItems(this.itemTitle, this.itemIcon, this.callback);
}
