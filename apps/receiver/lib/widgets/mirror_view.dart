import 'package:display_flutter/generated/l10n.dart';
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
              width: MediaQuery.of(context).size.width / 3,
              height: MediaQuery.of(context).size.height / 2,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.airplay,
                          color: Colors.white,
                        ),
                        Text(
                          S.of(context).main_airplay_pin_code,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      mirror.pinCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                  ],
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
