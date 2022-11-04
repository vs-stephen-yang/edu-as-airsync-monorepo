import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_ui_constant.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/screens/debug_switch.dart';
import 'package:display_flutter/screens/language_selection.dart';
import 'package:display_flutter/screens/moderator_view.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/screens/whats_new.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/main_info.dart';
import 'package:display_flutter/widgets/privilege_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

// Empty, Basic streaming
const String stateEmpty = 'empty';
// SplitScreen, Moderator, Language, WhatsNew,
const String stateStandby = 'standby';
// Display Cloud,
const String stateMenuOff = 'menuOff';
// SplitScreen, Moderator, Show Display Code, BackArrow
const String stateMenuOn = 'menuOn';
// BackArrow Only (for close display code)
const String stateBackArrow = 'backArrow';

class StreamFunction extends StatefulWidget {
  const StreamFunction({Key? key}) : super(key: key);

  static bool showDebugFunction = false;
  static ValueNotifier<String> streamFunctionState =
      ValueNotifier(stateStandby);

  @override
  State<StatefulWidget> createState() => StreamFunctionStates();
}

class StreamFunctionStates extends State<StreamFunction> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: StreamFunction.streamFunctionState,
      builder: (BuildContext context, String value, Widget? child) {
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

        // region Main icon
        String iconMain = '';
        if (value == stateStandby) {
          iconMain = 'assets/images/ic_whats_news.svg';
        } else if (value == stateMenuOff || value == stateEmpty) {
          iconMain = 'assets/images/ic_streaming_menu.svg';
        } else {
          iconMain = 'assets/images/ic_display_code_arrow.svg';
        }
        // endregion

        double bottomInset = 20;
        if (value == stateStandby) {
          bottomInset = 140;
        }

        return Stack(
          alignment: Alignment.bottomLeft,
          children: <Widget>[
            Container(
              width: AppUIConstant.featureContainerWidth,
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Visibility(
                    visible: StreamFunction.showDebugFunction,
                    child: FocusIconButton(
                      child: const Icon(
                        Icons.build_outlined,
                        color: Colors.white,
                      ),
                      hasFocusSize: AppUIConstant.iconHasFocusSize,
                      notFocusSize: AppUIConstant.iconNotFocusSize,
                      onClick: () {
                        _showMenuDialog(const DebugSwitch());
                      },
                    ),
                  ),
                  Visibility(
                    visible: (value == stateStandby || value == stateMenuOn) &&
                        !AppInstanceCreate().isDisableAdvance,
                    child: FocusIconButton(
                      child: Image(image: Svg(iconSplitScreen)),
                      hasFocusSize: AppUIConstant.iconHasFocusSize,
                      notFocusSize: AppUIConstant.iconNotFocusSize,
                      onClick: ControlSocket().moderator == null
                          ? () {
                              _showSplitScreen(value == stateMenuOn);
                            }
                          : null,
                    ),
                  ),
                  Visibility(
                    visible: (value == stateStandby || value == stateMenuOn) &&
                        !AppInstanceCreate().isDisableAdvance,
                    child: FocusIconButton(
                      child: Image(image: Svg(iconModerator)),
                      hasFocusSize: AppUIConstant.iconHasFocusSize,
                      notFocusSize: AppUIConstant.iconNotFocusSize,
                      onClick: (ControlSocket().moderator == null &&
                              SplitScreen
                                  .mapSplitScreen.value[keySplitScreenEnable])
                          ? null
                          : () {
                              _showModerator(value == stateMenuOn);
                            },
                    ),
                  ),
                  Visibility(
                    visible: value == stateStandby || value == stateMenuOn,
                    child: FocusIconButton(
                      child: Image(
                        image: Svg(value == stateStandby
                            ? 'assets/images/ic_language.svg'
                            : 'assets/images/ic_show_display_code.svg'),
                      ),
                      hasFocusSize: AppUIConstant.iconHasFocusSize,
                      notFocusSize: AppUIConstant.iconNotFocusSize,
                      onClick: () {
                        if (value == stateStandby) {
                          AppAnalytics().trackEventAppLanguageClick();
                          _showMenuDialog(const LanguageSelection());
                        } else if (value == stateMenuOn) {
                          // _showMenuDialog(const MainInfo());
                          StreamFunction.streamFunctionState.value =
                              stateBackArrow;
                          MainInfo.showMainInfo.value = true;
                        }
                      },
                    ),
                  ),
                  Visibility(
                    visible: value != stateEmpty,
                    child: FocusIconButton(
                      child: Image(image: Svg(iconMain)),
                      hasFocusSize: AppUIConstant.iconHasFocusSize,
                      notFocusSize: AppUIConstant.iconNotFocusSize,
                      onClick: () {
                        if (value == stateStandby) {
                          AppAnalytics().trackEventAppWhatsNewsClick();
                          _showMenuDialog(const WhatsNew());
                        } else if (value == stateMenuOff) {
                          StreamFunction.streamFunctionState.value =
                              stateMenuOn;
                        } else if (value == stateMenuOn) {
                          StreamFunction.streamFunctionState.value =
                              stateMenuOff;
                        } else if (value == stateBackArrow) {
                          MainInfo.showMainInfo.value = false;
                          StreamFunction.streamFunctionState.value =
                              stateMenuOff;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  _showMenuDialog(Widget widget) {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return widget;
      },
    );
  }

  _showSplitScreen(bool leavePresentFunction) {
    AppAnalytics().trackEventAppSplitScreenClick();
    if (ControlSocket().featureList.contains('SplitScreen')) {
      _showMenuDialog(const SplitScreen());
      if (leavePresentFunction) {
        StreamFunction.streamFunctionState.value = stateMenuOff;
      }
    } else {
      // todo: multi language
      _showMenuDialog(const PrivilegeDialog(title: 'Split Screen'));
    }
  }

  _showModerator(bool leavePresentFunction) {
    AppAnalytics().trackEventAppModeratorClick();
    if (ControlSocket().featureList.contains('Moderator')) {
      _showMenuDialog(ModeratorView());
      if (leavePresentFunction) {
        StreamFunction.streamFunctionState.value = stateMenuOff;
      }
    } else {
      AppAnalytics().trackEventLicenseInsufficientPrivilege();
      // todo: multi language
      _showMenuDialog(const PrivilegeDialog(title: 'Moderator'));
    }
  }
}
