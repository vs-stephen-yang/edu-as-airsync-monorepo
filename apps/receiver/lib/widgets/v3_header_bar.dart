import 'package:display_flutter/screens/debug_switch.dart';
import 'package:display_flutter/widgets/v3_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

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
      top: 30,
      right: 25,
      child: Row(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  debugCounter++;
                  if (debugCounter == openDebugCounter) {
                    _showMenuDialog(const DebugSwitch());
                    debugCounter = 0;
                  }
                },
                child: const Image(
                  image: Svg('assets/images/ic_logo_airsync_icon.svg'),
                  height: 36,
                  width: 36,
                ),
              ),
              const Padding(padding: EdgeInsets.only(left: 7)),
              Image(
                image: const Svg('assets/images/ic_logo_airsync_text.svg'),
                height: 31,
                width: 140,
                color: widget.isWaitForStream ? Colors.white : Colors.black,
              ),
            ],
          ),
          const Spacer(),
          if (!widget.isWaitForStream) const V3Status(),
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
