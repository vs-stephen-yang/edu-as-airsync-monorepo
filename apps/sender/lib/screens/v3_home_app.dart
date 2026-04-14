import 'dart:io';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/demo/v3_present_present_start_demo.dart';
import 'package:display_cast_flutter/demo/v3_present_select_role_demo.dart';
import 'package:display_cast_flutter/demo/v3_remote_screen_widget_demo.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/providers/settings_provider.dart';
import 'package:display_cast_flutter/providers/v3_demo_provider.dart';
import 'package:display_cast_flutter/screens/v3_setting_menu_app.dart';
import 'package:display_cast_flutter/screens/v3_setting_menu_desktop.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_cast_flutter/widgets/V3_focus.dart';
import 'package:display_cast_flutter/widgets/v3_background.dart';
import 'package:display_cast_flutter/widgets/v3_debug_invisible_button.dart';
import 'package:display_cast_flutter/widgets/v3_device_list.dart';
import 'package:display_cast_flutter/widgets/v3_moderator_idle_name.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle.dart';
import 'package:display_cast_flutter/widgets/v3_present_present_start.dart';
import 'package:display_cast_flutter/widgets/v3_present_select_role.dart';
import 'package:display_cast_flutter/widgets/v3_present_select_screen.dart';
import 'package:display_cast_flutter/widgets/v3_present_wait_prompt.dart';
import 'package:display_cast_flutter/widgets/v3_qrcode_scan.dart';
import 'package:display_cast_flutter/widgets/v3_remote_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class V3HomeApp extends StatelessWidget {
  const V3HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Consumer2<PresentStateProvider, V3DemoProvider>(
            builder: (context, presentStateProvider, demoProvider, child) {
          return SingleChildScrollView(
            reverse: true,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // 加上鍵盤高度
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: query.size.height -
                    query.padding.top -
                    query.padding.bottom,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  const V3Background(),
                  V3PresentStateMachine(
                    presentStateProvider: presentStateProvider,
                    demoProvider: demoProvider,
                  ),
                  if (presentStateProvider.currentState == ViewState.idle &&
                      (demoProvider.state == V3DemoViewState.idle ||
                          demoProvider.state == V3DemoViewState.off)) ...[
                    const V3DebugInvisibleButton(),
                    const QRCodeConnect(),
                    const SettingMenu(),
                  ]
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class V3PresentStateMachine extends StatelessWidget {
  const V3PresentStateMachine({
    super.key,
    required this.presentStateProvider,
    required this.demoProvider,
  });

  final PresentStateProvider presentStateProvider;
  final V3DemoProvider demoProvider;

  @override
  Widget build(BuildContext context) {
    if (!demoProvider.isDemoMode) {
      log.info('PresentState: ${presentStateProvider.currentState}');

      switch (presentStateProvider.currentState) {
        case ViewState.idle:
          return const V3PresentIdle();
        case ViewState.selectRole:
          return const V3PresentSelectRole();
        case ViewState.authorizeWait:
          return const V3PresentWaitPrompt();
        case ViewState.moderatorName:
          return const V3ModeratorIdleName();
        case ViewState.moderatorWait:
          return const V3PresentWaitPrompt();
        case ViewState.selectScreen:
          return const V3PresentSelectScreen();
        case ViewState.presentStart:
          return const V3PresentPresentStart(isModeratorMode: false);
        case ViewState.moderatorStart:
          return const V3PresentPresentStart(isModeratorMode: true);
        case ViewState.moderatorShare:
          return const V3RemoteScreen(isModeratorShare: true);
        case ViewState.remoteScreen:
          return const V3RemoteScreen(isModeratorShare: false);
        case ViewState.deviceList:
          return const V3DeviceList();
        case ViewState.qrScanner:
          return const V3QRcodeScan();
        default:
          return const SizedBox();
      }
    } else {
      switch (demoProvider.state) {
        case V3DemoViewState.off:
          return const SizedBox();
        case V3DemoViewState.selectRole:
          return const V3PresentSelectRoleDemo();
        case V3DemoViewState.presentStart:
          return const V3PresentPresentStartDemo();
        case V3DemoViewState.remoteScreen:
          return const V3RemoteScreenDemo();
        case V3DemoViewState.idle:
          return const V3PresentIdle();
      }
    }
  }
}

class QRCodeConnect extends StatelessWidget {
  const QRCodeConnect({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      return Positioned(
        top: 24,
        left: 8,
        child: V3Focus(
          label: S.of(context).v3_lbl_qr_code,
          identifier: 'v3_qa_qr_code',
          button: true,
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
              shadows: context.tokens.shadow.vsdswShadowNeutralSm,
            ),
            child: ExcludeSemantics(
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/images/v3_ic_qrcode.svg',
                ),
                onPressed: () {
                  Provider.of<PresentStateProvider>(context, listen: false)
                      .presentQrScannerPage();
                },
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

class SettingMenu extends StatelessWidget {
  const SettingMenu({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = Platform.isAndroid || Platform.isIOS;
    return Positioned(
      left: isMobile ? null : 24,
      top: isMobile ? 24 : null,
      right: isMobile ? 8 : null,
      bottom: isMobile ? null : 24,
      child: V3Focus(
        label: S.of(context).v3_lbl_setting,
        identifier: 'v3_qa_setting',
        button: true,
        child: Container(
          width: 48,
          height: 48,
          decoration: ShapeDecoration(
            color: context.tokens.color.vsdswColorSurface900,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: context.tokens.color.vsdswColorSurface900,
              ),
              borderRadius: context.tokens.radii.vsdswRadiusFull,
            ),
            shadows: context.tokens.shadow.vsdswShadowNeutralSm,
          ),
          child: ExcludeSemantics(
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/images/v3_ic_setting.svg',
                excludeFromSemantics: true,
              ),
              onPressed: () {
                _showOptionsMenuDialog(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  _showOptionsMenuDialog(BuildContext context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      settingsProvider.setPage(SettingPageState.appHome);
      showGeneralDialog(
        context: context,
        pageBuilder: (_, __, ___) {
          return const V3SettingMenuApp();
        },
      );
    } else {
      settingsProvider.setPage(SettingPageState.language);
      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (_) {
          return const V3SettingMenuDesktop();
        },
      );
    }
  }
}
