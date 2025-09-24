import 'dart:async';

import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/utilities/connect_timer.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_cast_flutter/utilities/version_util.dart';
import 'package:display_cast_flutter/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_virtual_display/flutter_virtual_display.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

class PresentSelectScreen extends StatelessWidget {
  const PresentSelectScreen({super.key});

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
        unawaited(channelProvider.presentStart(
            selectedSource: value.selectedSource,
            systemAudio: value.systemAudio));
      }
    });

    if (WebRTC.platformIsIOS) {
      return _buildIosView(context, channelProvider);
    }
    return const SizedBox();
  }

  Future<void> _handleDesktopPlatform(
      BuildContext context, ChannelProvider provider) async {
    if (WebRTC.platformIsWindows || VersionUtil.isOpenVersion) {
      await FlutterVirtualDisplay.instance.startVirtualDisplay();
    }

    // start timeout timer (30 sec)
    ConnectionTimer.getInstance().startConnectionTimeoutTimer(() {
      log.info('timeout');
      // onFinish
      selectScreenDialog?.cancel();
    });

    await showDialog<CustomDesktopCapturerSource>(
      context: context,
      builder: (context) => selectScreenDialog = SelectScreenDialog(),
    ).then((value) async {
      log.info('selectedSource: ${value?.selectedSource?.type})');
      ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
      if (value != null && value.selectedSource != null) {
        if (WebRTC.platformIsWindows &&
            value.selectedSource?.type != SourceType.Window) {
          unawaited(provider.presentStart(
              selectedSource: value.selectedSource,
              systemAudio: value.systemAudio));
        } else {
          unawaited(
              provider.presentStart(selectedSource: value.selectedSource));
        }
      } else {
        if (WebRTC.platformIsWindows || VersionUtil.isOpenVersion) {
          await FlutterVirtualDisplay.instance.stopVirtualDisplay();
        }
        SelectScreenDialog._timer?.cancel();
        for (var element in selectScreenDialog!._subscriptions) {
          unawaited(element.cancel());
        }
        // moderator mode
        if (provider.moderatorStatus) {
          unawaited(provider.presentStop());
          unawaited(Provider.of<PresentStateProvider>(context, listen: false)
              .presentModeratorWaitPage());
        } else {
          unawaited(provider.presentStop());
          unawaited(provider.presentEnd());
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
          width: 640,
          height: 560,
          color: const Color.fromARGB(255, 63, 63, 63),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10),
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        S.of(context).present_select_screen_description,
                        style: const TextStyle(
                            fontSize: AppConstants.fontSizeTitle,
                            color: Colors.white),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        child: const Icon(Icons.close, color: Colors.white),
                        onTap: () => cancel(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      _stateSetter = setState;
                      return DefaultTabController(
                        length: 2,
                        child: Builder(builder: (context) {
                          TabController tabController =
                              DefaultTabController.of(context);
                          return Column(
                            children: <Widget>[
                              Container(
                                constraints:
                                    const BoxConstraints.expand(height: 24),
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
                                        child: Text(
                                      S
                                          .of(context)
                                          .present_select_screen_entire,
                                      // style: const TextStyle(color: Colors.white60),
                                    )),
                                    Tab(
                                        child: Text(
                                      S
                                          .of(context)
                                          .present_select_screen_window,
                                      // style: const TextStyle(color: Colors.white60),
                                    )),
                                  ],
                                  labelColor:
                                      const Color.fromARGB(255, 147, 179, 242),
                                  unselectedLabelColor: Colors.white60,
                                  indicatorColor:
                                      const Color.fromARGB(255, 147, 179, 242),
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Expanded(
                                child: TabBarView(children: [
                                  Align(
                                      alignment: Alignment.center,
                                      child: GridView.count(
                                        crossAxisSpacing: 8,
                                        crossAxisCount: 2,
                                        children: _sources.entries
                                            .where((element) =>
                                                element.value.type ==
                                                SourceType.Screen)
                                            .map((e) => ThumbnailWidget(
                                                  onTap: (source) {
                                                    if (!context.mounted) {
                                                      return;
                                                    }
                                                    setState(() {
                                                      _selectedSource = source;
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
                                        crossAxisSpacing: 8,
                                        crossAxisCount: 3,
                                        children: _sources.entries
                                            .where((element) =>
                                                element.value.type ==
                                                SourceType.Window)
                                            .map((e) => ThumbnailWidget(
                                                  onTap: (source) {
                                                    if (!context.mounted) {
                                                      return;
                                                    }
                                                    setState(() {
                                                      _selectedSource = source;
                                                    });
                                                  },
                                                  source: e.value,
                                                  selected:
                                                      _selectedSource?.id ==
                                                          e.value.id,
                                                ))
                                            .toList(),
                                      )),
                                ]),
                              ),
                              if (WebRTC.platformIsWindows &&
                                  tabController.index ==
                                      SourceType.Screen.index)
                                Row(
                                  children: [
                                    Checkbox(
                                        value: _systemAudio,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _systemAudio = value!;
                                          });
                                        }),
                                    Text(
                                        S
                                            .of(context)
                                            .present_select_screen_share_audio,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ],
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
                padding: const EdgeInsets.all(10.0),
                child: ButtonBar(
                  children: <Widget>[
                    OutlinedButton(
                      child: Text(
                        S.of(context).present_select_screen_cancel,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 147, 179, 242)),
                      ),
                      onPressed: () {
                        cancel();
                      },
                    ),
                    ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            Color.fromARGB(255, 147, 179, 242)),
                      ),
                      onPressed: () {
                        ChannelProvider channelProvider =
                            Provider.of<ChannelProvider>(context,
                                listen: false);
                        if (channelProvider.isConnectAvailable()) {
                          _ok(_selectedSource, _systemAudio);
                        } else {
                          Toast.makeFeatureReconnectToast(
                              channelProvider.reconnectState,
                              channelProvider.reconnectState ==
                                      ChannelReconnectState.reconnecting
                                  ? S
                                      .of(context)
                                      .main_feature_reconnecting_toast
                                  : S
                                      .of(context)
                                      .main_feature_reconnect_fail_toast);
                        }
                      },
                      child: Text(
                        S.of(context).present_select_screen_share,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 63, 63, 63)),
                      ),
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

  void cancel() async {
    _timer?.cancel();
    for (var element in _subscriptions) {
      unawaited(element.cancel());
    }
    Navigator.pop<CustomDesktopCapturerSource>(ctx, null);
  }

  void _ok(DesktopCapturerSource? selectedSource, bool systemAudio) async {
    _timer?.cancel();
    for (var element in _subscriptions) {
      unawaited(element.cancel());
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
      if (!mounted) return;
      setState(() {});
    }));
    _subscriptions.add(widget.source.onNameChanged.stream.listen((event) {
      if (!mounted) return;
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
      children: [
        Expanded(
            child: Container(
          decoration: widget.selected
              ? BoxDecoration(
                  border: Border.all(width: 2, color: Colors.blueAccent))
              : null,
          child: InkWell(
            onTap: () {
              log.info('Selected source id => ${widget.source.id}');
              widget.onTap(widget.source);
            },
            child: widget.source.thumbnail != null
                ? Image.memory(
                    widget.source.thumbnail!,
                    gaplessPlayback: true,
                    alignment: Alignment.center,
                  )
                : Container(),
          ),
        )),
        Text(
          widget.source.name,
          style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight:
                  widget.selected ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }
}
