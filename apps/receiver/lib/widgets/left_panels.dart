import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/screens/language_selection.dart';
import 'package:display_flutter/screens/whats_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LeftPanels extends StatefulWidget {
  const LeftPanels({Key? key}) : super(key: key);
  static ValueNotifier<bool> showLanguage = ValueNotifier(false);
  static ValueNotifier<bool> showWhatsNew = ValueNotifier(false);

  @override
  State<StatefulWidget> createState() => _LeftPanelsStates();
}

class _LeftPanelsStates extends State<LeftPanels> {
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
                    LeftPanels.showLanguage.value = true;
                  },
                  icon: SvgPicture.asset('assets/images/ic_language.svg')),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
              width: MediaQuery.of(context).size.height * 0.08,
              child: IconButton(
                  onPressed: () {
                    LeftPanels.showWhatsNew.value = true;
                  },
                  icon: SvgPicture.asset('assets/images/ic_whatsnews.svg')),
            ),
          ],
        ),
        ValueListenableBuilder(
            valueListenable: LeftPanels.showLanguage,
            builder: (BuildContext context, bool value, Widget? child) {
              return Visibility(
                visible: LeftPanels.showLanguage.value,
                child: const LanguageSelection(),
              );
            }),
        ValueListenableBuilder(
            valueListenable: LeftPanels.showWhatsNew,
            builder: (BuildContext context, bool value, Widget? child) {
              return Visibility(
                  visible: LeftPanels.showWhatsNew.value,
                  child: const WhatsNew());
            }),
      ],
    );
  }
}
