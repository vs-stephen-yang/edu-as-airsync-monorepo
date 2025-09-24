import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_ui_constant.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplitScreenFunction extends StatefulWidget {
  const SplitScreenFunction(
      {super.key, required this.index, this.updateSize, this.onClose});

  static ValueNotifier<List<bool>> isMenuOnList =
      ValueNotifier(List.filled(4, false, growable: false));

  final int index;
  final VoidCallback? updateSize;
  final VoidCallback? onClose;

  @override
  State<StatefulWidget> createState() => _SplitScreenFunctionState();
}

class _SplitScreenFunctionState extends State<SplitScreenFunction> {
  @override
  Widget build(BuildContext context) {
    double? left, top, bottom, right;
    if (Home.enlargedScreenPositionIndex.value == widget.index ||
        HybridConnectionList().getPresentingCount() == 1) {
      // full screen mode in right-bottom;
      right = 20;
      bottom = 20;
    } else {
      // 4 split screen in center corner
      if (widget.index == 1) {
        // right-top screen
        left = 20;
        bottom = 20;
      } else if (widget.index == 2) {
        // left-bottom screen
        right = 20;
        top = 20;
      } else if (widget.index == 3) {
        // right-bottom screen
        left = 20;
        top = 20;
      } else {
        // left-top screen
        right = 20;
        bottom = 20;
      }
    }
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: ValueListenableBuilder(
        valueListenable: SplitScreenFunction.isMenuOnList,
        builder: (BuildContext context, List<bool> value, Widget? child) {
          return Container(
            height: AppUIConstant.featureContainerHeight,
            alignment: Alignment.center,
            child: Wrap(
              textDirection: (widget.index == 0 || widget.index == 2)
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                if (Home.enlargedScreenPositionIndex.value != widget.index &&
                    value[widget.index])
                  FocusIconButton(
                    icons: Icons.close,
                    iconForegroundColor: Colors.white,
                    iconBackgroundColor: AppColors.iconPresentingBackground,
                    iconFocusBackgroundColor:
                        AppColors.iconFeatureOnStandbyBackground,
                    hasFocusSize: AppUIConstant.iconHasFocusSize,
                    notFocusSize: AppUIConstant.iconNotFocusSize,
                    onClick: () {
                      widget.onClose?.call();
                    },
                  ),
                if (Home.enlargedScreenPositionIndex.value != widget.index &&
                    value[widget.index])
                  Consumer<MirrorStateProvider>(
                    builder: (_, mirrorStateProvider, __) {
                      var isMute = HybridConnectionList()
                          .getAudioDisableStateByIndex(widget.index);
                      return FocusIconButton(
                        icons: isMute
                            ? Icons.volume_up_outlined
                            : Icons.volume_off_outlined,
                        iconForegroundColor: Colors.white,
                        iconBackgroundColor: AppColors.iconPresentingBackground,
                        iconFocusBackgroundColor:
                            AppColors.iconFeatureOnStandbyBackground,
                        hasFocusSize: AppUIConstant.iconHasFocusSize,
                        notFocusSize: AppUIConstant.iconNotFocusSize,
                        onClick: () {
                          if (!mounted) return;
                          setState(() {
                            HybridConnectionList()
                                .updateAudioEnableStateByIndex(
                                    widget.index, isMute, true);
                          });
                        },
                      );
                    },
                  ),
                if (Home.enlargedScreenPositionIndex.value != widget.index &&
                    value[widget.index] &&
                    HybridConnectionList().getPresentingCount() > 1)
                  FocusIconButton(
                    icons: Icons.crop_free_sharp,
                    iconForegroundColor: Colors.white,
                    iconBackgroundColor: AppColors.iconPresentingBackground,
                    iconFocusBackgroundColor:
                        AppColors.iconFeatureOnStandbyBackground,
                    hasFocusSize: AppUIConstant.iconHasFocusSize,
                    notFocusSize: AppUIConstant.iconNotFocusSize,
                    onClick: () {
                      SplitScreenFunction.isMenuOnList.value.fillRange(0,
                          SplitScreenFunction.isMenuOnList.value.length, false);
                      widget.updateSize?.call();
                    },
                  ),
                // Using same button to show focus status at same button area.
                FocusIconButton(
                  icons: Home.enlargedScreenPositionIndex.value == widget.index
                      // Full screen mode
                      ? Icons.close_fullscreen
                      // Split screen mode
                      : (value[widget.index])
                          // Menu On: display left/right
                          ? (widget.index == 0 || widget.index == 2)
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
                    if (Home.enlargedScreenPositionIndex.value ==
                        widget.index) {
                      // Full screen mode: update size
                      widget.updateSize?.call();
                    } else {
                      // Split screen mode: switch menu on/off
                      SplitScreenFunction.isMenuOnList.value[widget.index] =
                          !SplitScreenFunction.isMenuOnList.value[widget.index];
                      // Using below method to trigger value changed.
                      // https://github.com/flutter/flutter/issues/29958
                      SplitScreenFunction.isMenuOnList.value =
                          List.from(SplitScreenFunction.isMenuOnList.value);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
