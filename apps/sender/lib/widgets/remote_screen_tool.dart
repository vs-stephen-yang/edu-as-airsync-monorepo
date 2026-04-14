import 'dart:math' as math;

import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/app_colors.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:display_cast_flutter/widgets/focus_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RemoteScreenTool extends StatefulWidget {
  const RemoteScreenTool({
    super.key,
    this.isModeratorShare = false,
  });

  final bool isModeratorShare;

  @override
  State createState() => _RemoteScreenToolStates();
}

class _RemoteScreenToolStates extends State<RemoteScreenTool> {
  Offset _position = const Offset(0, 0);
  RenderBox? box;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (context.findRenderObject() is RenderBox) {
        box = context.findRenderObject() as RenderBox;
        var width = MediaQuery.of(context).size.width;
        if (!mounted) return;
        setState(() {
          _position = Offset(width - box!.size.width - 25, 25);
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Draggable(
        onDragEnd: (details) {
          if (!mounted) return;
          setState(() {
            _position = details.offset;
          });
        },
        feedback: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FocusIconButton(
              icons: Icons.exit_to_app,
              iconForegroundColor: Colors.white,
              iconBackgroundColor: AppColors.iconFeatureBackground,
              iconFocusBackgroundColor: AppColors.iconFeatureBackground,
              hasFocusSize: AppConstants.iconHasFocusSize,
              notFocusSize: AppConstants.iconNotFocusSize,
              rotateY: math.pi,
              onClick: () {},
            ),
          ],
        ),
        childWhenDragging: const SizedBox.shrink(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FocusIconButton(
              icons: Icons.exit_to_app,
              iconForegroundColor: Colors.white,
              iconBackgroundColor: AppColors.iconFeatureBackground,
              iconFocusBackgroundColor: AppColors.iconFeatureBackground,
              hasFocusSize: AppConstants.iconHasFocusSize,
              notFocusSize: AppConstants.iconNotFocusSize,
              rotateY: math.pi,
              onClick: () {
                if (widget.isModeratorShare) {
                  channelProvider.removeShareRemoteScreenClient();
                } else {
                  channelProvider.removeRemoteScreenClient();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
