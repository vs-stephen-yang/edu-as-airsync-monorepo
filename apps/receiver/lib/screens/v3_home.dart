import 'dart:io';

import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_overlay_tab.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/widgets/v3_footer_bar.dart';
import 'package:display_flutter/widgets/v3_header_bar.dart';
import 'package:display_flutter/widgets/v3_main_info.dart';
import 'package:display_flutter/widgets/v3_streaming_view.dart';
import 'package:display_flutter/widgets/vbs_ota.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppOverlayTab().setupOverlayTabHandler(context);
    Provider.of<ChannelProvider>(context, listen: false).startChannelProvider();
    Provider.of<MirrorStateProvider>(context, listen: false)
        .startMirrorStartProvider();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
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
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Platform.isAndroid ? false : true,
      onPopInvoked: (didPop) async {
        log.info('PopScope didPop: $didPop');
        if (didPop) {
          return;
        }
        try {
          _showSnackBarMessage(S.of(context).main_status_go_background);
          await Future.delayed(const Duration(seconds: 1));
          _androidAppRetain.invokeMethod('sendToBackground');
        } catch (e, stackTrace) {
          log.severe('sendTiBackground', e, stackTrace);
        }
      },
      child: Scaffold(
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              const V3StreamingView(),
              ValueListenableBuilder(
                valueListenable: V3Home.isShowHeaderFooterBar,
                builder: (_, bool value, __) {
                  return value
                      ? Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Container(
                              color: const Color(0xFFEAEBF1),
                            ),
                            const V3FooterBar(),
                            const V3HeaderBar(),
                            if (AppInstanceCreate().isInstalledInVBS100 |
                                AppInstanceCreate().isInstalledInVBS200)
                              const Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: VbsOTA()),
                          ],
                        )
                      : const SizedBox.shrink();
                },
              ),
              ValueListenableBuilder(
                valueListenable: V3Home.isShowDisplayCode,
                builder: (_, bool value, __) {
                  return value ? const V3MainInfo() : const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showSnackBarMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}
