import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_ui_constant.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:flutter/material.dart';

class SplitScreenFunction extends StatelessWidget {
  const SplitScreenFunction({super.key, required this.index, this.updateSize});
  static ValueNotifier<List<bool>> isMenuOnList =
      ValueNotifier(List.filled(4, false, growable: false));

  final int index;
  final VoidCallback? updateSize;

  @override
  Widget build(BuildContext context) {
    double? left, top, bottom, right;
    if (Home.isSelectedList.value[index]) {
      // full screen mode in right-bottom;
      right = 20;
      bottom = 20;
    } else {
      // 4 split screen in center corner
      if (index == 1) {
        // right-top screen
        left = 20;
        bottom = 20;
      } else if (index == 2) {
        // left-bottom screen
        right = 20;
        top = 20;
      } else if (index == 3) {
        // right-bottom screen
        left = 20;
        top = 20;
      } else {
        // left-top screen
        right = 20;
        bottom = 20;
      }
    }
    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          child: Visibility(
            // More than 1 presenting will show this function button.
            visible: ControlSocket().getPresentingQuantity() > 1,
            child: ValueListenableBuilder(
              valueListenable: SplitScreenFunction.isMenuOnList,
              builder: (BuildContext context, List<bool> value, Widget? child) {
                return Container(
                  height: AppUIConstant.featureContainerHeight,
                  alignment: Alignment.center,
                  child: Wrap(
                    textDirection: (index == 0 || index == 2)
                        ? TextDirection.ltr
                        : TextDirection.rtl,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Visibility(
                        visible:
                            !Home.isSelectedList.value[index] && value[index],
                        child: FocusIconButton(
                          icons: Icons.close,
                          iconForegroundColor: Colors.white,
                          iconBackgroundColor:
                              AppColors.iconPresentingBackground,
                          iconFocusBackgroundColor:
                              AppColors.iconFeatureOnStandbyBackground,
                          hasFocusSize: AppUIConstant.iconHasFocusSize,
                          notFocusSize: AppUIConstant.iconNotFocusSize,
                          onClick: () {
                            AppAnalytics()
                                .trackEventSplitScreenDisconnectClick();
                            SplitScreenFunction.isMenuOnList.value.fillRange(
                                0,
                                SplitScreenFunction.isMenuOnList.value.length,
                                false);
                            ControlSocket().removePresenterBy(index);
                          },
                        ),
                      ),
                      Visibility(
                        visible:
                            !Home.isSelectedList.value[index] && value[index],
                        child: FocusIconButton(
                          icons: Icons.crop_free_sharp,
                          iconForegroundColor: Colors.white,
                          iconBackgroundColor:
                              AppColors.iconPresentingBackground,
                          iconFocusBackgroundColor:
                              AppColors.iconFeatureOnStandbyBackground,
                          hasFocusSize: AppUIConstant.iconHasFocusSize,
                          notFocusSize: AppUIConstant.iconNotFocusSize,
                          onClick: () {
                            AppAnalytics()
                                .trackEventSplitScreenFullScreenClick();
                            SplitScreenFunction.isMenuOnList.value.fillRange(
                                0,
                                SplitScreenFunction.isMenuOnList.value.length,
                                false);
                            updateSize?.call();
                          },
                        ),
                      ),
                      // Using same button to show focus status at same button area.
                      FocusIconButton(
                        icons: Home.isSelectedList.value[index]
                            // Full screen mode
                            ? Icons.close_fullscreen
                            // Split screen mode
                            : (value[index])
                                // Menu On: display left/right
                                ? (index == 0 || index == 2)
                                    ? Icons.chevron_right
                                    : Icons.chevron_left
                                // Menu Off: display cloud icon
                                : Icons.more_vert,
                        iconForegroundColor: Colors.white,
                        iconBackgroundColor: AppColors.iconPresentingBackground,
                        iconFocusBackgroundColor:
                            AppColors.iconFeatureOnStandbyBackground,
                        hasFocusSize: AppUIConstant.iconHasFocusSize,
                        notFocusSize: AppUIConstant.iconNotFocusSize,
                        onClick: () {
                          if (Home.isSelectedList.value[index]) {
                            // Full screen mode: update size
                            updateSize?.call();
                          } else {
                            // Split screen mode: switch menu on/off
                            SplitScreenFunction.isMenuOnList.value[index] =
                                !SplitScreenFunction.isMenuOnList.value[index];
                            // Using below method to trigger value changed.
                            // https://github.com/flutter/flutter/issues/29958
                            SplitScreenFunction.isMenuOnList.value = List.from(
                                SplitScreenFunction.isMenuOnList.value);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
