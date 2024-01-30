
import 'dart:html';

import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/connect_timer.dart';
import 'package:display_cast_flutter/widgets/present_select_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PresentSelectScreen extends StatelessWidget {
  const PresentSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ChannelProvider provider =
          Provider.of<ChannelProvider>(context, listen: false);
      // start timeout timer (30 sec)
      ConnectionTimer.getInstance().startConnectionTimeoutTimer(() {
        // onFinish
        if (kIsWeb) {
          window.location.reload();
        }
      });
      var value = CustomDesktopCapturerSource(null, true);
      provider.presentStart(
          selectedSource: value.selectedSource, systemAudio: value.systemAudio);
    });
    return const SizedBox();
  }
}
