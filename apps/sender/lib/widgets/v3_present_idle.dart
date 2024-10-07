import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/demo_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
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
        AppAnalytics.instance.trackEvent('enter_display_code', properties: {
          'target': isDisplayCodeSelectedFromHistory ? 'select' : 'type',
        });

        AppAnalytics.instance.setGlobalProperty('display_code', displayCode);

        AppAnalytics.instance.trackEvent('click_connect');

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
    return SizedBox(
      height: 32,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Quick connect by',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Color(0xFF2A2A2A),
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: context.tokens.color.vsdswColorSurface600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                shadows: [
                  BoxShadow(
                    color: context.tokens.color.vsdswColorOpacityNeutralSm,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                          context.tokens.color.vsdswColorOnPrimary,
                          BlendMode.srcIn),
                      'assets/images/ic_device_list_screen.svg'),
                  const SizedBox(width: 4),
                  Text(
                    'Device List',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.tokens.color.vsdswColorOnPrimary,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 0.09,
                      letterSpacing: 0.28,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              AppAnalytics.instance.trackEvent('click_device_list');
              presentStateProvider.presentDeviceListPage();
            },
          ),
        ],
      ),
    );
  }
}
