import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/app_preferences.dart';
import 'package:display_cast_flutter/widgets/v3_background.dart';
import 'package:display_cast_flutter/widgets/v3_focus_single_child_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class V3Eula extends StatelessWidget {
  const V3Eula({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const V3Background(),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                width: 546,
                height: 504,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: context.tokens.radii.vsdswRadiusXl,
                  ),
                  color: context.tokens.color.vsdswColorSurface100,
                  shadows: context.tokens.shadow.vsdswShadowNeutralXl,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      child: AutoSizeText(
                        S.of(context).v3_eula_title,
                        style: TextStyle(
                          color: context.tokens.color.vsdswColorOnInfo,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    Container(
                      height: 1,
                      color: context.tokens.color.vsdswColorOutline,
                    ),
                    const SizedBox(height: 8),
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
                              content = snapshot.data as String;
                            } else {
                              content = S.of(context).v3_eula_title;
                            }
                            return V3FocusSingleChildScrollView(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: AutoSizeText(
                                    content,
                                    style: TextStyle(
                                      color: context
                                          .tokens.color.vsdswColorOnSurface,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      color: context.tokens.color.vsdswColorOutline,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 16, 30, 40),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 108,
                            height: 48,
                            child: TextButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    context.tokens.color.vsdswColorPrimary,
                                backgroundColor: Colors.white,
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                trackEvent('click_eula', EventCategory.system,
                                    target: 'decline');
                                // return to home screen.
                                if (Platform.isIOS) {
                                  // todo: may not pass Apple review, need add some dialog to let user known?
                                  exit(0);
                                } else {
                                  // Android : workable.
                                  // macOS: workable.
                                  // Windows: todo: waiting verify
                                  SystemNavigator.pop();
                                }
                              },
                              child:
                                  AutoSizeText(S.of(context).v3_eula_disagree),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 108,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 5.0,
                                shadowColor:
                                    context.tokens.color.vsdswColorPrimary,
                                foregroundColor: context
                                    .tokens.color.vsdswColorOnSurfaceInverse,
                                backgroundColor:
                                    context.tokens.color.vsdswColorPrimary,
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                trackEvent('click_eula', EventCategory.system,
                                    target: 'accept');

                                AppPreferences().setShowEULA(false);
                                navService.pushNamedAndRemoveUntil('/v3home');
                              },
                              child: AutoSizeText(S.of(context).v3_eula_agree),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _loadEulaFromAssets() async {
    return await rootBundle
        .loadString('assets/ViewSonic-AirSync-EULA-20241115.txt');
  }
}
