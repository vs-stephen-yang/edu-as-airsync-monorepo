import "package:universal_html/html.dart";
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/connect_timer.dart';
import 'package:display_cast_flutter/widgets/present_select_screen.dart';
import 'package:display_cast_flutter/widgets/web_hidden_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PresentSelectScreen extends StatefulWidget {
  const PresentSelectScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _PresentSelectScreen();
  }
}

class _PresentSelectScreen extends State<PresentSelectScreen> {
  @override
  void initState() {
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

    if (kIsWeb) {
      document.addEventListener("visibilitychange", onVisibilityChange);
    }

    super.initState();
  }

  @override
  void dispose() {
    if (kIsWeb) {
      document.removeEventListener("visibilitychange", onVisibilityChange);
    }
    super.dispose();
  }

  void onVisibilityChange(e) {
    if (document.visibilityState == 'hidden') {
      WebOnHiddenHelper.getInstance().setOnHiddenTimestamp(
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
