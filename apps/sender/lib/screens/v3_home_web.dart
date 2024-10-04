import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/widgets/v3_web_download.dart';
import 'package:display_cast_flutter/widgets/v3_web_footer.dart';
import 'package:display_cast_flutter/widgets/v3_web_main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class V3HomeWeb extends StatefulWidget {
  const V3HomeWeb({super.key});

  @override
  State<StatefulWidget> createState() => _V3HomeWebState();
}

class _V3HomeWebState extends State<V3HomeWeb> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Consumer<PresentStateProvider>(
          builder: (context, presentStateProvider, child) {
        return Column(
          children: <Widget>[
            V3WebMain(
              presentStateProvider: presentStateProvider,
              scrollTo: () {
                _scrollController.animateTo(
                  700.0,
                  // The target scroll position in pixels
                  duration: const Duration(milliseconds: 500),
                  // Animation duration
                  curve: Curves.ease, // Animation curve
                );
              },
            ),
            if (presentStateProvider.currentState == ViewState.idle) ...[
              const V3WebDownload(),
              const V3WebFooter(),
            ],
          ],
        );
      }),
    );
  }
}
