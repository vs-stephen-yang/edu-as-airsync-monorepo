import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/screens/debug_switch.dart';
import 'package:display_flutter/widgets/v3_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class V3HeaderBar extends StatefulWidget {
  const V3HeaderBar({super.key, this.isWaitForStream = false});

  final bool isWaitForStream;

  @override
  State<StatefulWidget> createState() => _V3HeaderBarState();
}

class _V3HeaderBarState extends State<V3HeaderBar> {
  int debugCounter = 0;
  final int openDebugCounter = 5;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 25,
      top: 25,
      right: 25,
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                excludeFromSemantics: true,
                onTap: () {
                  debugCounter++;
                  if (debugCounter == openDebugCounter) {
                    _showMenuDialog(const DebugSwitch());
                    debugCounter = 0;
                  }
                },
                child: SvgPicture.asset(
                  'assets/images/ic_logo_airsync_icon.svg',
                  excludeFromSemantics: true,
                  width: 36,
                  height: 36,
                ),
              ),
              MultiWindowAdaptiveLayout(
                landscape: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(padding: EdgeInsets.only(left: 7)),
                    SvgPicture.asset(
                      'assets/images/ic_logo_airsync_text.svg',
                      excludeFromSemantics: true,
                      width: 140,
                      height: 31,
                      colorFilter: ColorFilter.mode(
                        widget.isWaitForStream ? Colors.white : Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
                landscapeOneThird: SizedBox.shrink(),
                landscapeHalf: SizedBox.shrink(),
              ),
            ],
          ),
          Expanded(
              child: !widget.isWaitForStream ? const V3Status() : SizedBox()),
        ],
      ),
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
}
