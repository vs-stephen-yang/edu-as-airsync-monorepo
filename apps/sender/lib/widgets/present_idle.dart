import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/demo_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/widgets/present_idle_button.dart';
import 'package:display_cast_flutter/widgets/present_idle_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';

class PresentIdle extends StatelessWidget {
  PresentIdle({super.key});

  final GlobalKey<PresentIdleTextFieldState> fieldKey = GlobalKey();
  final GlobalKey<PresentIdleButtonState> presentBtnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context, listen: false);
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    DemoProvider demoProvider = Provider.of<DemoProvider>(context);
    bool presentBtnEnable = false;
    String displayCode = '', password = '';
    bool isDisplayCodeSelectedFromHistory = false;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        PresentIdleTextField(
          key: fieldKey,
          onFieldChanged: (result) {
            isDisplayCodeSelectedFromHistory =
                result.isDisplayCodeSelectedFromHistory;

            presentBtnEnable = result.enable;
            displayCode = result.displayCode;
            password = result.password;
            presentBtnKey.currentState?.setEnable(result.enable,
                displayCode: result.displayCode, password: result.password);
          },
          onPasswordEnterEvent: (text) {
            if (presentBtnEnable) {
              presentBtnKey.currentState?.onButtonPressed();
            }
          },
        ),
        PresentIdleButton(
          key: presentBtnKey,
          onPressed: () async {
            trackEvent(
              'enter_display_code',
              EventCategory.menu,
              properties: {
                'target': isDisplayCodeSelectedFromHistory ? 'select' : 'type',
              },
            );

            AppAnalytics.instance
                .setGlobalProperty('display_code', displayCode);

            trackEvent('click_connect', EventCategory.session);

            if (!presentBtnEnable) return;
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
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OptionMenu(
              name: S.of(context).main_setting,
              iconWidget: const Icon(
                Icons.settings,
                size: 18,
                color: Colors.white,
              ),
              onTap: () {
                presentStateProvider.presentSettingPage();
              },
            ),
            if (!kIsWeb) const SizedBox(height: 10),
            if (!kIsWeb)
              OptionMenu(
                name: S.of(context).main_device_list,
                iconWidget: const Image(
                  image: Svg('assets/images/ic_quick_connect.svg'),
                ),
                onTap: () {
                  trackEvent('click_device_list', EventCategory.menu);
                  presentStateProvider.presentDeviceListPage();
                },
              ),
          ],
        ),
      ],
    );
  }
}

class OptionMenu extends StatelessWidget {
  const OptionMenu(
      {super.key,
      required this.name,
      required this.iconWidget,
      required this.onTap});

  final String name;
  final Widget iconWidget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 18,
            padding: const EdgeInsets.only(right: 5),
            child: iconWidget,
          ),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppConstants.fontSizeNormal,
            ),
          ),
        ],
      ),
    );
  }
}
