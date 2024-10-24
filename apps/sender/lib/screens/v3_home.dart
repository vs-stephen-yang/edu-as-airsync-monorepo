import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/screens/v3_home_app.dart';
import 'package:display_cast_flutter/screens/v3_home_web.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/version_update.dart';
import 'package:display_cast_flutter/widgets/app_retain.dart';
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
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: _handleResume,
      onExitRequested: _handleExitRequest,
    );

    if (!kIsWeb) {
      FlutterWindowClose.setWindowShouldCloseHandler(() async {
        await _handleExitRequest();
        return true;
      });
    }

    html.window.onBeforeUnload.listen((event) async {
      await _handleExitRequest();
    });
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

      if (!kIsWeb) {
        _checkUpdateVersion(context).then((value) {
          if (value != CompareVersionResult.none) {
            // show update dialog
            if (context.mounted) {
              _showUpdateDialog(context, value);
            }
          }
        });
      }
    });
    return const AppRetain(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: kIsWeb ? V3HomeWeb() : V3HomeApp(),
      ),
    );
  }

  void _handleResume() {
    if (_shouldCheckUpdate()) {
      _checkUpdateVersion(context).then((value) {
        if (value != CompareVersionResult.none) {
          if (context.mounted) {
            _showUpdateDialog(context, value);
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
        presentStateProvider.currentState == ViewState.idle;
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

  void _showUpdateDialog(BuildContext context, CompareVersionResult status) {
    // check dialog
    if (_isDialogShowing) {
      return;
    }
    _isDialogShowing = true;

    if (Platform.isIOS) {
      showUpdateDialogIos(context, status).then((_) {
        _isDialogShowing = false;
      });
    } else if (Platform.isAndroid) {
      showUpdateDialogAndroid(context, status).then((_) {
        _isDialogShowing = false;
      });
    } else {
      showUpdateDialogDesktop(context, status).then((_) {
        _isDialogShowing = false;
      });
    }
  }

  Future<CompareVersionResult> _checkUpdateVersion(BuildContext context) async {
    String version = AppConfig.of(context)?.appVersion;
    String? api = AppConfig.of(context)?.settings.appUpdateVersionEndpoint;
    if (api == null) return CompareVersionResult.none;

    return getVersion(api, version);
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
                  launchUrl(Uri.parse(
                      'https://play.google.com/store/apps/details?id=com.viewsonic.display.cast&pcampaignid=web_share'));
                } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                  launchUrl(Uri.parse(
                      'https://apps.apple.com/tw/app/airsync-sender/id6453759985'));
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
