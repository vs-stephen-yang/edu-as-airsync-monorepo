import 'dart:async';
import 'dart:math';

import 'package:app_links/app_links.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/providers/v3_demo_provider.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:display_cast_flutter/utilities/v3_toast.dart';
import 'package:display_cast_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_cast_flutter/widgets/v3_message_dialog.dart';
import 'package:display_cast_flutter/widgets/v3_present_device_list_button.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle_audio_driver_warning.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle_button.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle_text_field.dart';
import 'package:display_cast_flutter/widgets/v3_scroll_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3PresentIdle extends StatefulWidget {
  const V3PresentIdle({super.key, this.supported = true});

  final bool supported;

  @override
  State<StatefulWidget> createState() => _V3PresentIdleState();
}

class _V3PresentIdleState extends State<V3PresentIdle> {
  final GlobalKey<V3PresentIdleTextFieldState> fieldKey = GlobalKey();
  final GlobalKey<V3PresentIdleButtonState> presentBtnKey = GlobalKey();

  bool nextBtnEnable = false;
  String displayCode = '';
  String password = '';
  bool isDisplayCodeSelectedFromHistory = false;
  bool isSessionFullDialogOnScreen = false;
  bool isScreenFullDialogOnScreen = false;
  bool isModeratorExitedDialogOnScreen = false;
  bool isReceiverRemoteScreenBusyDialogOnScreen = false;

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
    AppAnalytics.instance.setMode(null);
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      String? quickConnectValue = uri.queryParameters['quick_connect'];
      if (quickConnectValue != null) {
        List<String> parts = quickConnectValue.split('@');
        if (parts.length == 3) {
          String code = parts[0];
          String otp = parts[1];
          // String ver = parts[2];
          await startConnect(displayCode: code, otp: otp);
        }
      }
    });
  }

  Future<void> startConnect(
      {required String displayCode, required String otp}) async {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context, listen: false);

    trackEvent('enter_display_code', EventCategory.menu, target: 'type');
    AppAnalytics.instance.setGlobalProperty('display_code', displayCode);
    trackEvent('click_connect', EventCategory.menu);

    await channelProvider.presentEnd(goIdleState: false);
    await channelProvider.startConnect(
      formattedDisplayCode: displayCode,
      otp: otp,
      presentStateProvider: presentStateProvider,
      qrCallback: (success) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context, listen: false);
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    V3DemoProvider demoProvider = Provider.of<V3DemoProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((callback) {
      if (channelProvider.channelConnectError != null) {
        fieldKey.currentState
            ?.handleConnectErrorMessage(channelProvider.channelConnectError!);
        presentBtnKey.currentState?.setEnable(false);
        presentBtnKey.currentState?.setLoadingState(false);
        channelProvider.resetMessage();
      }
      if (channelProvider.isJoinDisplayRejected &&
          !isSessionFullDialogOnScreen) {
        channelProvider.isJoinDisplayRejected = false;
        _showSessionFullDialog();
      }
      if (channelProvider.isPresentRejected && !isScreenFullDialogOnScreen) {
        channelProvider.isPresentRejected = false;
        _showScreenFullDialog();
      }
      if (channelProvider.isModeratorExitedRejected &&
          !isModeratorExitedDialogOnScreen) {
        channelProvider.isModeratorExitedRejected = false;
        _showModeratorExitedDialog();
      }
      if (channelProvider.isReceiverRemoteScreenBusyRejected) {
        channelProvider.isReceiverRemoteScreenBusyRejected = false;
        _showReceiverRemoteScreenBusyDialog();
      }
      if (channelProvider.totalSharingTime.isNotEmpty) {
        V3Toast().makeSharingTimeToast(
            context,
            S.of(context).v3_present_end_information,
            channelProvider.totalSharingTime);
        channelProvider.totalSharingTime = '';
      }
    });

    return Stack(
      fit: StackFit.expand,
      alignment: AlignmentDirectional.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const V3PresentIdleAudioDriverWarning(),
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                final sc = ScrollController();
                final minHeight = WebRTC.platformIsMobile
                    ? AppConstants.mobileMinHeight
                    : AppConstants.windowsMinHeight;
                final double gatHeight = WebRTC.platformIsMobile ? 40 : 60;
                final double gap = max(minHeight - constraints.maxHeight, 0) > 0
                    ? 0
                    : gatHeight;
                return V3Scrollbar(
                  controller: sc,
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    controller: sc,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                        minWidth: double.infinity,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (kIsWeb) ...[
                            V3AutoHyphenatingText(
                              S.of(context).v3_main_present_title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                color: context.tokens.color.vsdswColorOnSurface,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.32,
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(bottom: 8)),
                            V3AutoHyphenatingText(
                              S.of(context).v3_main_present_subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: context
                                    .tokens.color.vsdswColorOnSurfaceVariant,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.18,
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(top: 40)),
                          ],
                          if (!kIsWeb) ...[
                            ExcludeSemantics(
                              child: SvgPicture.asset(
                                  'assets/images/v3_ic_airsync.svg'),
                            ),
                            Gap(35),
                          ],
                          if (!kIsWeb) ...[
                            Gap(gap),
                            buildDeviceListButton(presentStateProvider),
                            const Gap(16),
                            SizedBox(
                              width: 300,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: context
                                          .tokens.color.vsdswColorOutline,
                                    ),
                                  ),
                                  const Gap(12),
                                  Text(
                                    S.of(context).v3_main_present_or,
                                    style: TextStyle(
                                        fontSize: 15,
                                        height: 1.5,
                                        color: context.tokens.color
                                            .vsdswColorOnSurfaceVariant),
                                    textHeightBehavior: TextHeightBehavior(
                                      applyHeightToFirstAscent: false,
                                      // Disable height for ascent
                                      applyHeightToLastDescent:
                                          true, // Apply height for descent
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Gap(12),
                                  Expanded(
                                    child: Divider(
                                      color: context
                                          .tokens.color.vsdswColorOutline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(16),
                          ],
                          _inputTextFields(),
                          _nextButton(channelProvider, demoProvider,
                              presentStateProvider),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        if (kIsWeb) ...[
          Positioned(
            bottom: 24,
            child: Align(
              alignment: Alignment.center,
              // To avoid misinterpreting the hyphen (“-”), use plain text instead.
              child: Text(
                'v${AppConfig.of(context)?.appVersion}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: context.tokens.color.vsdswColorOnSurfaceVariant,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.0,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  V3PresentIdleButton _nextButton(ChannelProvider channelProvider,
      V3DemoProvider demoProvider, PresentStateProvider presentStateProvider) {
    return V3PresentIdleButton(
      key: presentBtnKey,
      fixedSize: const Size(300, 48),
      buttonText: S.of(context).v3_main_present_action,
      buttonLabel: S.of(context).v3_lbl_main_present_action,
      buttonIdentifier: 'v3_qa_main_present_action',
      onPressed: () async {
        trackEvent(
          'enter_display_code',
          EventCategory.menu,
          target: isDisplayCodeSelectedFromHistory ? 'select' : 'type',
        );

        AppAnalytics.instance.setGlobalProperty('display_code', displayCode);

        trackEvent('click_connect', EventCategory.menu);

        if (!nextBtnEnable) return;
        await channelProvider.presentEnd(goIdleState: false);
        if (displayCode == "00000000000" && password == "0000") {
          demoProvider.isDemoMode = true;
          unawaited(demoProvider.presentSelectRoleDemoPage());
        } else {
          channelProvider.startConnect(
              formattedDisplayCode: displayCode,
              otp: password,
              presentStateProvider: presentStateProvider);
        }
      },
    );
  }

  V3PresentIdleTextField _inputTextFields() {
    return V3PresentIdleTextField(
      key: fieldKey,
      widthTextField: 300,
      enable: widget.supported,
      onFieldChanged: (result) {
        isDisplayCodeSelectedFromHistory =
            result.isDisplayCodeSelectedFromHistory;
        nextBtnEnable = result.enable && widget.supported;
        displayCode = result.displayCode;
        password = result.password;
        presentBtnKey.currentState?.setEnable(result.enable && widget.supported,
            displayCode: result.displayCode, password: result.password);
      },
      onPasswordEnterEvent: (text) {
        if (nextBtnEnable) {
          presentBtnKey.currentState?.onButtonPressed();
        }
      },
    );
  }

  Widget buildDeviceListButton(PresentStateProvider presentStateProvider) {
    return V3PresentDeviceListButton(
      onTap: () {
        trackEvent('click_device_list', EventCategory.menu);
        presentStateProvider.presentDeviceListPage();
      },
    );
  }

  _showSessionFullDialog() async {
    isSessionFullDialogOnScreen = true;
    FocusScope.of(context).unfocus();
    await showDialog(
      context: context,
      builder: (context) {
        return V3MessageDialog(
          stringTitle: S.of(context).v3_present_session_full,
          stringContent: S.of(context).v3_present_session_full_description,
          stringAction: S.of(context).v3_present_session_full_action,
        );
      },
    ).then((_) {
      isSessionFullDialogOnScreen = false;
      setState(() {});
    });
  }

  _showScreenFullDialog() async {
    isScreenFullDialogOnScreen = true;
    FocusScope.of(context).unfocus();
    await showDialog(
      context: context,
      builder: (context) {
        return V3MessageDialog(
          stringTitle: S.of(context).v3_present_screen_full,
          stringContent: S.of(context).v3_present_screen_full_description,
          stringAction: S.of(context).v3_present_screen_full_action,
        );
      },
    ).then((_) {
      isScreenFullDialogOnScreen = false;
      setState(() {});
    });
  }

  _showModeratorExitedDialog() async {
    isModeratorExitedDialogOnScreen = true;
    FocusScope.of(context).unfocus();
    await showDialog(
      context: context,
      builder: (context) {
        return V3MessageDialog(
          stringTitle: S.of(context).v3_present_moderator_exited,
          stringContent: S.of(context).v3_present_moderator_exited_description,
          stringAction: S.of(context).v3_present_moderator_exited_action,
        );
      },
    ).then((_) {
      isModeratorExitedDialogOnScreen = false;
      setState(() {});
    });
  }

  _showReceiverRemoteScreenBusyDialog() async {
    isReceiverRemoteScreenBusyDialogOnScreen = true;
    FocusScope.of(context).unfocus();
    await showDialog(
      context: context,
      builder: (context) {
        return V3MessageDialog(
          stringTitle: S.of(context).v3_receiver_remote_screen_busy_title,
          stringContent:
              S.of(context).v3_receiver_remote_screen_busy_description,
          stringAction: S.of(context).v3_receiver_remote_screen_busy_action,
        );
      },
    ).then((_) {
      isReceiverRemoteScreenBusyDialogOnScreen = false;
      presentBtnKey.currentState?.setEnable(false);
      presentBtnKey.currentState?.setLoadingState(false);
      setState(() {});
    });
  }
}
