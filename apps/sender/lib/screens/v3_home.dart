import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/screens/v3_home_app.dart';
import 'package:display_cast_flutter/screens/v3_home_web.dart';
import 'package:display_cast_flutter/utilities/audio_switch_manager.dart';
import 'package:display_cast_flutter/utilities/v3_network_status_detector.dart';
import 'package:display_cast_flutter/utilities/v3_update_manager.dart';
import 'package:display_cast_flutter/widgets/app_retain.dart';
import 'package:display_cast_flutter/widgets/v3_exit_dialog.dart';
import 'package:display_cast_flutter/widgets/v3_scroll_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:provider/provider.dart';
import "package:universal_html/html.dart" as html;
import 'package:url_launcher/url_launcher.dart';

class V3Home extends StatefulWidget {
  const V3Home({super.key});

  @override
  State<StatefulWidget> createState() => _V3HomeState();
}

class _V3HomeState extends State<V3Home> {
  late final AppLifecycleListener _lifecycleListener;
  late Future<void> initOperation;
  var _alertShowing = false;

  AudioSwitchManager? _audioSwitchManager;

  @override
  void initState() {
    super.initState();

    _audioSwitchManager = context.read<AudioSwitchManager>();

    _lifecycleListener = AppLifecycleListener(
      onResume: _handleResume,
      onExitRequested: _handleExitRequest,
    );
    initOperation = initHyphenation();

    if (!kIsWeb &&
        (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      FlutterWindowClose.setWindowShouldCloseHandler(() async {
        if (_alertShowing) return false;
        _alertShowing = true;
        return await showDialog(
            context: context,
            builder: (context) {
              return V3ExitDialog();
            }).then((value) async {
          if (value) {
            await _handleExitRequest();
          }
          _alertShowing = false;
          return value;
        });
      });
    } else {
      html.window.onBeforeUnload.listen((event) async {
        await _handleExitRequest();
      });
    }
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!_isWebSupportPlatform()) {
        _showNotSupportDialog();
        return;
      }

      if (!kIsWeb && V3NetworkStatusDetector().isConnected()) {
        V3UpdateManager().checkUpdateVersion(context, (value) {
          if (value != CompareVersionResult.noUpdate) {
            if (context.mounted) {
              V3UpdateManager().showUpdateDialog(context, value);
            }
          }
        });
      }
    });
    return AppRetain(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: FutureBuilder(
            future: initOperation,
            builder: (_, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return kIsWeb ? V3HomeWeb() : V3HomeApp();
              } else {
                return CircularProgressIndicator();
              }
            }),
      ),
    );
  }

  void _handleResume() {
    if (_shouldCheckUpdate()) {
      V3UpdateManager().checkUpdateVersion(context, (value) {
        if (value != CompareVersionResult.noUpdate) {
          if (context.mounted) {
            V3UpdateManager().showUpdateDialog(context, value);
          }
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

      await _audioSwitchManager?.restoreToDefaultAudioOutput();

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

  bool _isWebSupportPlatform() {
    if (kIsWeb) {
      return defaultTargetPlatform != TargetPlatform.android &&
          defaultTargetPlatform != TargetPlatform.iOS;
    } else {
      return true;
    }
  }

  void _showNotSupportDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final sc = ScrollController();
        return AlertDialog(
          backgroundColor: Colors.white,
          // Can not use V3AutoHyphenatingText
          title: Text(S.of(context).main_notice_title),
          content: SizedBox(
            width: 100,
            height: 100,
            child: V3Scrollbar(
              controller: sc,
              child: SingleChildScrollView(
                controller: sc,
                // Can not use V3AutoHyphenatingText
                child: Text(S.of(context).main_notice_not_support_description),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                // 设置按钮背景颜色
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                // 设置按钮文字颜色
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // 设置按钮圆角
                    side: const BorderSide(color: Colors.blue), // 设置按钮边框
                  ),
                ),
              ),
              onPressed: () async {
                if (defaultTargetPlatform == TargetPlatform.android) {
                  unawaited(launchUrl(Uri.parse(
                      'https://play.google.com/store/apps/details?id=com.viewsonic.display.cast&pcampaignid=web_share')));
                } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                  unawaited(launchUrl(Uri.parse(
                      'https://apps.apple.com/tw/app/airsync-sender/id6453759985')));
                }
              },
              // Can not use V3AutoHyphenatingText
              child: Text(S.of(context).main_notice_positive_button),
            ),
          ],
        );
      },
    );
  }
}
