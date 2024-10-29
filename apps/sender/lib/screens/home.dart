import 'dart:async';
import 'dart:io' show Platform, exit;
import 'dart:ui';

import 'package:display_cast_flutter/demo/present_present_start_demo.dart';
import 'package:display_cast_flutter/demo/present_select_role_demo.dart';
import 'package:display_cast_flutter/demo/remote_screen_widget_demo.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/demo_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/app_colors.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_cast_flutter/utilities/updater_windows.dart';
import 'package:display_cast_flutter/utilities/v3_network_status_detector.dart';
import 'package:display_cast_flutter/utilities/v3_update_manager.dart';
import 'package:display_cast_flutter/widgets/app_retain.dart';
import 'package:display_cast_flutter/widgets/bottom_bar.dart';
import 'package:display_cast_flutter/widgets/device_list.dart';
import 'package:display_cast_flutter/widgets/language.dart';
import 'package:display_cast_flutter/widgets/moderator_idle.dart';
import 'package:display_cast_flutter/widgets/moderator_present_start.dart';
import 'package:display_cast_flutter/widgets/moderator_share.dart';
import 'package:display_cast_flutter/widgets/moderator_wait.dart';
import 'package:display_cast_flutter/widgets/present_idle.dart';
import 'package:display_cast_flutter/widgets/present_present_start.dart';
import 'package:display_cast_flutter/widgets/present_select_role.dart';
import 'package:display_cast_flutter/widgets/present_select_screen.dart';
import 'package:display_cast_flutter/widgets/remote_screen_widget.dart';
import 'package:display_cast_flutter/widgets/settings.dart';
import 'package:display_cast_flutter/widgets/title_bar.dart';
import 'package:display_cast_flutter/widgets/toast.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:provider/provider.dart';
import "package:universal_html/html.dart" as html;
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State createState() => _HomeStates();
}

class _HomeStates extends State<Home> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: _handleResume,
      onExitRequested: _handleExitRequest,
    );

    html.window.onBeforeUnload.listen((event) async {
      await _presentEndOnExit();
    });
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();

    super.dispose();
  }

  void _handleResume() {
    if (_shouldCheckUpdate()) {
      _checkUpdateVersion(context).then((value) {
        if (value != CompareVersionResult.noUpdate) {
          _showUpdateDialog(context, value);
        }
      });
    }
  }

  bool _shouldCheckUpdate() {
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context, listen: false);
    return !kIsWeb &&
        !Platform.isWindows &&
        !Platform.isMacOS &&
        presentStateProvider.currentState == ViewState.idle &&
        V3NetworkStatusDetector().isConnected();
  }

  Future<AppExitResponse> _handleExitRequest() {
    final completer = Completer<AppExitResponse>();

    () async {
      await _presentEndOnExit();
      completer.complete(AppExitResponse.exit);
    }();

    return completer.future;
  }

  Future<void> _presentEndOnExit() async {
    final channelProvider = Provider.of<ChannelProvider>(
      context,
      listen: false,
    );

    await channelProvider.presentStop();
    await channelProvider.presentEnd(goIdleState: false);

    // Workaround:
    // adding a short delay to give the receiver sufficient time to receive the close message.
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!isSupportPlatform()) {
        _showNotSupportDialog();
        return;
      }

      if (!kIsWeb && V3NetworkStatusDetector().isConnected()) {
        _checkUpdateVersion(context).then((value) {
          if (value != CompareVersionResult.noUpdate) {
            // show update dialog
            _showUpdateDialog(context, value);
          }
        });
      }
    });

    return AppRetain(
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.7),
                  radius: 1,
                  colors: [
                    AppColors.homeBackground,
                    Colors.black,
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const TitleBar(),
                  const BottomBar(),
                  Consumer3<PresentStateProvider, ChannelProvider, DemoProvider>(
                      builder: (context, present, channel, demo, child) {
                    if (!demo.isDemoMode) {
                      log.info('PresentState: ${present.currentState}');
                      if (!kIsWeb) {
                        FlutterWindowClose.setWindowShouldCloseHandler(
                            () async {
                          await channel.presentStop();
                          await channel.presentEnd(goIdleState: false);
                          return true;
                        });
                      }

                      switch (present.currentState) {
                        case ViewState.idle:
                          return PresentIdle();
                        case ViewState.selectRole:
                          if (kIsWeb) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              channel.currentRole = JoinIntentType.present;
                              if (channel.moderatorStatus) {
                                present.presentModeratorNamePage();
                              } else {
                                if (channel.isConnectAvailable()) {
                                  channel.beginBasicMode();
                                } else {
                                  Toast.makeFeatureReconnectToast(
                                      channel.reconnectState,
                                      channel.reconnectState ==
                                          ChannelReconnectState.reconnecting
                                          ? S.of(context)
                                          .main_feature_reconnecting_toast
                                          : S.of(context)
                                          .main_feature_reconnect_fail_toast);
                                }
                              }
                            });
                            return const SizedBox();
                          } else {
                            return const PresentSelectRole();
                          }
                        case ViewState.moderatorName:
                          return const ModeratorIdle();
                        case ViewState.moderatorWait:
                          return const ModeratorWait();
                        case ViewState.selectScreen:
                          return const PresentSelectScreen();
                        case ViewState.presentStart:
                          return PresentPresentStart();
                        case ViewState.moderatorStart:
                          return ModeratorPresentStart();
                        case ViewState.moderatorShare:
                          return const ModeratorPresentShare();
                        case ViewState.remoteScreen:
                          return const RemoteScreenWidget();
                        case ViewState.settings:
                          return const Settings();
                        case ViewState.language:
                          return const Language();
                        case ViewState.deviceList:
                          return const DeviceList();
                        default:
                          return const SizedBox();
                      }
                    } else {
                      switch (demo.state) {
                        case DemoViewState.off:
                          return const SizedBox();
                        case DemoViewState.selectRole:
                          return const PresentSelectRoleDemo();
                        case DemoViewState.presentStart:
                          return PresentPresentStartDemo();
                        case DemoViewState.remoteScreen:
                          return const RemoteScreenDemo();
                      }
                    }
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isDialogShowing = false;

  void _showUpdateDialog(BuildContext context, CompareVersionResult status) {
    // check dialog
    if (_isDialogShowing) {
      return;
    }
    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(S.of(context).main_update_title),
          content: SizedBox(
            width: 100,
            height: 100,
            child: Column(
              children: [
                if (Platform.isIOS || Platform.isMacOS) Text(S.of(context).main_update_description_apple),
                if (Platform.isAndroid) Text(S.of(context).main_update_description_android),
                if (Platform.isWindows) Text(S.of(context).main_update_description_windows),
              ],
            ),
          ),
          actions: <Widget>[
            if (status == CompareVersionResult.userChoose)
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), // 设置按钮背景颜色
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey), // 设置按钮文字颜色
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 设置按钮圆角
                      side: const BorderSide(color: Colors.grey), // 设置按钮边框
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(S.of(context).main_update_deny_button),
              ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // 设置按钮背景颜色
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // 设置按钮文字颜色
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // 设置按钮圆角
                    side: const BorderSide(color: Colors.blue), // 设置按钮边框
                  ),
                ),
              ),
              onPressed: () async {
                if (status == CompareVersionResult.userChoose) {
                  Navigator.of(context).pop();
                }
                if (Platform.isAndroid) {
                  launchUrl( Uri.parse('https://play.google.com/store/apps/details?id=com.viewsonic.display.cast'));
                } else if (Platform.isIOS) {
                  launchUrl( Uri.parse('https://apps.apple.com/us/app/airsync-sender/id6453759985'));
                } else if (Platform.isMacOS) {
                  launchUrl( Uri.parse('macappstore://apps.apple.com/app/airsync-sender/id6453759985'));
                } else if (Platform.isWindows) {
                  try {
                    await installUpdates();
                    exit(0);
                  } on UpdateErrorExecption catch (e) {
                    _showUpdateErrorDialog(context, e);
                  }
                }
              },
              child: Text(S.of(context).main_update_positive_button),
            ),
          ],
        );
      },
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  void _showUpdateErrorDialog(BuildContext context, UpdateErrorExecption e) {
    showDialog(context: context, builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(S.of(context).main_update_error_title),
            content: SizedBox(
              width: 100,
              height: 100,
              child: Column(
                children: [
              Text('${S.of(context).main_update_error_type}: ${e.error.name} \n${S.of(context).main_update_error_detail}: ${e.details.toString()}'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // 设置按钮背景颜色
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // 设置按钮文字颜色
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 设置按钮圆角
                      side: const BorderSide(color: Colors.blue), // 设置按钮边框
                    ),
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: Text(S.of(context).device_list_enter_pin_ok),
              ),
            ],
          );
        });
  }

  Future<CompareVersionResult> _checkUpdateVersion(BuildContext context) async {
    String version = AppConfig.of(context)?.appVersion;
    String? api = AppConfig.of(context)?.settings.appUpdateVersionEndpoint;
    if (api == null) return CompareVersionResult.noUpdate;

    return V3UpdateManager().getVersion(api, version);
  }

  bool isSupportPlatform() {
    if(kIsWeb) {
      return defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS;
    } else {
      return true;
    }
  }

  void _showNotSupportDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(S.of(context).main_notice_title),
          content: SizedBox(
            width: 100,
            height: 100,
            child: Column(
              children: [
                Text(S.of(context).main_notice_not_support_description),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // 设置按钮背景颜色
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // 设置按钮文字颜色
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // 设置按钮圆角
                    side: const BorderSide(color: Colors.blue), // 设置按钮边框
                  ),
                ),
              ),
              onPressed: () async {
                if (defaultTargetPlatform == TargetPlatform.android) {
                  launchUrl( Uri.parse('https://play.google.com/store/apps/details?id=com.viewsonic.display.cast&pcampaignid=web_share'));
                } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                  launchUrl( Uri.parse('https://apps.apple.com/tw/app/airsync-sender/id6453759985'));
                }
              },
              child: Text(S.of(context).main_notice_positive_button),
            ),
          ],
        );
      },
    );
  }
}
