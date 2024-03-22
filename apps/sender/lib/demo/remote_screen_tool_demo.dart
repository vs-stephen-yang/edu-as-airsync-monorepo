
import 'package:display_cast_flutter/providers/demo_provider.dart';
import 'package:display_cast_flutter/utilities/app_colors.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:display_cast_flutter/widgets/focus_icon_button.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';

class StreamFunctionToolDemo extends StatefulWidget {
  const StreamFunctionToolDemo({super.key});

  @override
  State createState() => _StreamFunctionToolStates();
}

class _StreamFunctionToolStates extends State<StreamFunctionToolDemo> {
  @override
  Widget build(BuildContext context) {
    DemoProvider demoProvider = Provider.of<DemoProvider>(context);
    return Stack(
      children: <Widget>[
        Container(
          width: AppConstants.featureContainerWidth,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FocusIconButton(
                  icons: Icons.exit_to_app,
                  iconForegroundColor: Colors.white,
                  iconBackgroundColor: AppColors.iconFeatureOnStandbyBackground,
                  iconFocusBackgroundColor:
                  AppColors.iconFeatureOnStandbyBackground,
                  hasFocusSize: AppConstants.iconHasFocusSize,
                  notFocusSize: AppConstants.iconNotFocusSize,
                  rotateY: math.pi,
                  onClick: () {
                    demoProvider.isDemoMode = false;
                    demoProvider.setViewState(DemoViewState.off);
                  }),
            ],
          ),
        ),
      ],
    );
  }

}