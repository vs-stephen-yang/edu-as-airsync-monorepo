import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/demo_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle_button.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class V3PresentIdleMain extends StatefulWidget {
  const V3PresentIdleMain({super.key});

  @override
  V3PresentIdleMainState createState() => V3PresentIdleMainState();
}

class V3PresentIdleMainState extends State<V3PresentIdleMain> {
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

    return Column(
      children: [
        _inputTextFields(),
        _nextButton(channelProvider, demoProvider, presentStateProvider),
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
}
