import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/v3_demo_provider.dart';
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
              // const RemoteVideoView(),
              // Positioned.fill(
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
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 50,
                      padding: EdgeInsets.symmetric(
                        vertical: context.tokens.spacing.vsdswSpacingXs.top,
                        horizontal: context.tokens.spacing.vsdswSpacingMd.left,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            width: 2,
                            color: context.tokens.color.vsdswColorOnSurface,
                          ),
                          top: BorderSide(
                            width: 2,
                            color: context.tokens.color.vsdswColorOnSurface,
                          ),
                          right: BorderSide(
                            width: 2,
                            color: context.tokens.color.vsdswColorOnSurface,
                          ),
                        ),
                        borderRadius: BorderRadius.only(
                            topLeft: context.tokens.radii.vsdswRadiusXl.topLeft,
                            topRight:
                                context.tokens.radii.vsdswRadiusXl.topRight),
                        color: context.tokens.color.vsdswColorSuccess,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AutoSizeText(
                            S.current.v3_main_receive_app_receive_from
                                .replaceAll('%s', 'ViewSonic Service'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: context.tokens.color.vsdswColorOnSuccess,
                            ),
                            maxLines: 1,
                          ),
                          SizedBox(
                              width:
                                  context.tokens.spacing.vsdswSpacingMd.right),
                          ElevatedButton.icon(
                            onPressed: () {
                              channelProvider.presentDemoOff();
                            },
                            label: Text(
                              S.of(context).v3_main_receive_app_stop,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.tokens.color.vsdswColorOnSurface,
                              ),
                            ),
                            icon: Icon(
                              Icons.stop,
                              size: 16,
                              color: context.tokens.color.vsdswColorError,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
