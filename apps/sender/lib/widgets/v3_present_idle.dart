import 'dart:io';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/demo_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle_button.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class V3PresentIdle extends StatelessWidget {
  V3PresentIdle({super.key});

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
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    DemoProvider demoProvider = Provider.of<DemoProvider>(context);

    return Stack(
      children: [
        if (Platform.isAndroid || Platform.isIOS) _qrCode(context),
        Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _logo(),
                  const Padding(padding: EdgeInsets.only(top: 35)),
                  _inputTextFields(),
                  _nextButton(
                      channelProvider, demoProvider, presentStateProvider),
                ],
              ),
            )),
      ],
    );
  }

  V3PresentIdleButton _nextButton(ChannelProvider channelProvider,
      DemoProvider demoProvider, PresentStateProvider presentStateProvider) {
    return V3PresentIdleButton(
      key: presentBtnKey,
      fixedSize: const Size(300, 48),
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

  Widget _logo() {
    return SvgPicture.asset('assets/images/v3_ic_airsync.svg');
  }

  Widget _qrCode(BuildContext context) {
    return Positioned(
        top: 24,
        left: 8,
        child: Container(
          width: 48,
          height: 48,
          decoration: ShapeDecoration(
            color: context.tokens.color.vsdslColorSurface200,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: context.tokens.color.vsdslColorSurface200,
              ),
              borderRadius: context.tokens.radii.vsdslRadiusFull,
            ),
            shadows: context.tokens.shadow.vsdslShadowNeutralSm,
          ),
          child: IconButton(
            icon: SvgPicture.asset('assets/images/v3_ic_qrcode.svg'),
            onPressed: () {},
          ),
        ));
  }
}
