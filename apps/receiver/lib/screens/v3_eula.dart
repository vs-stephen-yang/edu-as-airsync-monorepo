import 'dart:io';

import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_eula_disable_page.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_focus_single_child_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class V3Eula extends StatefulWidget {
  const V3Eula({super.key, required this.primaryFocusNode});

  final FocusNode primaryFocusNode;

  @override
  State<V3Eula> createState() => _V3EulaState();
}

late Future<void> initOperation;

class _V3EulaState extends State<V3Eula> {
  late Future<void> initOperation;
  bool showDisagreePage = false;

  @override
  void initState() {
    super.initState();
    initOperation = initHyphenation();
  }

  @override
  Widget build(BuildContext context) {
    if (showDisagreePage) {
      return V3EulaDisablePage(onPressed: () {
        setState(() {
          showDisagreePage = false;
        });
      });
    }
    return _buildEula(context);
  }

  Scaffold _buildEula(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: initOperation,
          builder: (_, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Container();
            }
            return ConstrainedBox(
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
                      excludeFromSemantics: true,
                      width: 1280,
                      height: 360,
                    ),
                  ),
                  Positioned(
                    left: 25,
                    top: 25,
                    right: 25,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SvgPicture.asset(
                          'assets/images/ic_logo_airsync_icon.svg',
                          excludeFromSemantics: true,
                          width: 36,
                          height: 36,
                        ),
                        const Padding(padding: EdgeInsets.only(left: 7)),
                        SvgPicture.asset(
                          'assets/images/ic_logo_airsync_text.svg',
                          excludeFromSemantics: true,
                          width: 140,
                          height: 31,
                          colorFilter: const ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 13,
                    bottom: 13,
                    child: Image.asset(
                      'assets/images/ic_logo_viewsonic.png',
                      excludeFromSemantics: true,
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
                        V3AutoHyphenatingText(
                          S.of(context).v3_eula_title,
                          style: TextStyle(
                            color: context.tokens.color.vsdslColorOnSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 21,
                          ),
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
                                  content = (snapshot.data as String)
                                      .replaceFirst('2016-%s',
                                          '2016-${DateTime.now().year}');
                                } else {
                                  content = S.of(context).eula_title;
                                }
                                return V3FocusSingleChildScrollView(
                                  primaryFocusNode: widget.primaryFocusNode,
                                  children: [
                                    V3AutoHyphenatingText(
                                      content,
                                      style: TextStyle(
                                        color: context
                                            .tokens.color.vsdslColorNeutral,
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
                            FutureBuilder(
                                future: DeviceInfoVs.isCorporateMode,
                                builder: (context, snapshot) {
                                  final isCorporateMode =
                                      snapshot.hasData && snapshot.data == true;
                                  return SizedBox(
                                    width: 108,
                                    height: 40,
                                    child: V3Focus(
                                      label: S.of(context).v3_lbl_eula_disagree,
                                      identifier: 'v3_qa_eula_disagree',
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: context
                                              .tokens.color.vsdslColorSecondary,
                                          backgroundColor: Colors.white,
                                          overlayColor: Colors.transparent,
                                          // remove onFocused color, this is also ripple color
                                          side: BorderSide(
                                            color: context.tokens.color
                                                .vsdslColorSecondary,
                                            width: 1.5,
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                        onPressed: () {
                                          if (isCorporateMode) {
                                            setState(() {
                                              showDisagreePage = true;
                                            });
                                          }

                                          if (Platform.isAndroid) {
                                            SystemNavigator.pop();
                                          } else if (Platform.isIOS) {
                                            exit(0);
                                          } else {
                                            // todo: support other platform.
                                          }
                                        },
                                        child: V3AutoHyphenatingText(
                                            S.of(context).v3_eula_disagree),
                                      ),
                                    ),
                                  );
                                }),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 108,
                              height: 40,
                              child: V3Focus(
                                label: S.of(context).v3_lbl_eula_agree,
                                identifier: 'v3_qa_eula_agree',
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 5.0,
                                    shadowColor: context
                                        .tokens.color.vsdslColorSecondary,
                                    foregroundColor: context.tokens.color
                                        .vsdslColorOnSurfaceInverse,
                                    overlayColor: context
                                        .tokens.color.vsdslColorSecondary,
                                    // remove onFocused color, this is also ripple color
                                    backgroundColor: context
                                        .tokens.color.vsdslColorSecondary,
                                    textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () {
                                    AppPreferences().set(showEULA: false);
                                    navService
                                        .pushNamedAndRemoveUntil('/v3Home');
                                  },
                                  child: V3AutoHyphenatingText(
                                      S.of(context).v3_eula_agree),
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
            );
          }),
    );
  }

  Future<String> _loadEulaFromAssets() async {
    return await rootBundle
        .loadString('assets/ViewSonic-MVB-EULA-20230508.txt');
  }
}
