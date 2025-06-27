import 'dart:io';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/utilities/audio_switch_manager.dart';
import 'package:display_cast_flutter/widgets/V3_focus.dart';
import 'package:display_cast_flutter/widgets/v3_auto_hyphenating_text.dart';
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
  bool _isVisible = true;

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
      setState(() {
        _isVisible = true; // 当应用回到前台时重新显示警告
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !Platform.isMacOS || !_isVisible) {
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

        return Container(
          decoration: BoxDecoration(
            color: context.tokens.color.vsdswColorWarning,
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 2,
                      child: V3AutoHyphenatingText(
                        S.current.v3_present_select_screen_mac_audio_driver,
                        style: TextStyle(
                          fontSize:
                              context.tokens.textStyle.vsdswBodySm.fontSize,
                          color: context.tokens.color.vsdswColorOnWarning,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: V3Focus(
                        label: S
                            .of(context)
                            .v3_lbl_present_idle_audio_driver_warning_download,
                        identifier:
                            'v3_qa_present_idle_audio_driver_warning_download',
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  context.tokens.radii.vsdswRadiusmd.topLeft.x),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                          ),
                          onPressed: () {
                            launchUrl(Uri.parse(
                                'https://myviewboard.com/kb/en_US/air-sync-troubleshooting/airsync-macos-client-audio-settings'));
                          },
                          child: V3AutoHyphenatingText(
                            S.current
                                .v3_present_idle_download_virtual_audio_device,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.tokens.color.vsdswColorWarning,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              V3Focus(
                label: S
                    .of(context)
                    .v3_lbl_present_idle_audio_driver_warning_close,
                identifier: 'v3_qa_present_idle_audio_driver_warning_close',
                button: true,
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: InkWell(
                    child: ExcludeSemantics(
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: context.tokens.color.vsdswColorOnWarning,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _isVisible = false;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        );
      },
    );
  }
}
