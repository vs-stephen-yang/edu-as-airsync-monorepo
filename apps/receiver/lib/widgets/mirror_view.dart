import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MirrorView extends StatelessWidget {
  const MirrorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MirrorStateProvider>(
      builder: (context, mirror, child) {
        switch (mirror.state) {
          case MirrorState.showPinCode:
            return Container(
              color: Colors.white,
              width: 160,
              height: 90,
              child: Center(
                child: Text(
                  mirror.pinCode,
                  style: const TextStyle(fontSize: 25),
                ),
              ),
            );
          case MirrorState.mirroring:
            return ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Listener(
                    onPointerDown: mirror.onTouchEvent,
                    onPointerMove: mirror.onTouchEvent,
                    onPointerUp: mirror.onTouchEvent,
                    child: AspectRatio(
                      key: mirror.mirrorViewKey,
                      aspectRatio: mirror.aspectRatio,
                      child: Texture(textureId: mirror.textureId!),
                    ),
                  ),
                ),
              ),
            );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
