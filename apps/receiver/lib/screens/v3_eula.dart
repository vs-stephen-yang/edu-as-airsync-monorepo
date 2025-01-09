import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_focus_single_child_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class V3Eula extends StatelessWidget {
  const V3Eula({super.key, required this.primaryFocusNode});

  final FocusNode primaryFocusNode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              color: const Color(0xFFEAEBF1),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/images/ic_wallpaper.png',
                width: 1280,
                height: 360,
              ),
            ),
            const Positioned(
              left: 25,
              top: 25,
              right: 25,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image(
                    image: Svg('assets/images/ic_logo_airsync_icon.svg'),
                    height: 36,
                    width: 36,
                  ),
                  Padding(padding: EdgeInsets.only(left: 7)),
                  Image(
                    image: Svg('assets/images/ic_logo_airsync_text.svg'),
                    height: 31,
                    width: 140,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            Positioned(
              right: 13,
              bottom: 13,
              child: Image.asset(
                'assets/images/ic_logo_viewsonic.png',
                width: 513 / 3,
                height: 160 / 3,
              ),
            ),
            Container(
              width: 512,
              height: 507,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: context.tokens.radii.vsdslRadiusXl,
                ),
                color: context.tokens.color.vsdslColorSurface100,
                shadows: context.tokens.shadow.vsdslShadowNeutralXl,
              ),
              padding: const EdgeInsets.fromLTRB(20, 27, 20, 20),
              child: Column(
                children: [
                  AutoSizeText(
                    S.of(context).v3_eula_title,
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorOnSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 21,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: FutureBuilder<String>(
                        future: _loadEulaFromAssets(),
                        builder: (context, snapshot) {
                          String content;
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.data != null) {
                            content = (snapshot.data as String).replaceFirst(
                                '2016-%s', '2016-${DateTime.now().year}');
                          } else {
                            content = S.of(context).eula_title;
                          }
                          return V3FocusSingleChildScrollView(
                            children: [
                              AutoSizeText(
                                content,
                                style: TextStyle(
                                  color: context.tokens.color.vsdslColorNeutral,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 108,
                        height: 40,
                        child: V3Focus(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor:
                                  context.tokens.color.vsdslColorSecondary,
                              backgroundColor: Colors.white,
                              overlayColor: Colors.transparent,
                              // remove onFocused color, this is also ripple color
                              side: BorderSide(
                                color: context.tokens.color.vsdslColorSecondary,
                                width: 1.5,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () {
                              if (Platform.isAndroid) {
                                SystemNavigator.pop();
                              } else if (Platform.isIOS) {
                                exit(0);
                              } else {
                                // todo: support other platform.
                              }
                            },
                            child: AutoSizeText(S.of(context).v3_eula_disagree),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 108,
                        height: 40,
                        child: V3Focus(
                          child: ElevatedButton(
                            focusNode: primaryFocusNode,
                            style: ElevatedButton.styleFrom(
                              elevation: 5.0,
                              shadowColor:
                                  context.tokens.color.vsdslColorSecondary,
                              foregroundColor: context
                                  .tokens.color.vsdslColorOnSurfaceInverse,
                              overlayColor:
                                  context.tokens.color.vsdslColorSecondary,
                              // remove onFocused color, this is also ripple color
                              backgroundColor:
                                  context.tokens.color.vsdslColorSecondary,
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () {
                              AppPreferences().set(showEULA: false);
                              navService.pushNamedAndRemoveUntil('/v3Home');
                            },
                            child: AutoSizeText(S.of(context).v3_eula_agree),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _loadEulaFromAssets() async {
    return await rootBundle
        .loadString('assets/ViewSonic-MVB-EULA-20230508.txt');
  }
}
