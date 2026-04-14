import 'package:display_cast_flutter/demo/remote_screen_tool_demo.dart';
import 'package:flutter/material.dart';

class RemoteScreenDemo extends StatelessWidget {
  const RemoteScreenDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: OrientationBuilder(builder: (_, __) {
        return Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/images/demo_remote.png',
                fit: BoxFit.fill,
              ),
            ),
            RemoteScreenToolDemo(key: GlobalKey()),
          ],
        );
      }),
    );
  }
}
