import 'dart:math' as math;

import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_ui_constant.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/screens/cast_settings.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/screens/moderator_menu_view.dart';
import 'package:display_flutter/screens/sender_menu_view.dart';
import 'package:display_flutter/screens/settings.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
// import 'package:move_to_background/move_to_background.dart';
import 'package:provider/provider.dart';

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
        // region Mirror buttons
        Color? colorButtonForeground, colorButtonBackground;
        if (ChannelProvider.isModeratorMode) {
          if (value == stateMenuOn) {
            colorButtonForeground = AppColors.iconDisablePresentingForeground;
            colorButtonBackground = AppColors.iconDisablePresentingBackground;
          } else {
            colorButtonForeground = AppColors.iconDisableStandbyForeground;
            colorButtonBackground = AppColors.iconDisableStandbyBackground;
          }
        } else {
          if (value == stateMenuOn) {
            colorButtonForeground = AppColors.iconFeatureOnPresentingForeground;
            colorButtonBackground = AppColors.iconFeatureOnPresentingBackground;
          } else {
            colorButtonForeground = AppColors.iconFeatureOnStandbyForeground;
            colorButtonBackground = AppColors.iconFeatureOnStandbyBackground;
          }
        }
        // endregion

        // region Moderator icon
        Color? colorModeratorForeground, colorModeratorBackground;
        if (ChannelProvider.isModeratorMode &&
            HybridConnectionList().getRtcConnectorMap().isNotEmpty) {
          if (value == stateMenuOn) {
            colorModeratorForeground = AppColors.iconPresentingForeground;
            colorModeratorBackground = AppColors.iconPresentingBackground;
          } else {
            colorModeratorForeground = AppColors.iconStandbyForeground;
            colorModeratorBackground = AppColors.iconStandbyBackground;
          }
        } else {
          colorModeratorForeground = AppColors.iconFeatureOnStandbyForeground;
          colorModeratorBackground = AppColors.iconFeatureOnStandbyBackground;
        }
        // endregion

        // region Main icon
        IconData? iconMain;
        Image? iconMainImageHasFocus;
        Image? iconMainImageNotFocus;
        if (value == stateStandby) {
          iconMain = Icons.settings;
        } else if (value == stateMenuOff) {
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
                  //Exit button for VBS
                  if (AppInstanceCreate().isInstalledInVBS200 &&
                      value == stateStandby)
                    Column(
                      children: [
                        FocusIconButton(
                            icons: Icons.exit_to_app,
                            iconForegroundColor:
                                AppColors.iconStandbyForeground,
                            iconBackgroundColor:
                                AppColors.iconStandbyBackground,
                            iconFocusBackgroundColor:
                                AppColors.iconFeatureOnStandbyBackground,
                            hasFocusSize: AppUIConstant.iconHasFocusSize,
                            notFocusSize: AppUIConstant.iconNotFocusSize,
                            rotateY: math.pi,
                            onClick: () {
                              // MoveToBackground.moveTaskToBack();
                            }),
                        const SizedBox(
                          width: 48,
                          child: Divider(color: Colors.white, height: 1),
                        ),
                      ],
                    ),

                  //Mirror button
                  if (value == stateStandby || value == stateMenuOn)
                    FocusIconButton(
                      icons: Icons.cast,
                      iconForegroundColor: colorButtonForeground,
                      iconBackgroundColor: colorButtonBackground,
                      iconFocusBackgroundColor:
                          AppColors.iconFeatureOnStandbyBackground,
                      hasFocusSize: AppUIConstant.iconHasFocusSize,
                      notFocusSize: AppUIConstant.iconNotFocusSize,
                      onClick: (!ChannelProvider.isModeratorMode)
                          ? () {
                              _showCastSettings();
                            }
                          : null,
                    ),

                  //Moderator button
                  if (value == stateStandby ||
                      (value == stateMenuOn && ChannelProvider.isModeratorMode))
                    Consumer<MirrorStateProvider>(builder: (_, mirror, __) {
                      bool mirrorEnable = mirror.airplayEnabled |
                          mirror.googleCastEnabled |
                          mirror.miracastEnabled;
                      if (mirrorEnable) {
                        colorModeratorForeground =
                            AppColors.iconDisableStandbyForeground;
                        colorModeratorBackground =
                            AppColors.iconDisableStandbyBackground;
                      }
                      return FocusIconButton(
                        icons: Icons.groups,
                        iconForegroundColor: colorModeratorForeground,
                        iconBackgroundColor: colorModeratorBackground,
                        iconFocusBackgroundColor:
                            AppColors.iconFeatureOnStandbyBackground,
                        hasFocusSize: AppUIConstant.iconHasFocusSize,
                        notFocusSize: AppUIConstant.iconNotFocusSize,
                        isAddGreenDot: ChannelProvider.isModeratorMode,
                        onClick: !mirrorEnable
                            ? () {
                                _showModerator(value == stateMenuOn);
                              }
                            : null,
                      );
                    }),

                  if (value == stateMenuOn &&
                      Provider.of<ChannelProvider>(context, listen: false)
                          .isSenderMode)
                    FocusIconButton(
                      svgSource: const Svg('assets/images/ic_receiver.svg'),
                      iconForegroundColor: AppColors.iconPresentingForeground,
                      iconBackgroundColor: AppColors.iconPresentingForeground,
                      iconFocusBackgroundColor:
                          AppColors.iconFeatureOnStandbyBackground,
                      hasFocusSize: AppUIConstant.iconHasFocusSize,
                      notFocusSize: AppUIConstant.iconNotFocusSize,
                      onClick: () {
                        _showSender(value == stateMenuOn);
                      },
                    ),

                  //ShowDisplayCode button
                  if (value == stateMenuOn)
                    // only for show display code while streaming menu on
                    FocusIconButton(
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
                        StreamFunction.streamFunctionState.value =
                            stateBackArrow;
                        Home.isShowDisplayCode.value = true;
                      },
                    ),

                  //Settings and In-connection button
                  // if (value != stateCast)
                  FocusIconButton(
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
                        StreamFunction.streamFunctionState.value = stateMenuOn;
                      } else if (value == stateMenuOn) {
                        StreamFunction.streamFunctionState.value = stateMenuOff;
                      } else if (value == stateBackArrow) {
                        StreamFunction.streamFunctionState.value = stateMenuOff;
                        Home.isShowDisplayCode.value = false;
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  _showMenuDialog(Widget widget) async {
    FocusScope.of(context).unfocus();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return widget;
      },
    ).then((_) {
      setState(() {});
    });
  }

  _showCastSettings() {
    _showMenuDialog(const CastSettings());
  }

  _showModerator(bool leavePresentFunction) {
    _showMenuDialog(const ModeratorMenuView());
    if (leavePresentFunction) {
      StreamFunction.streamFunctionState.value = stateMenuOff;
    }
  }

  _showSender(bool leavePresentFunction) {
    _showMenuDialog(const SenderMenuView());
    if (leavePresentFunction) {
      StreamFunction.streamFunctionState.value = stateMenuOff;
    }
  }
}
