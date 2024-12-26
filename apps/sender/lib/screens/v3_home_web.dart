import 'package:display_cast_flutter/providers/pref_language_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/dart_ui_web_fake.dart'
    if (dart.library.ui_web) 'dart:ui_web' as ui_web;
import 'package:display_cast_flutter/widgets/v3_web_download.dart';
import 'package:display_cast_flutter/widgets/v3_web_footer.dart';
import 'package:display_cast_flutter/widgets/v3_web_main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class V3HomeWeb extends StatefulWidget {
  const V3HomeWeb({super.key});

  @override
  State<StatefulWidget> createState() => _V3HomeWebState();
}

class _V3HomeWebState extends State<V3HomeWeb> {
  final ScrollController _scrollController = ScrollController();
  bool chineseFontLoaded = false;
  bool supportedBrowsers = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initWeb();
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      PrefLanguageProvider prefLanguageProvider =
          Provider.of<PrefLanguageProvider>(context, listen: false);
      if (!prefLanguageProvider.language.contains('繁體中文')) {
        setState(() {
          chineseFontLoaded = true;
        });
      } else {
        () async {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          setState(() {
            chineseFontLoaded = true;
          });
        }();
      }
    });
  }

  void _initWeb() {
    supportedBrowsers = ui_web.browser.isChromium || ui_web.browser.isEdge;
  }

  @override
  Widget build(BuildContext context) {
    return chineseFontLoaded
        ? SingleChildScrollView(
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
                    supportedBrowsers: supportedBrowsers,
                  ),
                  if (presentStateProvider.currentState == ViewState.idle) ...[
                    const V3WebDownload(),
                    const V3WebFooter(),
                  ],
                ],
              );
            }),
          )
        : const Opacity(
            opacity: 0.0,
            child: Text('中文'),
          );
  }
}
