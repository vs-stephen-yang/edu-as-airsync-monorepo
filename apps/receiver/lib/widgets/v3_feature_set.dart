import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/screens/v3_cast_devices_menu.dart';
import 'package:display_flutter/screens/v3_participants_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3FeatureSet extends StatefulWidget {
  const V3FeatureSet({super.key});

  @override
  State<StatefulWidget> createState() => _V3FeatureSetState();
}

class _V3FeatureSetState extends State<V3FeatureSet> {
  bool _isModeratorOnScreen = false;
  bool _isCastDeviceOnScreen = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelProvider>(builder: (_, channelProvider, __) {
      int featureCount = 0;
      bool showModerator = false;
      bool showCastDevice = false;
      if (ChannelProvider.isModeratorMode) {
        featureCount++;
        showModerator = true;
        if (HybridConnectionList.hybridSplitScreenCount.value == 0) {
          // remove if not on streaming.
          featureCount--;
          showModerator = false;
        }
      }
      if (channelProvider.isSenderMode) {
        featureCount++;
        showCastDevice = true;
      }
      return showModerator || showCastDevice
          ? Positioned(
              right: 0,
              bottom: 80,
              child: SizedBox(
                width: 41,
                height: featureCount == 2 ? 123 : 68,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 32,
                        height: featureCount == 2 ? 123 : 68,
                        decoration: BoxDecoration(
                          color:
                              context.tokens.color.vsdslColorOnSurfaceInverse,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    if (showModerator) ...[
                      Positioned(
                        top: 20,
                        right: 3,
                        child: SizedBox(
                          width: 27,
                          height: 27,
                          child: IconButton(
                            icon: Image(
                              image: Svg(_isModeratorOnScreen
                                  ? 'assets/images/ic_streaming_moderator_on.svg'
                                  : 'assets/images/ic_streaming_moderator_off.svg'),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              _showParticipantsMenuDialog(context);
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 9,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Color(0xFF5D80ED),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          padding: EdgeInsets.zero,
                          child: AutoSizeText(
                            HybridConnectionList()
                                .getConnectionCount()
                                .toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: context
                                  .tokens.color.vsdslColorOnSurfaceInverse,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (featureCount == 2)
                      Positioned(
                        top: 61,
                        right: 5,
                        child: Container(
                          width: 21,
                          height: 1,
                          color: context.tokens.color.vsdslColorOutline,
                        ),
                      ),
                    if (showCastDevice) ...[
                      Positioned(
                        right: 3,
                        bottom: 20,
                        child: SizedBox(
                          width: 27,
                          height: 27,
                          child: IconButton(
                            icon: Image(
                              image: Svg(_isCastDeviceOnScreen
                                  ? 'assets/images/ic_streaming_device_list_on.svg'
                                  : 'assets/images/ic_streaming_device_list_off.svg'),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              _showCastDeviceMenuDialog(context);
                            },
                          ),
                        ),
                      ),
                      if (channelProvider.remoteScreenConnectors.isNotEmpty)
                        Positioned(
                          left: 0,
                          top: featureCount == 2 ? 64 : 9,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFF5D80ED),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            padding: EdgeInsets.zero,
                            child: AutoSizeText(
                              channelProvider.remoteScreenConnectors.length
                                  .toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: context
                                    .tokens.color.vsdslColorOnSurfaceInverse,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            )
          : const SizedBox.shrink();
    });
  }

  _showParticipantsMenuDialog(BuildContext context) async {
    setState(() {
      _isModeratorOnScreen = true;
    });
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return const V3ParticipantsMenu();
      },
    ).then((_) {
      setState(() {
        _isModeratorOnScreen = false;
      });
    });
  }

  _showCastDeviceMenuDialog(BuildContext context) async {
    setState(() {
      _isCastDeviceOnScreen = true;
    });
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return const V3CastDevicesMenu();
      },
    ).then((_) {
      setState(() {
        _isCastDeviceOnScreen = false;
      });
    });
  }
}
