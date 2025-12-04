import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/screens/v3_home_app.dart';
import 'package:display_cast_flutter/screens/v3_home_web.dart';
import 'package:display_cast_flutter/screens/v3_mobile_unsupported.dart';
import 'package:display_cast_flutter/utilities/audio_switch_manager.dart';
import 'package:display_cast_flutter/utilities/v3_network_status_detector.dart';
import 'package:display_cast_flutter/utilities/v3_update_manager.dart';
import 'package:display_cast_flutter/widgets/app_retain.dart';
import 'package:display_cast_flutter/widgets/v3_exit_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:provider/provider.dart';
import "package:universal_html/html.dart" as html;

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
    // Check if this is a mobile device on web
    if (!_isWebSupportPlatform()) {
      return const V3MobileUnsupported();
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
}
