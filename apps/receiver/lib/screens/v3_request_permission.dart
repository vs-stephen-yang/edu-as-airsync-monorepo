import 'dart:io';

import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

class V3RequestPermission extends StatefulWidget {
  const V3RequestPermission({super.key, required this.primaryFocusNode});

  final FocusNode primaryFocusNode;

  @override
  State<StatefulWidget> createState() => V3RequestPermissionState();
}

class V3RequestPermissionState extends State<V3RequestPermission> {
  late final Future<void> _hyphenationInit;

  @override
  void initState() {
    super.initState();
    _hyphenationInit = initHyphenation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _hyphenationInit,
        builder: (_, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Container();
          }
          return Consumer<MirrorStateProvider>(
              builder: (_, mirrorStateProvider, __) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mirrorStateProvider.isPermissionGranted) {
                navService.pushNamedAndRemoveUntil(AppPreferences().showEULA &&
                        !AppInstanceCreate().isInstalledInVBS100
                    ? '/v3Eula'
                    : '/v3Home');
              }
            });
            return ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(color: const Color(0xFFEAEBF1)),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Image.asset(
                      'assets/images/ic_wallpaper.png',
                      excludeFromSemantics: true,
                      width: 1280,
                      height: 360,
                      fit: BoxFit.cover,
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
                        const Gap(7),
                        SvgPicture.asset(
                          'assets/images/ic_logo_airsync_text.svg',
                          excludeFromSemantics: true,
                          width: 140,
                          height: 31,
                          colorFilter: const ColorFilter.mode(
                              Colors.black, BlendMode.srcIn),
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: 512,
                          minHeight: 150,
                        ),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: context.tokens.radii.vsdslRadiusXl,
                          ),
                          color: context.tokens.color.vsdslColorSurface100,
                          shadows: context.tokens.shadow.vsdslShadowNeutralXl,
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 27, 20, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            V3AutoHyphenatingText(
                              'Permission required',
                              style: TextStyle(
                                color: context.tokens.color.vsdslColorOnSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 21,
                              ),
                            ),
                            const Gap(20),
                            V3AutoHyphenatingText(
                              'Please go to setting to grant permission',
                              style: TextStyle(
                                color: context.tokens.color.vsdslColorOnSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 21,
                              ),
                            ),
                            const Gap(40),
                            SizedBox(
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
                                      color: context
                                          .tokens.color.vsdslColorSecondary,
                                      width: 1.5,
                                    ),
                                    textStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
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
                                  child: V3AutoHyphenatingText('Exit'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}
