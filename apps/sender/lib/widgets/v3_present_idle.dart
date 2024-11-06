import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/demo_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/v3_toast.dart';
import 'package:display_cast_flutter/widgets/v3_message_dialog.dart';
import 'package:display_cast_flutter/widgets/v3_present_device_list_button.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle_button.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3PresentIdle extends StatefulWidget {
  const V3PresentIdle({super.key});

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

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
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
    AppAnalytics.instance
        .trackEvent('enter_display_code', EventCategory.menu, target: 'type');
    AppAnalytics.instance.setGlobalProperty('display_code', displayCode);
    AppAnalytics.instance.trackEvent('click_connect', EventCategory.menu);

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
    DemoProvider demoProvider = Provider.of<DemoProvider>(context);

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
        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
          Positioned(
            top: 24,
            left: 8,
            child: Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: context.tokens.color.vsdswColorSurface200,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: context.tokens.color.vsdswColorSurface200,
                  ),
                  borderRadius: context.tokens.radii.vsdswRadiusFull,
                ),
                shadows: context.tokens.shadow.vsdswShadowNeutralLg,
              ),
              child: IconButton(
                icon: SvgPicture.asset('assets/images/v3_ic_qrcode.svg'),
                onPressed: () {
                  Provider.of<PresentStateProvider>(context, listen: false)
                      .presentQrScannerPage();
                },
              ),
            ),
          ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (kIsWeb) ...[
              AutoSizeText(
                S.of(context).v3_main_present_title,
                style: TextStyle(
                  fontSize: 32,
                  color: context.tokens.color.vsdswColorOnSurface,
                  fontWeight: FontWeight.w700,
                  // height: 0.04,
                  letterSpacing: -0.32,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 8)),
              AutoSizeText(
                S.of(context).v3_main_present_subtitle,
                style: TextStyle(
                  fontSize: 18,
                  color: context.tokens.color.vsdswColorOnSurfaceVariant,
                  fontWeight: FontWeight.w400,
                  // height: 0.10,
                  letterSpacing: -0.18,
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 40)),
            ],
            if (!kIsWeb) ...[
              SvgPicture.asset('assets/images/v3_ic_airsync.svg'),
              const Padding(padding: EdgeInsets.only(top: 35)),
            ],
            _inputTextFields(),
            _nextButton(channelProvider, demoProvider, presentStateProvider),
            if (!kIsWeb) ...[
              Gap((Platform.isAndroid || Platform.isIOS) ? 40 : 60),
              buildDeviceListButton(presentStateProvider),
            ],
          ],
        ),
      ],
    );
  }

  V3PresentIdleButton _nextButton(ChannelProvider channelProvider,
      DemoProvider demoProvider, PresentStateProvider presentStateProvider) {
    return V3PresentIdleButton(
      key: presentBtnKey,
      fixedSize: const Size(300, 48),
      buttonText: S.of(context).v3_main_present_action,
      onPressed: () async {
        AppAnalytics.instance.trackEvent(
          'enter_display_code',
          EventCategory.menu,
          target: isDisplayCodeSelectedFromHistory ? 'select' : 'type',
        );

        AppAnalytics.instance.setGlobalProperty('display_code', displayCode);

        AppAnalytics.instance.trackEvent('click_connect', EventCategory.menu);

        if (!nextBtnEnable) return;
        await channelProvider.presentEnd(goIdleState: false);
        if (displayCode == "00000000000" && password == "0000") {
          demoProvider.isDemoMode = true;
          demoProvider.presentSelectRoleDemoPage();
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
      onFieldChanged: (result) {
        isDisplayCodeSelectedFromHistory =
            result.isDisplayCodeSelectedFromHistory;

        nextBtnEnable = result.enable;
        displayCode = result.displayCode;
        password = result.password;
        presentBtnKey.currentState?.setEnable(result.enable,
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
        AppAnalytics.instance
            .trackEvent('click_device_list', EventCategory.menu);
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
}
