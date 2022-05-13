import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/screens/language_selection.dart';
import 'package:display_flutter/screens/whats_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StreamFunction extends StatefulWidget {
  const StreamFunction({Key? key}) : super(key: key);
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
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
              width: MediaQuery.of(context).size.height * 0.08,
              child: IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    'assets/images/ic_moderator_off.svg',
                  )),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
              width: MediaQuery.of(context).size.height * 0.08,
              child: IconButton(
                  onPressed: () {
                    StreamFunction.showLanguage.value = true;
                  },
                  icon: SvgPicture.asset('assets/images/ic_language.svg')),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
              width: MediaQuery.of(context).size.height * 0.08,
              child: IconButton(
                  onPressed: () {
                    StreamFunction.showWhatsNew.value = true;
                  },
                  icon: SvgPicture.asset('assets/images/ic_whatsnews.svg')),
            ),
          ],
        ),
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
