import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/widgets/V3_focus.dart';
import 'package:display_cast_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:qr_flutter/qr_flutter.dart';

class V3DownloadAppMenu extends StatelessWidget {
  const V3DownloadAppMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        alignment: Alignment.center,
        child: TapRegion(
          onTapOutside: (tap) {
            if (navService.canPop()) {
              navService.goBack();
            }
          },
          child: Container(
            constraints: BoxConstraints(maxWidth: 512, maxHeight: 507),
            decoration: BoxDecoration(
                color: context.tokens.color.vsdswColorSurface100,
                borderRadius: context.tokens.radii.vsdswRadius2xl,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0.0, 8.0),
                    blurRadius: 16.0,
                    spreadRadius: 0.0,
                    color: context.tokens.color.vsdswColorOpacityNeutralSm,
                  ),
                ]),
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                LayoutBuilder(builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          V3AutoHyphenatingText(
                            S.of(context).v3_main_download_app_dialog_title,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                              color: context.tokens.color.vsdswColorOnSurface,
                            ),
                          ),
                          QrImageView(
                            data: AppConfig.of(context)!.settings.appStoreUrl,
                            version: QrVersions.auto,
                            size: 144,
                          ),
                          Wrap(
                            spacing: 13,
                            runSpacing: 13,
                            children: [
                              ExcludeSemantics(
                                child: SvgPicture.asset(
                                  'assets/images/ic_store_appstore.svg',
                                  width: 120,
                                  height: 38,
                                ),
                              ),
                              ExcludeSemantics(
                                child: SvgPicture.asset(
                                  'assets/images/ic_store_google_play.svg',
                                  width: 120,
                                  height: 38,
                                ),
                              ),
                            ],
                          ),
                          V3AutoHyphenatingText(
                            S.of(context).v3_main_download_app_dialog_desc,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color:
                                    context.tokens.color.vsdswColorSurface400),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                Positioned(
                  right: 13,
                  bottom: 13,
                  child: V3Focus(
                    label: S.current.v3_lbl_download_menu_minimal,
                    identifier: 'v3_qa_download_menu_minimal',
                    button: true,
                    child: InkWell(
                      child: ExcludeSemantics(
                        child: SvgPicture.asset(
                          'assets/images/ic_menu_minimal.svg',
                          width: 35,
                          height: 35,
                        ),
                      ),
                      onTap: () {
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
        ),
      ),
    );
  }
}
