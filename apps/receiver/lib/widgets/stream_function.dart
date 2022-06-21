import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/screens/language_selection.dart';
import 'package:display_flutter/screens/moderator.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/screens/whats_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class StreamFunction extends StatefulWidget {
  const StreamFunction({Key? key}) : super(key: key);

  static ValueNotifier<bool> showWaitFunction = ValueNotifier(true);
  static ValueNotifier<bool> showSplitScreen = ValueNotifier(false);
  static ValueNotifier<bool> showModerator = ValueNotifier(false);
  static ValueNotifier<bool> showLanguage = ValueNotifier(false);
  static ValueNotifier<bool> showWhatsNew = ValueNotifier(false);

  @override
  State<StatefulWidget> createState() => StreamFunctionStates();
}

class StreamFunctionStates extends State<StreamFunction> {
  @override
  Widget build(BuildContext context) {
    // region SplitScreen icon
    String iconSplitScreen = '';
    if (ControlSocket().moderatorMode) {
      iconSplitScreen = 'assets/images/ic_split_screen_off.svg';
    } else {
      if (SplitScreen.splitScreenEnabled.value) {
        iconSplitScreen = 'assets/images/ic_split_screen_activate.svg';
      } else {
        iconSplitScreen = 'assets/images/ic_split_screen_on.svg';
      }
    }
    // endregion

    // region Moderator icon
    String iconModerator = '';
    if (!ControlSocket().moderatorMode &&
        SplitScreen.splitScreenEnabled.value) {
      iconModerator = 'assets/images/ic_moderator_off.svg';
    } else {
      if (ControlSocket().moderatorMode) {
        iconModerator = 'assets/images/ic_moderator_activate.svg';
      } else {
        iconModerator = 'assets/images/ic_moderator_on.svg';
      }
    }
    // endregion

    return Stack(
      children: <Widget>[
        ValueListenableBuilder(
          valueListenable: StreamFunction.showWaitFunction,
          builder: (BuildContext context, bool value, Widget? child) {
            return Visibility(
              visible: value,
              child: Column(
                children: <Widget>[
                  IconButton(
                    iconSize: 48,
                    onPressed: ControlSocket().moderatorMode
                        ? null
                        : () {
                            StreamFunction.showSplitScreen.value = true;
                          },
                    icon: Image(
                      image: Svg(iconSplitScreen),
                    ),
                  ),
                  IconButton(
                    iconSize: 48,
                    onPressed: (!ControlSocket().moderatorMode &&
                            SplitScreen.splitScreenEnabled.value)
                        ? null
                        : () {
                            StreamFunction.showModerator.value = true;
                          },
                    icon: Image(
                      image: Svg(iconModerator),
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
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: StreamFunction.showSplitScreen,
          builder: (BuildContext context, bool value, Widget? child) {
            return Visibility(visible: value, child: const SplitScreen());
          },
        ),
        ValueListenableBuilder(
          valueListenable: StreamFunction.showModerator,
          builder: (BuildContext context, bool value, Widget? child) {
            return Visibility(visible: value, child: const ModeratorView());
          },
        ),
        ValueListenableBuilder(
          valueListenable: StreamFunction.showLanguage,
          builder: (BuildContext context, bool value, Widget? child) {
            return Visibility(visible: value, child: const LanguageSelection());
          },
        ),
        ValueListenableBuilder(
          valueListenable: StreamFunction.showWhatsNew,
          builder: (BuildContext context, bool value, Widget? child) {
            return Visibility(visible: value, child: const WhatsNew());
          },
        ),
      ],
    );
  }
}
