import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/v3_demo_provider.dart';
import 'package:display_cast_flutter/widgets/resizable_draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class V3RemoteScreenDemo extends StatefulWidget {
  const V3RemoteScreenDemo({super.key, this.isModeratorShare = false});

  final bool isModeratorShare;

  @override
  State<StatefulWidget> createState() => _V3RemoteScreenDemoState();
}

class _V3RemoteScreenDemoState extends State<V3RemoteScreenDemo> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: OrientationBuilder(
        builder: (_, __) {
          V3DemoProvider channelProvider =
              Provider.of<V3DemoProvider>(context, listen: false);
          return Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/demo_remote.png',
                  fit: BoxFit.fill,
                ),
              ),
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 6,
                      color: context.tokens.color.vsdswColorOnSurface,
                    ),
                  ),
                ),
              ),
              ResizableDraggableWidget(
                halfScreen: MediaQuery.of(context).size.width / 2,
                text: S.current.v3_main_receive_app_receive_from
                    .replaceAll('%s', 'ViewSonic Service'),
                onStop: () {
                  channelProvider.presentDemoOff();
                },
              ),
              IgnorePointer(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 4,
                          color: context.tokens.color.vsdswColorSuccess,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
