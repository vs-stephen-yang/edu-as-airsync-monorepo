import 'dart:async';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/utilities/connect_timer.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_cast_flutter/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3PresentSelectScreen extends StatelessWidget {
  const V3PresentSelectScreen({super.key});

  static SelectScreenDialog? selectScreenDialog;

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (WebRTC.platformIsDesktop) {
        // MacOS and Windows
        await _handleDesktopPlatform(context, channelProvider);
      } else {
        // Android and iOS and Web
        if (WebRTC.platformIsAndroid) {
          // Android specific
          await Helper.requestCapturePermission();
          await _requestBackgroundPermission();
        }
        var value = CustomDesktopCapturerSource(null, true);
        channelProvider.presentStart(
            selectedSource: value.selectedSource,
            systemAudio: value.systemAudio);
      }
    });

    if (WebRTC.platformIsIOS) {
      return _buildIosView(context, channelProvider);
    }
    return const SizedBox();
  }

  Future<void> _handleDesktopPlatform(
      BuildContext context, ChannelProvider provider) async {
    // start timeout timer (30 sec)
    ConnectionTimer.getInstance().startConnectionTimeoutTimer(() {
      log.info('timeout');
      // onFinish
      selectScreenDialog?.cancel();
    });

    await showDialog<CustomDesktopCapturerSource>(
      context: context,
      builder: (context) => selectScreenDialog = SelectScreenDialog(),
    ).then((value) {
      log.info('selectedSource: ${value?.selectedSource?.type})');
      ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
      if (value != null && value.selectedSource != null) {
        if (WebRTC.platformIsWindows &&
            value.selectedSource?.type != SourceType.Window) {
          provider.presentStart(
              selectedSource: value.selectedSource,
              systemAudio: value.systemAudio);
        } else {
          provider.presentStart(selectedSource: value.selectedSource);
        }
      } else {
        SelectScreenDialog._timer?.cancel();
        for (var element in selectScreenDialog!._subscriptions) {
          element.cancel();
        }
        // moderator mode
        if (provider.moderatorStatus) {
          provider.presentStop();
          Provider.of<PresentStateProvider>(context, listen: false)
              .presentModeratorWaitPage();
        } else {
          provider.presentStop();
          provider.presentEnd();
        }
      }
    });
  }

  Future<void> _requestBackgroundPermission() async {
    // Required for android screen share.
    try {
      var hasPermissions = await FlutterBackground.hasPermissions;
      const androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: 'Screen Sharing',
        notificationText: 'AirSync is sharing the screen.',
        notificationImportance: AndroidNotificationImportance.normal,
        notificationIcon: AndroidResource(
          name: 'ic_launcher',
          defType: 'mipmap',
        ),
        // Above Android 12 will has some issue if set below option true.
        shouldRequestBatteryOptimizationsOff: false,
      );

      hasPermissions =
          await FlutterBackground.initialize(androidConfig: androidConfig);

      if (hasPermissions && !FlutterBackground.isBackgroundExecutionEnabled) {
        await FlutterBackground.enableBackgroundExecution();
      }
    } catch (e, stackTrace) {
      log.severe('could not publish video: $e', e, stackTrace);
    }
  }

  Widget _buildIosView(BuildContext context, ChannelProvider provider) {
    return Stack(
      children: [
        Positioned(
          left: 30,
          top: 100,
          child: InkWell(
            onTap: () {
              provider.presentStop();
              provider.presentEnd();
            },
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: Colors.white,
                  size: 14,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    S.of(context).moderator_back,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppConstants.fontSizeNormal),
                  ),
                ),
              ],
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: AppConstants.viewStateMenuWidth,
                child: Text(
                  S.of(context).present_select_screen_ios_restart_description,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () {
                  // WebRTC already connected,
                  // just call "makeCall" to restart broadcast extension.
                  provider.makeCall(selectedSource: null);
                },
                child: Text(
                  S.of(context).present_select_screen_ios_restart,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//ignore: must_be_immutable
class SelectScreenDialog extends Dialog {
  SelectScreenDialog({super.key}) {
    Future.delayed(const Duration(milliseconds: 100), () {
      _getSources(SourceType.Screen);
    });

    _subscriptions.add(desktopCapturer.onAdded.stream.listen((source) {
      _sources[source.id] = source;
      _stateSetter?.call(() {});
    }));

    _subscriptions.add(desktopCapturer.onRemoved.stream.listen((source) {
      _sources.remove(source.id);
      _stateSetter?.call(() {});
    }));

    _subscriptions
        .add(desktopCapturer.onThumbnailChanged.stream.listen((source) {
      _stateSetter?.call(() {});
    }));
  }

  final List<StreamSubscription<DesktopCapturerSource>> _subscriptions = [];
  final Map<String, DesktopCapturerSource> _sources = {};
  static DesktopCapturerSource? _selectedSource;
  static StateSetter? _stateSetter;
  static Timer? _timer;
  late BuildContext ctx;
  bool _systemAudio = false;

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 1081,
          height: 661,
          decoration: ShapeDecoration(
            color: context.tokens.color.vsdswColorSurface100,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: context.tokens.color.vsdswColorNeutral,
              ),
              borderRadius: context.tokens.radii.vsdswRadius2xl,
            ),
            shadows: context.tokens.shadow.vsdswShadowNeutralLg,
          ),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 24, left: 33),
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).present_role_cast_screen,
                            style: TextStyle(
                              color: context.tokens.color.vsdswColorOnSurface,
                              fontSize: 24,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Gap(8),
                          Text(
                            'Cast-4782 wants to share your screen. Choose what to share. ',
                            style: TextStyle(
                              color: context.tokens.color.vsdswColorOnSurface,
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 14, right: 14, bottom: 14),
                          child: Icon(Icons.close,
                              size: 20,
                              color: context.tokens.color.vsdswColorOnSurface),
                        ),
                        onTap: () => cancel(),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(15),
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: double.infinity,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      _stateSetter = setState;
                      return DefaultTabController(
                        length: 3,
                        child: Builder(builder: (context) {
                          TabController tabController =
                              DefaultTabController.of(context);
                          return Column(
                            children: <Widget>[
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 33),
                                constraints:
                                    const BoxConstraints.expand(height: 48),
                                child: TabBar(
                                  onTap: (value) {
                                    Future.delayed(
                                        const Duration(milliseconds: 300), () {
                                      _getSources(value == 0
                                          ? SourceType.Screen
                                          : SourceType.Window);
                                    });
                                  },
                                  tabs: [
                                    Tab(
                                      child: buildTabWidget(S.current
                                          .present_select_screen_entire),
                                    ),
                                    Tab(
                                      child: buildTabWidget(S.current
                                          .present_select_screen_window),
                                    ),
                                    Tab(
                                      child: buildTabWidget('Screen extension'),
                                    ),
                                  ],
                                  labelColor:
                                      context.tokens.color.vsdswColorSecondary,
                                  unselectedLabelColor:
                                      context.tokens.color.vsdswColorOnSurface,
                                  indicatorColor:
                                      context.tokens.color.vsdswColorSecondary,
                                ),
                              ),
                              const Gap(8),
                              Expanded(
                                child: Container(
                                  color: const Color(0x14151C32),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 64),
                                  child: TabBarView(
                                    children: [
                                      Align(
                                          alignment: Alignment.topCenter,
                                          child: GridView.count(
                                            crossAxisCount: 3,
                                            childAspectRatio: 1.39,
                                            children: _sources.entries
                                                .where((element) =>
                                                    element.value.type ==
                                                    SourceType.Screen)
                                                .map((e) => ThumbnailWidget(
                                                      onTap: (source) {
                                                        setState(() {
                                                          _selectedSource =
                                                              source;
                                                        });
                                                      },
                                                      source: e.value,
                                                      selected:
                                                          _selectedSource?.id ==
                                                              e.value.id,
                                                    ))
                                                .toList(),
                                          )),
                                      Align(
                                          alignment: Alignment.center,
                                          child: GridView.count(
                                            crossAxisCount: 3,
                                            childAspectRatio: 1.39,
                                            children: _sources.entries
                                                .where((element) =>
                                                    element.value.type ==
                                                    SourceType.Window)
                                                .map((e) => ThumbnailWidget(
                                                      onTap: (source) {
                                                        setState(() {
                                                          _selectedSource =
                                                              source;
                                                        });
                                                      },
                                                      source: e.value,
                                                      selected:
                                                          _selectedSource?.id ==
                                                              e.value.id,
                                                    ))
                                                .toList(),
                                          )),
                                      SizedBox(), // todo
                                    ],
                                  ),
                                ),
                              ),
                              if (WebRTC.platformIsWindows && tabController.index == SourceType.Screen.index)
                                Container(
                                  margin:
                                      const EdgeInsets.only(top: 28, left: 32),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _systemAudio,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(2.0),
                                        ),
                                        side: WidgetStateBorderSide.resolveWith(
                                              (states) => BorderSide(width: 1.0, color: context.tokens.color.vsdswColorPrimary),
                                        ),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _systemAudio = value!;
                                          });
                                        },
                                      ),
                                      const Gap(8),
                                      Text(
                                        'Share computer audio.',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            color: context.tokens.color.vsdswColorOnSurface),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 96,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(top: 16,right: 33),
                child: Row(
                  children: <Widget>[
                    const Spacer(),
                    createButton(
                        text: S.of(context).present_select_screen_cancel,
                        textColor: context.tokens.color.vsdswColorOnSurface,
                        backgroundColor: Colors.transparent,
                        onPressed: () {
                          cancel();
                        }),

                    createButton(
                      text: 'Share',
                      textColor: context.tokens.color.vsdswColorOnPrimary,
                      backgroundColor: context.tokens.color.vsdswColorPrimary,
                      onPressed: () {
                        ChannelProvider channelProvider = Provider.of<ChannelProvider>(context, listen: false);
                        if (channelProvider.isConnectAvailable()) {
                          _ok(_selectedSource, _systemAudio);
                        } else {
                          Toast.makeFeatureReconnectToast(
                              channelProvider.reconnectState,
                              channelProvider.reconnectState == ChannelReconnectState.reconnecting
                                  ? S.current.main_feature_reconnecting_toast
                                  : S.current.main_feature_reconnect_fail_toast);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTabWidget(String text) {
    return Container(
      alignment: Alignment.center,
      width: 338.67,
      height: 48,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget createButton(
      {required String text,
      required Color textColor,
      required Color backgroundColor,
      required GestureTapCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        width: 240,
        height: 48,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          shadows: backgroundColor != Colors.transparent?[
            BoxShadow(
              color: backgroundColor.withOpacity(0.31),
              blurRadius: 24,
              offset: const Offset(0, 16),
              spreadRadius: 0,
            )
          ]:null,
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  void cancel() async {
    _timer?.cancel();
    for (var element in _subscriptions) {
      element.cancel();
    }
    Navigator.pop<CustomDesktopCapturerSource>(ctx, null);
  }

  void _ok(DesktopCapturerSource? selectedSource, bool systemAudio) async {
    _timer?.cancel();
    for (var element in _subscriptions) {
      element.cancel();
    }
    Navigator.pop<CustomDesktopCapturerSource>(
        ctx, CustomDesktopCapturerSource(selectedSource, systemAudio));
  }

  Future<void> _getSources(SourceType sourceType) async {
    try {
      var sources = await desktopCapturer.getSources(types: [sourceType]);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        desktopCapturer.updateSources(types: [sourceType]);
      });
      _sources.clear();
      for (var element in sources) {
        _sources[element.id] = element;
      }
      _stateSetter?.call(() {});
      return;
    } catch (e, stackTrace) {
      log.severe('Failed to capture desktop', e, stackTrace);
    }
  }
}

class CustomDesktopCapturerSource {
  DesktopCapturerSource? selectedSource;
  bool systemAudio = false;

  CustomDesktopCapturerSource(this.selectedSource, this.systemAudio);
}

class ThumbnailWidget extends StatefulWidget {
  const ThumbnailWidget(
      {super.key,
      required this.source,
      required this.selected,
      required this.onTap});

  final DesktopCapturerSource source;
  final bool selected;
  final Function(DesktopCapturerSource) onTap;

  @override
  State createState() => _ThumbnailWidgetState();
}

class _ThumbnailWidgetState extends State<ThumbnailWidget> {
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _subscriptions.add(widget.source.onThumbnailChanged.stream.listen((event) {
      setState(() {});
    }));
    _subscriptions.add(widget.source.onNameChanged.stream.listen((event) {
      setState(() {});
    }));
  }

  @override
  void deactivate() {
    for (var element in _subscriptions) {
      element.cancel();
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              log.info('Selected source id => ${widget.source.id}');
              widget.onTap(widget.source);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(4),
              decoration: widget.selected
                  ? BoxDecoration(
                      border: Border.all(
                          width: 4,
                          color: context.tokens.color.vsdswColorSecondary),
                      borderRadius: context.tokens.radii.vsdswRadiusLg,
                    )
                  : null,
              child: widget.source.thumbnail != null
                  ? Image.memory(
                      fit: BoxFit.fill,
                      widget.source.thumbnail!,
                      gaplessPlayback: true,
                      // alignment: Alignment.center,
                    )
                  : Container(),
            ),
          ),
        ),
        const Gap(8),
        Text(
          widget.source.name,
          style: TextStyle(
              fontSize: 16,
              color: context.tokens.color.vsdswColorOnSurface,
              fontWeight:
                  widget.selected ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }
}
