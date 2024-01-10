
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/app_colors.dart';
import 'package:display_cast_flutter/utilities/app_ui_constant.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';

import 'focus_icon_button.dart';

class StreamFunctionTool extends StatefulWidget {
  const StreamFunctionTool({super.key});

  @override
  State createState() => _StreamFunctionToolStates();
}

class _StreamFunctionToolStates extends State<StreamFunctionTool> {
  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    return Stack(
      children: <Widget>[
        Container(
          width: AppUIConstant.featureContainerWidth,
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
                  hasFocusSize: AppUIConstant.iconHasFocusSize,
                  notFocusSize: AppUIConstant.iconNotFocusSize,
                  rotateY: math.pi,
                  onClick: () {
                    channelProvider.removeRemoteScreenClient();
                  }),
            ],
          ),
        ),
      ],
    );
  }

}