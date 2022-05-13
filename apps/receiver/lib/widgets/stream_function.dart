import 'package:display_flutter/screens/language_selection.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/screens/whats_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class StreamFunction extends StatefulWidget {
  const StreamFunction({Key? key}) : super(key: key);
  static ValueNotifier<bool> showSplitScreen = ValueNotifier(false);
  static ValueNotifier<bool> showLanguage = ValueNotifier(false);
  static ValueNotifier<bool> showWhatsNew = ValueNotifier(false);

  @override
  State<StatefulWidget> createState() => _StreamFunctionStates();
}

class _StreamFunctionStates extends State<StreamFunction> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            IconButton(
              iconSize: 48,
              onPressed: () {
                StreamFunction.showSplitScreen.value = true;
              },
              icon: const Image(
                image: Svg('assets/images/ic_split_screen.svg'),
              ),
            ),
            IconButton(
              iconSize: 48,
              onPressed: () {},
              icon: const Image(
                image: Svg('assets/images/ic_moderator_off.svg'),
              ),
            ),
            IconButton(
              iconSize: 48,
              onPressed: () {
                StreamFunction.showLanguage.value = true;
              },
              icon: const Image(
                image: Svg('assets/images/ic_language.svg'),
              ),
            ),
            IconButton(
              iconSize: 48,
              onPressed: () {
                StreamFunction.showWhatsNew.value = true;
              },
              icon: const Image(
                image: Svg('assets/images/ic_whats_news.svg'),
              ),
            ),
          ],
        ),
        ValueListenableBuilder(
            valueListenable: StreamFunction.showSplitScreen,
            builder: (BuildContext context, bool value, Widget? child) {
              return Visibility(
                visible: StreamFunction.showSplitScreen.value,
                child: const SplitScreen(),
              );
            }),
        ValueListenableBuilder(
            valueListenable: StreamFunction.showLanguage,
            builder: (BuildContext context, bool value, Widget? child) {
              return Visibility(
                visible: StreamFunction.showLanguage.value,
                child: const LanguageSelection(),
              );
            }),
        ValueListenableBuilder(
            valueListenable: StreamFunction.showWhatsNew,
            builder: (BuildContext context, bool value, Widget? child) {
              return Visibility(
                  visible: StreamFunction.showWhatsNew.value,
                  child: const WhatsNew());
            }),
      ],
    );
  }
}
