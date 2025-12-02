import 'dart:async';
import 'dart:io';

import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:display_flutter/app_manager_config.dart';
import 'package:display_flutter/app_overlay_tab.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/services/display_service_broadcast.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/wifi_status_util.dart';
import 'package:display_flutter/widgets/streaming/streaming_feature_wrapper.dart';
import 'package:display_flutter/widgets/streaming/streaming_view_container.dart';
import 'package:display_flutter/widgets/v3_authorize_prompt.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_debug_device_info_overlay.dart';
import 'package:display_flutter/widgets/v3_footer_bar.dart';
import 'package:display_flutter/widgets/v3_group_host_view.dart';
import 'package:display_flutter/widgets/v3_group_reject_prompt.dart';
import 'package:display_flutter/widgets/v3_header_bar.dart';
import 'package:display_flutter/widgets/v3_main_info.dart';
import 'package:display_flutter/widgets/v3_message_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:provider/provider.dart';

class V3Home extends StatefulWidget {
  const V3Home({super.key});

  static ValueNotifier<bool> isShowHeaderFooterBar = ValueNotifier(true);
  static ValueNotifier<bool> isShowDisplayCode = ValueNotifier(true);

  @override
  State<StatefulWidget> createState() => _V3HomeState();
}

class _V3HomeState extends State<V3Home> with WidgetsBindingObserver {
  static const _androidAppRetain =
      MethodChannel('com.mvbcast.crosswalk/android_app_retain');
  StreamSubscription? _wifiStatusSubscription;
  bool _lastWifiStatus = false;
  late Future<void> initOperation;

  @override
  void initState() {
    initOperation = initHyphenation();
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    AppOverlayTab().setupOverlayTabHandler(context);
    Provider.of<ChannelProvider>(context, listen: false).startChannelProvider();
    final mirrorStateProvider =
        Provider.of<MirrorStateProvider>(context, listen: false);
    mirrorStateProvider.startMirrorStartProvider();

    setProviderContainer();
    AppManagerConfig().startHandleManagerUpdateRequest(context);

    if (mirrorStateProvider.miracastSupport) {
      WifiStatusUtil().initialize();

      // 獲取當前 WiFi 狀態
      WifiStatusUtil.isWifiEnabled().then((value) {
        _lastWifiStatus = value;
      });

      // 監聽 WiFi 狀態變化
      _wifiStatusSubscription =
          WifiStatusUtil().wifiStatusStream.listen((isEnabled) {
        // reopen
        if (isEnabled && !_lastWifiStatus) {
          mirrorStateProvider.restartMiracast();
        }
        _lastWifiStatus = isEnabled;
      });
    }
  }

  void setProviderContainer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChannelProvider>(context, listen: false)
          .setProviderContainer(riverpod.ProviderScope.containerOf(context));
    });
  }

  @override
  void dispose() {
    _wifiStatusSubscription?.cancel();
    WifiStatusUtil().dispose();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    AppManagerConfig().stopHandleManagerUpdateRequest();
    DisplayServiceBroadcast.instance?.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log.info('AppLifecycleState: $state');
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    MirrorStateProvider mirrorStateProvider =
        Provider.of<MirrorStateProvider>(context, listen: false);
    if (state == AppLifecycleState.inactive) {
      channelProvider.updateAllAudioEnableState(false);
      mirrorStateProvider.updateAllAudioEnableState(false);
    } else if (state == AppLifecycleState.resumed) {
      channelProvider.updateAllAudioEnableState(true);
      mirrorStateProvider.updateAllAudioEnableState(true);
    }
    setProviderContainer();
  }

  @override
  Widget build(BuildContext context) {
    final realScreenSizeHeight = context
        .select<MultiWindowProvider, double>((p) => p.realScreenSize.height);
    return PopScope<Object?>(
      canPop: Platform.isAndroid ? false : true,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        log.info('PopScope didPop: $didPop');
        if (didPop) {
          return;
        }
        try {
          _showSnackBarMessage(S.of(context).main_status_go_background);
          await Future.delayed(const Duration(seconds: 1));
          await _androidAppRetain.invokeMethod('sendToBackground');
        } catch (e, stackTrace) {
          log.severe('sendTiBackground', e, stackTrace);
        }
      },
      child: Scaffold(
        body: FutureBuilder(
            future: initOperation,
            builder: (_, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Container();
              }

              return ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: _getBottomPadding(context, realScreenSizeHeight)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      const StreamingViewContainer(),
                      MultiWindowAdaptiveLayout(
                        landscape: ValueListenableBuilder(
                          valueListenable: V3Home.isShowHeaderFooterBar,
                          builder: (_, bool value, __) {
                            return value
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                      Container(
                                        color: const Color(0xFFEAEBF1),
                                      ),
                                      Positioned(child: const V3HeaderBar()),
                                      const V3FooterBar(),
                                    ],
                                  )
                                : const SizedBox.shrink();
                          },
                        ),
                        launcher: SizedBox.shrink(),
                        floatingDefault: SizedBox.shrink(),
                      ),
                      ValueListenableBuilder(
                        valueListenable: V3Home.isShowDisplayCode,
                        builder: (_, bool value, __) {
                          return value ? const V3MainInfo() : const SizedBox();
                        },
                      ),
                      const StreamingFeatureWrapper(),
                      const V3AuthorizePrompt(),
                      const V3GroupRejectPrompt(),
                      const V3GroupHostView(),
                      const V3MessageDialog(),
                      const V3DebugDeviceInfoOverlay(),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  double _getBottomPadding(BuildContext context, double realScreenSizeHeight) {
    // In the multiWindow mode the system status and bottom navigation bar will appear, also not able to hide due to the rule by android's design
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final appHeight = MediaQuery.of(context).size.height * devicePixelRatio;
    var bottomPadding = 0.0;
    if (context.isNavigationBarVisible &&
        context.isStatusBarVisible &&
        appHeight == realScreenSizeHeight &&
        context.isInMultiWindow) {
      bottomPadding = context.navigationBarHeightPx / devicePixelRatio;
    }
    return bottomPadding;
  }

  _showSnackBarMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: V3AutoHyphenatingText(message)),
      );
  }
}
