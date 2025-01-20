import 'dart:io';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/utilities/audio_switch_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class V3PresentIdleAudioDriverWarning extends StatefulWidget {
  const V3PresentIdleAudioDriverWarning({super.key});

  @override
  State<V3PresentIdleAudioDriverWarning> createState() =>
      _V3PresentIdleAudioDriverWarningState();
}

class _V3PresentIdleAudioDriverWarningState
    extends State<V3PresentIdleAudioDriverWarning> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !Platform.isMacOS) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<bool>(
      future: AudioSwitchManager().hasVirtualAudioDevice(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final bool hasAudioDevice = snapshot.data ?? true;
        if (hasAudioDevice) {
          return const SizedBox.shrink();
        }

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: context.tokens.color.vsdswColorWarning,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  S.current.v3_present_select_screen_mac_audio_driver,
                  style: TextStyle(
                    fontSize: context.tokens.textStyle.vsdswBodySm.fontSize,
                    color: context.tokens.color.vsdswColorOnWarning,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          context.tokens.radii.vsdswRadiusmd.topLeft.x),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  ),
                  onPressed: () {
                    launchUrl(Uri.parse(
                        'https://myviewboard.com/kb/en_US/air-sync-troubleshooting/airsync-macos-client-audio-settings'));
                  },
                  child: Text(
                    S.current.v3_present_idle_download_virtual_audio_device,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.tokens.color.vsdswColorWarning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
