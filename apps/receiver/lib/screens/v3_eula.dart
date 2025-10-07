import 'dart:io';

import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_eula_disable_page.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_focus_single_child_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class V3Eula extends StatefulWidget {
  const V3Eula({super.key, required this.primaryFocusNode});

  final FocusNode primaryFocusNode;

  @override
  State<V3Eula> createState() => _V3EulaState();
}

class _V3EulaState extends State<V3Eula> {
  late final Future<void> _hyphenationInit;
  late final Future<String> _eulaFuture;
  late final Future<bool?> _corporateModeFuture;

  bool _showDisagreePage = false;

  @override
  void initState() {
    super.initState();
    _hyphenationInit = initHyphenation();
    _eulaFuture = _loadEulaFromAssets();
    _corporateModeFuture = DeviceInfoVs.isCorporateMode;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/ic_wallpaper.png'), context);
    precacheImage(
      const AssetImage('assets/images/ic_logo_viewsonic.png'),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showDisagreePage) {
      return V3EulaDisablePage(
        onPressed: () {
          if (!mounted) return;
          setState(() => _showDisagreePage = false);
        },
      );
    }
    return _buildEula(context);
  }

  Scaffold _buildEula(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _hyphenationInit,
        builder: (_, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Container();
          }

          final full = _fullScreen(context);
          final compact = _oneThird(context);
          return MultiWindowAdaptiveLayout(
            landscape: full,
            launcher: compact,
            landscapeHalf: full,
            landscapeOneThird: compact,
            floatingDefault: full,
          );
        },
      ),
    );
  }

  Widget _oneThird(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 16, bottom: 10),
      color: context.tokens.color.vsdslColorSurface100,
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
          const Gap(10),
          Expanded(
            child: Directionality(
              textDirection: Directionality.of(context),
              child: _EulaText(
                eulaFuture: _eulaFuture,
                primaryFocusNode: widget.primaryFocusNode,
              ),
            ),
          ),
          const Gap(10),
          _ActionButtons(
            height: 30,
            corporateModeFuture: _corporateModeFuture,
            onRequireDisablePage: () {
              if (!mounted) return;
              setState(() => _showDisagreePage = true);
            },
          ),
        ],
      ),
    );
  }

  Widget _fullScreen(BuildContext context) {
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
                  colorFilter:
                      const ColorFilter.mode(Colors.black, BlendMode.srcIn),
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
            children: [
              const Expanded(child: SizedBox.shrink()),
              Expanded(
                flex: 3,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 512,
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
                    children: [
                      V3AutoHyphenatingText(
                        S.of(context).v3_eula_title,
                        style: TextStyle(
                          color: context.tokens.color.vsdslColorOnSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 21,
                        ),
                      ),
                      const Gap(20),
                      Expanded(
                        child: Directionality(
                          textDirection: Directionality.of(context),
                          child: _EulaText(
                            eulaFuture: _eulaFuture,
                            primaryFocusNode: widget.primaryFocusNode,
                          ),
                        ),
                      ),
                      const Gap(30),
                      _ActionButtons(
                        height: 40,
                        corporateModeFuture: _corporateModeFuture,
                        onRequireDisablePage: () {
                          if (!mounted) return;
                          setState(() => _showDisagreePage = true);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ],
      ),
    );
  }

  Future<String> _loadEulaFromAssets() async {
    try {
      final raw =
          await rootBundle.loadString('assets/ViewSonic-MVB-EULA-20230508.txt');
      // Replace year placeholder once and reuse the result
      return raw.replaceFirst('2016-%s', '2016-${DateTime.now().year}');
    } catch (_) {
      // Fall back to localized title if asset can't be read
      if (!context.mounted) return '';
      return S.of(context).eula_title;
    }
  }
}

class _EulaText extends StatelessWidget {
  const _EulaText({
    required this.eulaFuture,
    required this.primaryFocusNode,
  });

  final Future<String> eulaFuture;
  final FocusNode primaryFocusNode;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: eulaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container();
        }

        final content = snapshot.data ?? S.of(context).eula_title;
        return V3FocusSingleChildScrollView(
          primaryFocusNode: primaryFocusNode,
          children: [
            V3AutoHyphenatingText(
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
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.height,
    required this.corporateModeFuture,
    required this.onRequireDisablePage,
  });

  final double height;
  final Future<bool?> corporateModeFuture;
  final VoidCallback onRequireDisablePage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FutureBuilder(
          future: corporateModeFuture,
          builder: (context, snapshot) {
            final isCorporateMode = snapshot.data == true;
            return SizedBox(
              width: 108,
              height: height,
              child: V3Focus(
                label: S.of(context).v3_lbl_eula_disagree,
                identifier: 'v3_qa_eula_disagree',
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: context.tokens.color.vsdslColorSecondary,
                    backgroundColor: Colors.white,
                    overlayColor: Colors.transparent,
                    // remove onFocused color, this is also ripple color
                    side: BorderSide(
                      color: context.tokens.color.vsdslColorSecondary,
                      width: 1.5,
                    ),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    if (isCorporateMode) {
                      onRequireDisablePage();
                    }

                    if (Platform.isAndroid) {
                      SystemNavigator.pop();
                    } else if (Platform.isIOS) {
                      exit(0);
                    } else {
                      // todo: support other platform.
                    }
                  },
                  child: V3AutoHyphenatingText(S.of(context).v3_eula_disagree),
                ),
              ),
            );
          },
        ),
        const Gap(8),
        SizedBox(
          width: 108,
          height: height,
          child: V3Focus(
            label: S.of(context).v3_lbl_eula_agree,
            identifier: 'v3_qa_eula_agree',
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 5.0,
                shadowColor: context.tokens.color.vsdslColorSecondary,
                foregroundColor:
                    context.tokens.color.vsdslColorOnSurfaceInverse,
                overlayColor: context.tokens.color.vsdslColorSecondary,
                backgroundColor: context.tokens.color.vsdslColorSecondary,
                textStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                AppPreferences().set(showEULA: false);
                navService.pushNamedAndRemoveUntil('/v3Home');
              },
              child: V3AutoHyphenatingText(S.of(context).v3_eula_agree),
            ),
          ),
        ),
      ],
    );
  }
}
