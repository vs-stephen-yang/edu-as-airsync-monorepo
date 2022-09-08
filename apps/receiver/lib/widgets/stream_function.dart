import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/screens/debug_switch.dart';
import 'package:display_flutter/screens/language_selection.dart';
import 'package:display_flutter/screens/moderator.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/screens/whats_new.dart';
import 'package:display_flutter/widgets/main_info.dart';
import 'package:display_flutter/widgets/privilege_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class StreamFunction extends StatefulWidget {
  const StreamFunction({Key? key}) : super(key: key);

  static ValueNotifier<bool> showDebugFunction = ValueNotifier(false);
  static ValueNotifier<bool> showWaitFunction = ValueNotifier(true);
  static ValueNotifier<bool> showPresentFunction = ValueNotifier(false);
  static ValueNotifier<bool> showArrowMenu = ValueNotifier(true);
  static ValueNotifier<bool> showStreamMenu = ValueNotifier(false);

  @override
  State<StatefulWidget> createState() => StreamFunctionStates();
}

class StreamFunctionStates extends State<StreamFunction> {
  @override
  Widget build(BuildContext context) {
    // region SplitScreen icon
    String iconSplitScreen = '';
    if (ControlSocket().moderator != null) {
      iconSplitScreen = 'assets/images/ic_split_screen_off.svg';
    } else {
      if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
        iconSplitScreen = 'assets/images/ic_split_screen_activate.svg';
      } else {
        iconSplitScreen = 'assets/images/ic_split_screen_on.svg';
      }
    }
    // endregion

    // region Moderator icon
    String iconModerator = '';
    if (ControlSocket().moderator == null &&
        SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      iconModerator = 'assets/images/ic_moderator_off.svg';
    } else {
      if (ControlSocket().moderator != null) {
        iconModerator = 'assets/images/ic_moderator_activate.svg';
      } else {
        iconModerator = 'assets/images/ic_moderator_on.svg';
      }
    }
    // endregion

    return Stack(
      alignment: Alignment.bottomLeft,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(bottom: 140),
          child: ValueListenableBuilder(
            valueListenable: StreamFunction.showWaitFunction,
            builder: (BuildContext context, bool value, Widget? child) {
              return Visibility(
                visible: value,
                child: Column(
                  children: <Widget>[
                    ValueListenableBuilder(
                      valueListenable: StreamFunction.showDebugFunction,
                      builder:
                          (BuildContext context, bool value, Widget? child) {
                        return Visibility(
                          visible: value,
                          child: IconButton(
                            iconSize: 48,
                            onPressed: () {
                              DebugSwitch.showDebugSwitch.value = true;
                            },
                            icon: const Icon(
                              Icons.build_outlined,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      iconSize: 48,
                      onPressed: ControlSocket().moderator != null
                          ? null
                          : () {
                              _showSplitScreen(false);
                            },
                      icon: Image(
                        image: Svg(iconSplitScreen),
                      ),
                    ),
                    IconButton(
                      iconSize: 48,
                      onPressed: (ControlSocket().moderator == null &&
                              SplitScreen
                                  .mapSplitScreen.value[keySplitScreenEnable])
                          ? null
                          : () {
                              _showModerator(false);
                            },
                      icon: Image(
                        image: Svg(iconModerator),
                      ),
                    ),
                    IconButton(
                      iconSize: 48,
                      onPressed: () {
                        AppAnalytics().trackEventAppLanguageClick();
                        LanguageSelection.showLanguage.value = true;
                      },
                      icon: const Image(
                        image: Svg('assets/images/ic_language.svg'),
                      ),
                    ),
                    IconButton(
                      iconSize: 48,
                      onPressed: () {
                        AppAnalytics().trackEventAppWhatsNewsClick();
                        WhatsNew.showWhatsNew.value = true;
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
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: ValueListenableBuilder(
            valueListenable: StreamFunction.showPresentFunction,
            builder: (BuildContext context, bool value, Widget? child) {
              return Visibility(
                visible: value,
                child: Column(
                  children: [
                    IconButton(
                      iconSize: 48,
                      onPressed: ControlSocket().moderator != null
                          ? null
                          : () {
                              _showSplitScreen(true);
                            },
                      icon: Image(
                        image: Svg(iconSplitScreen),
                      ),
                    ),
                    IconButton(
                      iconSize: 48,
                      onPressed: (ControlSocket().moderator == null &&
                              SplitScreen
                                  .mapSplitScreen.value[keySplitScreenEnable])
                          ? null
                          : () {
                              _showModerator(true);
                            },
                      icon: Image(
                        image: Svg(iconModerator),
                      ),
                    ),
                    IconButton(
                      iconSize: 48,
                      onPressed: () {
                        MainInfo.showMainInfo.value =
                            !MainInfo.showMainInfo.value;
                      },
                      icon: const Image(
                        image: Svg('assets/images/ic_show_display_code.svg'),
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: StreamFunction.showArrowMenu,
                      builder:
                          (BuildContext context, bool value, Widget? child) {
                        return Visibility(
                          visible: value,
                          child: IconButton(
                            iconSize: 48,
                            onPressed: () {
                              StreamFunction.showPresentFunction.value = false;
                              StreamFunction.showStreamMenu.value = true;
                            },
                            icon: const Image(
                              image: Svg(
                                  'assets/images/ic_display_code_arrow.svg'),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: ValueListenableBuilder(
            valueListenable: StreamFunction.showStreamMenu,
            builder: (BuildContext context, bool value, Widget? child) {
              return Visibility(
                visible: value,
                child: IconButton(
                  iconSize: 48,
                  onPressed: () {
                    StreamFunction.showPresentFunction.value = true;
                    StreamFunction.showStreamMenu.value = false;
                  },
                  icon: const Image(
                    image: Svg('assets/images/ic_streaming_menu.svg'),
                  ),
                ),
              );
            },
          ),
        ),
        const SplitScreen(),
        ModeratorView(),
        const LanguageSelection(),
        const WhatsNew(),
        const DebugSwitch(),
      ],
    );
  }

  _showSplitScreen(bool leavePresentFunction) {
    AppAnalytics().trackEventAppSplitScreenClick();
    if (ControlSocket().featureList.contains('SplitScreen')) {
      SplitScreen.showSplitScreen.value = true;
      if (leavePresentFunction) {
        StreamFunction.showPresentFunction.value = false;
      }
    } else {
      _callPrivilegeDialog();
    }
  }

  _showModerator(bool leavePresentFunction) {
    AppAnalytics().trackEventAppModeratorClick();
    if (ControlSocket().featureList.contains('Moderator')) {
      ModeratorView.showModerator.value = true;
      if (leavePresentFunction) {
        StreamFunction.showPresentFunction.value = false;
      }
    } else {
      _callPrivilegeDialog();
    }
  }

  _callPrivilegeDialog() {
    AppAnalytics().trackEventLicenseInsufficientPrivilege();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const PrivilegeDialog();
      },
    );
  }
}
