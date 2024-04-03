import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/connect_timer.dart';
import 'package:display_cast_flutter/widgets/present_select_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:universal_html/html.dart";

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
