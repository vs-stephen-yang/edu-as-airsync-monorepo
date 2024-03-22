
import 'package:display_cast_flutter/demo/remote_screen_tool_demo.dart';
import 'package:flutter/material.dart';

class RemoteScreenDemo extends StatelessWidget {
  const RemoteScreenDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: FittedBox(
            fit: BoxFit.fill,
            child: Image.asset('assets/images/demo_remote.png'),
          )
          ),
        const Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          child: StreamFunctionToolDemo(),
        ),
      ],
    );
  }
}
