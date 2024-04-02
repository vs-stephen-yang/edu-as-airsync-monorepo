import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MirrorView extends StatefulWidget {
  const MirrorView({super.key, required this.index});

  final int index;

  @override
  State<StatefulWidget> createState() => MirrorViewState();
}

class MirrorViewState extends State<MirrorView> {
  GlobalKey mirrorViewKey = GlobalKey();
  MirrorRequest? mirrorRequest;

  @override
  void deactivate() {
    mirrorRequest = null;
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    mirrorRequest =
        HybridConnectionList().getConnection<MirrorRequest>(widget.index);
    return Consumer<MirrorStateProvider>(
      builder: (context, mirror, child) {
        return ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Stack(
            children: [
              if (mirrorRequest?.mirrorState == MirrorState.mirroring)
                Container(
                  color: Colors.black,
                  child: Center(
                    child: NotificationListener<SizeChangedLayoutNotification>(
                      onNotification: (notification) {
                        mirror.onWidgetSizeChanged();
                        return true;
                      },
                      child: SizeChangedLayoutNotifier(
                        child: Listener(
                          onPointerDown: (PointerDownEvent event) {
                            mirror.onTouchEvent(
                                event, mirrorRequest?.mirrorId, mirrorViewKey);
                          },
                          onPointerMove: (PointerMoveEvent event) {
                            mirror.onTouchEvent(
                                event, mirrorRequest?.mirrorId, mirrorViewKey);
                          },
                          onPointerUp: (PointerUpEvent event) {
                            mirror.onTouchEvent(
                                event, mirrorRequest?.mirrorId, mirrorViewKey);
                          },
                          child: AspectRatio(
                            key: mirrorViewKey,
                            aspectRatio: mirrorRequest?.aspectRatio ?? 2 / 3,
                            child: Texture(textureId: mirrorRequest?.textureId ?? 0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
