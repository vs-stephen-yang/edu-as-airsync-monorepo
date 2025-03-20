import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/pref_language_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/utilities/dart_ui_web_fake.dart'
    if (dart.library.ui_web) 'dart:ui_web' as ui_web;
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_cast_flutter/utilities/web_util.dart';
import 'package:display_cast_flutter/widgets/moderator_share.dart';
import 'package:display_cast_flutter/widgets/toast.dart';
import 'package:display_cast_flutter/widgets/v3_moderator_idle_name.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle.dart';
import 'package:display_cast_flutter/widgets/v3_present_present_start.dart';
import 'package:display_cast_flutter/widgets/v3_present_wait_prompt.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3WebMain extends StatelessWidget {
  const V3WebMain({
    super.key,
    required this.presentStateProvider,
    this.scrollTo,
  });

  final PresentStateProvider presentStateProvider;

  final Function()? scrollTo;

  @override
  Widget build(BuildContext context) {
    bool isPresenting =
        (presentStateProvider.currentState == ViewState.presentStart ||
            presentStateProvider.currentState == ViewState.moderatorStart);
    bool isWaiting =
        (presentStateProvider.currentState == ViewState.authorizeWait ||
            presentStateProvider.currentState == ViewState.moderatorWait);
    return SizedBox(
      height: (isPresenting || isWaiting)
          ? MediaQuery.of(context).size.height
          : 700,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isPresenting) const V3PresentStateMachine(),
          if (!isPresenting) ...[
            Row(
              children: [
                if (isBigThan1024(context))
                  Container(
                    width: 460,
                    color: const Color(0xFFEDEEF3),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset('assets/images/ic_web_connection.png'),
                      ],
                    ),
                  ),
                Expanded(
                  child: Container(
                    color: context.tokens.color.vsdswColorSurface100,
                    child: Stack(
                      fit: StackFit.expand,
                      alignment: AlignmentDirectional.center,
                      children: [
                        Positioned(
                          top: 21,
                          right: 40,
                          child: Row(
                            children: [
                              const LanguageShowMenu(),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 5.0,
                                  shadowColor:
                                      context.tokens.color.vsdswColorPrimary,
                                  foregroundColor:
                                      context.tokens.color.vsdswColorOnPrimary,
                                  backgroundColor:
                                      context.tokens.color.vsdswColorPrimary,
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                ),
                                onPressed: () {
                                  scrollTo?.call();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/v3_ic_web_main_download.svg',
                                      width: 16,
                                      height: 16,
                                      colorFilter: ColorFilter.mode(
                                        context
                                            .tokens.color.vsdswColorOnPrimary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    SizedBox(
                                        width: context.tokens.spacing
                                            .vsdswSpacing2xs.left),
                                    AutoSizeText(
                                        S.of(context).v3_main_download),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 82,
                          right: 0,
                          left: 0,
                          child: unsupportedMessage(context),
                        ),
                        const V3PresentStateMachine(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 40,
              top: 16,
              child: SvgPicture.asset('assets/images/ic_logo_airsync.svg'),
            ),
          ],
          if (isWaiting) ...[
            Container(color: context.tokens.color.vsdswColorOpacityNeutralMd),
            const Align(
              alignment: Alignment.center,
              child: V3PresentWaitPrompt(),
            ),
          ],
        ],
      ),
    );
  }

  Widget unsupportedMessage(BuildContext context) {
    bool supportedBrowsers =
        kIsWeb && (ui_web.browser.isChromium || ui_web.browser.isEdge);
    bool showUnsupportedMassage = true;
    return StatefulBuilder(builder: (context, setState) {
      return (showUnsupportedMassage && !supportedBrowsers)
          ? Container(
              height: 48,
              color: const Color(0xFFF67F00),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    S.current.v3_main_web_nonsupport,
                    style: const TextStyle(
                      color: Color(0xFFFFFAEC),
                      fontSize: 14,
                    ),
                  ),
                  const Gap(24),
                  InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      height: 32,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        S.current.v3_main_web_nonsupport_confirm,
                        style: const TextStyle(
                          color: Color(0xFFF67F00),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        showUnsupportedMassage = false;
                      });
                    },
                  ),
                ],
              ),
            )
          : const SizedBox();
    });
  }
}

class V3PresentStateMachine extends StatelessWidget {
  const V3PresentStateMachine({super.key});

  @override
  Widget build(BuildContext context) {
    bool supportedBrowsers =
        kIsWeb && (ui_web.browser.isChromium || ui_web.browser.isEdge);
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context);
    log.info('PresentState: ${presentStateProvider.currentState}');
    switch (presentStateProvider.currentState) {
      case ViewState.idle:
        return V3PresentIdle(supported: supportedBrowsers);
      case ViewState.selectRole:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ChannelProvider channelProvider =
              Provider.of<ChannelProvider>(context, listen: false);
          channelProvider.currentRole = JoinIntentType.present;
          if (channelProvider.moderatorStatus) {
            presentStateProvider.presentModeratorNamePage();
          } else {
            if (channelProvider.isConnectAvailable()) {
              channelProvider.beginBasicMode();
              if (channelProvider.authorizeStatus) {
                presentStateProvider.presentAuthorizeWaitPage();
              }
            } else {
              Toast.makeFeatureReconnectToast(
                  channelProvider.reconnectState,
                  channelProvider.reconnectState ==
                          ChannelReconnectState.reconnecting
                      ? S.of(context).main_feature_reconnecting_toast
                      : S.of(context).main_feature_reconnect_fail_toast);
            }
          }
          AppAnalytics.instance.setMode(EventMode.webrtc);
        });
        return const SizedBox();
      case ViewState.authorizeWait:
        // move to V3WebMain for center in whole browser view.
        return const SizedBox();
      case ViewState.moderatorName:
        return const V3ModeratorIdleName();
      case ViewState.moderatorWait:
        // move to V3WebMain for center in whole browser view.
        return const SizedBox();
      case ViewState.selectScreen:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ChannelProvider channelProvider =
              Provider.of<ChannelProvider>(context, listen: false);
          channelProvider.presentStart(selectedSource: null, systemAudio: true);
        });
        return const SizedBox();
      case ViewState.presentStart:
        return V3PresentPresentStart(isModeratorMode: false);
      case ViewState.moderatorStart:
        return V3PresentPresentStart(isModeratorMode: true);
      case ViewState.moderatorShare:
        return const ModeratorPresentShare();
      default:
        return const SizedBox();
    }
  }
}

class LanguageShowMenu extends StatefulWidget {
  const LanguageShowMenu({super.key});

  @override
  State<StatefulWidget> createState() => _LanguageShowMenuState();
}

class _LanguageShowMenuState extends State<LanguageShowMenu> {
  bool _menuOn = false;

  // This method shows a custom dropdown (using showMenu)
  void _showCustomDropdown(BuildContext context) async {
    setState(() {
      _menuOn = true;
    });

    PrefLanguageProvider prefLanguageProvider =
        Provider.of<PrefLanguageProvider>(context, listen: false);

    // Get the size and position of the button (for dropdown placement)
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    // Calculate the position of the dropdown
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, button.size.height), ancestor: overlay),
        // Lower than the button
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    // Show the menu below the button
    String? newValue = await showMenu<String>(
      context: context,
      position: position.shift(const Offset(0, 5)),
      color: context.tokens.color.vsdswColorSurface100,
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 120),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: prefLanguageProvider.localeMap.entries.map((entry) {
                  return PopupMenuItem<String>(
                    value: entry.key,
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: (entry.key == prefLanguageProvider.language)
                            ? context.tokens.color.vsdswColorTertiary
                            : context.tokens.color.vsdswColorSurface100,
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: (entry.key == prefLanguageProvider.language)
                              ? context.tokens.color.vsdswColorOnSurfaceInverse
                              : context.tokens.color.vsdswColorOnSurface,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        )
      ],
    );

    // If a new language was selected, update the state
    if (newValue != null) {
      prefLanguageProvider.setLanguage(newValue);
    }
    setState(() {
      _menuOn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    PrefLanguageProvider prefLanguageProvider =
        Provider.of<PrefLanguageProvider>(context, listen: false);
    return GestureDetector(
      onTap: () => _showCustomDropdown(context),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: _menuOn
            ? ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: context.tokens.color.vsdswColorSurface300,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                shadows: [
                  BoxShadow(
                    color: context.tokens.color.vsdswColorOutline,
                    blurRadius: 0,
                    offset: const Offset(0, 0),
                    spreadRadius: 4,
                  )
                ],
              )
            : null,
        child: Row(
          children: [
            Icon(
              Icons.language,
              size: 16,
              color: context.tokens.color.vsdswColorOnSurface,
            ),
            const SizedBox(width: 8),
            AutoSizeText(
              prefLanguageProvider.language,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: context.tokens.color.vsdswColorOnSurface,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_sharp,
              size: 16,
              color: context.tokens.color.vsdswColorOnSurface,
            ),
          ],
        ),
      ),
    );
  }
}
