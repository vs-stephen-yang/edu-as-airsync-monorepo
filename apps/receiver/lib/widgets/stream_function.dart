import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_ui_constant.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/screens/debug_switch.dart';
import 'package:display_flutter/screens/language_selection.dart';
import 'package:display_flutter/screens/moderator_view.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/screens/whats_new.dart';
import 'package:display_flutter/widgets/custom_icons_icons.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/main_info.dart';
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
  State createState() => _StreamFunctionStates();
}

class _StreamFunctionStates extends State<StreamFunction> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: StreamFunction.streamFunctionState,
      builder: (BuildContext context, String value, Widget? child) {
        // region SplitScreen icon
        Color? colorSplitScreenForeground, colorSplitScreenBackground;
        if (ControlSocket().moderator != null) {
          if (value == stateMenuOn) {
            colorSplitScreenForeground =
                AppColors.iconDisablePresentingForeground;
            colorSplitScreenBackground =
                AppColors.iconDisablePresentingBackground;
          } else {
            colorSplitScreenForeground = AppColors.iconDisableStandbyForeground;
            colorSplitScreenBackground = AppColors.iconDisableStandbyBackground;
          }
        } else {
          if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
            if (value == stateMenuOn) {
              colorSplitScreenForeground =
                  AppColors.iconFeatureOnPresentingForeground;
              colorSplitScreenBackground =
                  AppColors.iconFeatureOnPresentingBackground;
            } else {
              colorSplitScreenForeground =
                  AppColors.iconFeatureOnStandbyForeground;
              colorSplitScreenBackground =
                  AppColors.iconFeatureOnStandbyBackground;
            }
          } else {
            if (value == stateMenuOn) {
              colorSplitScreenForeground = AppColors.iconPresentingForeground;
              colorSplitScreenBackground = AppColors.iconPresentingBackground;
            } else {
              colorSplitScreenForeground = AppColors.iconStandbyForeground;
              colorSplitScreenBackground = AppColors.iconStandbyBackground;
            }
          }
        }
        // endregion

        // region Moderator icon
        Color? colorModeratorForeground, colorModeratorBackground;
        if (ControlSocket().moderator == null &&
            SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
          if (value == stateMenuOn) {
            colorModeratorForeground =
                AppColors.iconDisablePresentingForeground;
            colorModeratorBackground =
                AppColors.iconDisablePresentingBackground;
          } else {
            colorModeratorForeground = AppColors.iconDisableStandbyForeground;
            colorModeratorBackground = AppColors.iconDisableStandbyBackground;
          }
        } else {
          if (ControlSocket().moderator != null) {
            colorModeratorForeground = AppColors.iconFeatureOnStandbyForeground;
            colorModeratorBackground = AppColors.iconFeatureOnStandbyBackground;
          } else {
            if (value == stateMenuOn) {
              colorModeratorForeground = AppColors.iconPresentingForeground;
              colorModeratorBackground = AppColors.iconPresentingBackground;
            } else {
              colorModeratorForeground = AppColors.iconStandbyForeground;
              colorModeratorBackground = AppColors.iconStandbyBackground;
            }
          }
        }
        // endregion

        // region Language icon
        IconData? iconLanguage;
        if (value == stateStandby) {
          iconLanguage = Icons.language;
        } else if (value == stateMenuOn) {
          iconLanguage = Icons.password;
        }
        // endregion

        // region Main icon
        IconData? iconMain;
        Image? iconMainImageHasFocus;
        Image? iconMainImageNotFocus;
        if (value == stateStandby) {
          iconMain = Icons.campaign;
        } else if (value == stateMenuOff || value == stateEmpty) {
          iconMainImageHasFocus =
              const Image(image: Svg('assets/images/ic_streaming_menu_on.svg'));
          iconMainImageNotFocus = const Image(
              image: Svg('assets/images/ic_streaming_menu_off.svg'));
        } else {
          iconMain = Icons.arrow_back_ios_new;
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
                      icons: Icons.build_outlined,
                      iconForegroundColor: AppColors.iconStandbyForeground,
                      iconBackgroundColor: AppColors.iconStandbyBackground,
                      iconFocusBackgroundColor:
                          AppColors.iconFeatureOnStandbyBackground,
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
                      icons: CustomIcons.split_screen,
                      iconForegroundColor: colorSplitScreenForeground,
                      iconBackgroundColor: colorSplitScreenBackground,
                      iconFocusBackgroundColor:
                          AppColors.iconFeatureOnStandbyBackground,
                      hasFocusSize: AppUIConstant.iconHasFocusSize,
                      notFocusSize: AppUIConstant.iconNotFocusSize,
                      isAddGreenDot: (SplitScreen
                              .mapSplitScreen.value[keySplitScreenEnable] &&
                          ControlSocket().moderator == null),
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
                      icons: Icons.groups,
                      iconForegroundColor: colorModeratorForeground,
                      iconBackgroundColor: colorModeratorBackground,
                      iconFocusBackgroundColor:
                          AppColors.iconFeatureOnStandbyBackground,
                      hasFocusSize: AppUIConstant.iconHasFocusSize,
                      notFocusSize: AppUIConstant.iconNotFocusSize,
                      isAddGreenDot: ControlSocket().moderator != null,
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
                      icons: iconLanguage,
                      iconForegroundColor: value == stateStandby
                          ? AppColors.iconStandbyForeground
                          : AppColors.iconPresentingForeground,
                      iconBackgroundColor: value == stateStandby
                          ? AppColors.iconStandbyBackground
                          : AppColors.iconPresentingForeground,
                      iconFocusBackgroundColor:
                          AppColors.iconFeatureOnStandbyBackground,
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
                      icons: iconMain,
                      childNotFocus: iconMainImageNotFocus,
                      childHasFocus: iconMainImageHasFocus,
                      iconForegroundColor: value == stateStandby
                          ? AppColors.iconStandbyForeground
                          : AppColors.iconPresentingForeground,
                      iconBackgroundColor: value == stateStandby
                          ? AppColors.iconStandbyBackground
                          : AppColors.iconPresentingForeground,
                      iconFocusBackgroundColor:
                          AppColors.iconFeatureOnStandbyBackground,
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
    _showMenuDialog(SplitScreen(onUpdateParentUI: () {
      setState(() {});
    }));
    if (leavePresentFunction) {
      StreamFunction.streamFunctionState.value = stateMenuOff;
    }
  }

  _showModerator(bool leavePresentFunction) {
    AppAnalytics().trackEventAppModeratorClick();
    _showMenuDialog(ModeratorView(onUpdateParentUI: () {
      setState(() {});
    }));
    if (leavePresentFunction) {
      StreamFunction.streamFunctionState.value = stateMenuOff;
    }
  }
}
