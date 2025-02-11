import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/screens/v3_cast_devices_menu.dart';
import 'package:display_flutter/screens/v3_participants_menu.dart';
import 'package:display_flutter/widgets/focus_aware_builder.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
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
    return Consumer2<ChannelProvider, MirrorStateProvider>(
      builder: (context, channelProvider, mirrorProvider, widget) {
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (V3CastDevicesMenu.fromShortcut) {
            _showCastDeviceMenuDialog(context);
          }
        });
        final isFullFeature = featureCount == 2;
        return showModerator || showCastDevice
            ? Positioned(
                left: 0,
                bottom: 80,
                child: SizedBox(
                  width: 41,
                  height: isFullFeature ? 123 : 68,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        bottom: 0,
                        child: Container(
                          width: 32,
                          height: isFullFeature ? 123 : 68,
                          decoration: BoxDecoration(
                            color:
                                context.tokens.color.vsdslColorOnSurfaceInverse,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      if (featureCount == 1 &&
                          (_isModeratorOnScreen || _isCastDeviceOnScreen))
                        Positioned(
                          top: 0,
                          left: 0,
                          bottom: 0,
                          child: Container(
                            width: 32,
                            height: isFullFeature ? 123 : 68,
                            decoration: BoxDecoration(
                              color: context.tokens.color.vsdslColorSurface300,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      if (isFullFeature &&
                          (_isModeratorOnScreen || _isCastDeviceOnScreen))
                        Positioned(
                          top: _isModeratorOnScreen ? 0 : 61.5,
                          left: 0,
                          bottom: _isModeratorOnScreen ? 61.5 : 0,
                          child: Container(
                            width: 32,
                            height: 61.5,
                            decoration: BoxDecoration(
                              color: context.tokens.color.vsdslColorSurface300,
                              borderRadius: BorderRadius.only(
                                topRight: _isModeratorOnScreen
                                    ? const Radius.circular(20)
                                    : Radius.zero,
                                bottomRight: _isCastDeviceOnScreen
                                    ? const Radius.circular(20)
                                    : Radius.zero,
                              ),
                            ),
                          ),
                        ),
                      if (showModerator)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: isFullFeature ? 61.5 : 0,
                          child: V3Focus(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 20,
                                  left: 3,
                                  right: 10,
                                  child: SizedBox(
                                    width: 27,
                                    height: 27,
                                    child: IconButton(
                                      icon: const Image(
                                        image: Svg(
                                            'assets/images/ic_streaming_moderator_off.svg'),
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        trackEvent(
                                          'click_connection_info',
                                          EventCategory.session,
                                          mode: 'webrtc',
                                        );
                                        _showParticipantsMenuDialog(context);
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
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
                                      HybridConnectionList()
                                          .getConnectionCount()
                                          .toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: context.tokens.color
                                            .vsdslColorOnSurfaceInverse,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (isFullFeature)
                        Positioned(
                          top: 61,
                          left: 5,
                          child: Container(
                            width: 21,
                            height: 1,
                            color: context.tokens.color.vsdslColorOutline,
                          ),
                        ),
                      if (showCastDevice)
                        Positioned(
                          left: 0,
                          top: isFullFeature ? 61.5 : 0,
                          right: 0,
                          bottom: 0,
                          child: V3Focus(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                if (channelProvider
                                    .remoteScreenConnectors.isNotEmpty)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: (channelProvider
                                                .remoteScreenConnectionFull)
                                            ? context
                                                .tokens.color.vsdslColorError
                                            : const Color(0xFF5D80ED),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      padding: EdgeInsets.zero,
                                      child: AutoSizeText(
                                        channelProvider
                                            .remoteScreenConnectors.length
                                            .toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: context.tokens.color
                                              .vsdslColorOnSurfaceInverse,
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  left: 3,
                                  right: 10,
                                  bottom: 20,
                                  child: SizedBox(
                                    width: 27,
                                    height: 27,
                                    child: IconButton(
                                      icon: const Image(
                                        image: Svg(
                                            'assets/images/ic_streaming_device_list_off.svg'),
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        _showCastDeviceMenuDialog(context);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }

  _showParticipantsMenuDialog(BuildContext context) async {
    setState(() {
      _isModeratorOnScreen = true;
    });
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) => FocusAwareBuilder(
          builder: (primaryFocusNode) =>
              V3ParticipantsMenu(primaryFocusNode: primaryFocusNode)),
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
    trackEvent('click_cast_to_device_icon', EventCategory.setting);

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return FocusAwareBuilder(
          builder: (FocusNode primaryFocusNode) =>
              V3CastDevicesMenu(primaryFocusNode: primaryFocusNode),
        );
      },
    ).then((_) {
      setState(() {
        _isCastDeviceOnScreen = false;
      });
    });
  }
}
