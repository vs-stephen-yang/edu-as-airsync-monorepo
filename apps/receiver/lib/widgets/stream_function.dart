import 'dart:math' as math;

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_ui_constant.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/screens/cast_settings.dart';
import 'package:display_flutter/screens/debug_switch.dart';
import 'package:display_flutter/screens/settings.dart';
import 'package:display_flutter/screens/moderator_menu_view.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/widgets/custom_icons_icons.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:provider/provider.dart';

// Empty, Basic streaming
const String stateEmpty = 'empty';
// SplitScreen, Moderator, Language, WhatsNew,
const String stateStandby = 'standby';
// Display Cloud,
const String stateMenuOff = 'menuOff';
// SplitScreen, Moderator, Show Display Code, BackArrow
const String stateMenuOn = 'menuOn';
// CastSettings
const String stateCast = 'cast';
// BackArrow Only (for close display code)
const String stateBackArrow = 'backArrow';

class StreamFunction extends StatefulWidget {
  const StreamFunction({super.key});

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
        if (ChannelProvider.isModeratorMode) {
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
        if (!ChannelProvider.isModeratorMode &&
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
          if (ChannelProvider.isModeratorMode) {
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

        // region Main icon
        IconData? iconMain;
        Image? iconMainImageHasFocus;
        Image? iconMainImageNotFocus;
        if (value == stateStandby) {
          iconMain = Icons.settings;
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
                  if (AppInstanceCreate().isInstalledInVBS200 &&
                      value == stateStandby)
                    Column(
                      children: [
                        FocusIconButton(
                            icons: Icons.exit_to_app,
                            iconForegroundColor: colorSplitScreenForeground,
                            iconBackgroundColor: colorSplitScreenBackground,
                            iconFocusBackgroundColor:
                                AppColors.iconFeatureOnStandbyBackground,
                            hasFocusSize: AppUIConstant.iconHasFocusSize,
                            notFocusSize: AppUIConstant.iconNotFocusSize,
                            rotateY: math.pi,
                            onClick: () {
                              MoveToBackground.moveTaskToBack();
                            }),
                        const SizedBox(
                          width: 48,
                          child: Divider(color: Colors.white, height: 1),
                        ),
                      ],
                    ),
                  if ((value == stateStandby &&
                          !AppInstanceCreate().isDisableAdvance ||
                      value == stateCast))
                    FocusIconButton(
                        icons: Icons.cast,
                        iconForegroundColor: colorSplitScreenForeground,
                        iconBackgroundColor: colorSplitScreenBackground,
                        iconFocusBackgroundColor:
                            AppColors.iconFeatureOnStandbyBackground,
                        hasFocusSize: AppUIConstant.iconHasFocusSize,
                        notFocusSize: AppUIConstant.iconNotFocusSize,
                        onClick: () {
                          if (!ChannelProvider.isModeratorMode) {
                            _showCastSettings();
                          }
                        }),
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
                          !ChannelProvider.isModeratorMode),
                      onClick: !ChannelProvider.isModeratorMode
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
                      isAddGreenDot: ChannelProvider.isModeratorMode,
                      onClick: (!ChannelProvider.isModeratorMode &&
                              SplitScreen
                                  .mapSplitScreen.value[keySplitScreenEnable])
                          ? null
                          : () {
                              _showModerator(value == stateMenuOn);
                            },
                    ),
                  ),
                  Visibility(
                    // only for show display code while streaming menu on
                    visible: value == stateMenuOn,
                    child: FocusIconButton(
                      icons: Icons.password,
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
                        // _showMenuDialog(const MainInfo());
                        StreamFunction.streamFunctionState.value =
                            stateBackArrow;
                        context.read<ChannelProvider>().updateModePanel();
                        // ChannelProvider.showMode = true;
                      },
                    ),
                  ),
                  Visibility(
                    visible: value != stateEmpty && value != stateCast,
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
                          _showMenuDialog(const Settings());
                        } else if (value == stateMenuOff) {
                          StreamFunction.streamFunctionState.value =
                              stateMenuOn;
                        } else if (value == stateMenuOn) {
                          StreamFunction.streamFunctionState.value =
                              stateMenuOff;
                        } else if (value == stateBackArrow) {
                          // ChannelProvider.showMode = true;
                          StreamFunction.streamFunctionState.value =
                              stateMenuOff;
                          context.read<ChannelProvider>().updateModePanel();
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

  _showCastSettings() {
    _showMenuDialog(const CastSettings());
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
    _showMenuDialog(ModeratorMenuView(onUpdateParentUI: () {
      setState(() {});
    }));
    if (leavePresentFunction) {
      StreamFunction.streamFunctionState.value = stateMenuOff;
    }
  }
}
