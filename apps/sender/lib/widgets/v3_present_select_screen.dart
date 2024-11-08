import 'dart:async';
import 'dart:io';

import 'package:display_cast_flutter/annotation/annotation_model.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/utilities/connect_timer.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_cast_flutter/widgets/toast.dart';
import 'package:display_cast_flutter/widgets/v3_back_button.dart';
import 'package:display_cast_flutter/widgets/v3_custom_white_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_virtual_display/flutter_virtual_display.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

class V3PresentSelectScreen extends StatelessWidget {
  const V3PresentSelectScreen({super.key});

  static SelectScreenDialog? selectScreenDialog;

  bool get platformIsDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (platformIsDesktop) {
        // MacOS and Windows
        await _handleDesktopPlatform(context, channelProvider);
      } else {
        // Android and iOS
        if (Platform.isAndroid) {
          // Android specific
          await Helper.requestCapturePermission();
          await _requestBackgroundPermission();
        }
        var value = CustomDesktopCaptureSource(null, true, false);
        channelProvider.presentStart(
            selectedSource: value.selectedSource,
            systemAudio: value.systemAudio);
      }
    });

    if (Platform.isIOS) {
      return _buildIosView(context, channelProvider);
    }
    return const SizedBox();
  }

  Future<void> _handleDesktopPlatform(
      BuildContext context, ChannelProvider provider) async {
    bool isSupported = !Platform.isWindows
        ? false
        : (await FlutterVirtualDisplay.instance.isSupported() ?? false);
    // start timeout timer (30 sec)
    ConnectionTimer.getInstance().startConnectionTimeoutTimer(() {
      log.info('timeout');
      // onFinish
      selectScreenDialog?.cancel();
    });

    await showDialog<CustomDesktopCaptureSource>(
      context: context,
      builder: (context) {
        selectScreenDialog = SelectScreenDialog(
          hostName: provider.deviceName ?? '',
          isExtensionEnable: Platform.isWindows && isSupported,
          annotationModel: context.read<AnnotationModel>(),
        );
        return selectScreenDialog!;
      },
    ).then((value) async {
      log.info('selectedSource: ${value?.selectedSource?.type})');
      ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
      if (value != null && value.selectedSource != null) {
        if (Platform.isWindows &&
            value.selectedSource?.type != SourceType.Window) {
          provider.presentStart(
              selectedSource: value.selectedSource,
              systemAudio: value.systemAudio,
              autoVirtualDisplay: value.isExtensionSelected);
        } else {
          provider.presentStart(selectedSource: value.selectedSource);
        }
      } else {
        if (Platform.isWindows) {
          await FlutterVirtualDisplay.instance.stopVirtualDisplay();
        }
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
    MediaQueryData mediaQuery = MediaQuery.of(context);

    return Container(
      width: mediaQuery.size.width,
      height: mediaQuery.size.height,
      color: context.tokens.color.vsdswColorSurfaceInverse,
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 24,
            child: V3BackButton(
                isDarkTheme: true,
                onPressed: () {
                  provider.presentStop();
                  provider.presentEnd();
                }),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 138,
                  height: 120,
                  child: SvgPicture.asset(
                      'assets/images/v3_ic_ios_start_sharing.svg'),
                ),
                Padding(padding: context.tokens.spacing.vsdswSpacingLg),
                SizedBox(
                  width: 327,
                  child: Text(
                    S.of(context).present_select_screen_ios_restart_description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.tokens.color.vsdswColorOnSurfaceVariant,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Padding(padding: context.tokens.spacing.vsdswSpacingXs),
                const CountDownText(),
                Padding(padding: context.tokens.spacing.vsdswSpacingLg),
                V3CustomWhiteButton(
                  buttonSize: const Size(300, 48),
                  text: S.of(context).v3_select_screen_ios_start_sharing,
                  onPressed: () {
                    // WebRTC already connected,
                    // just call "makeCall" to restart broadcast extension.
                    provider.makeCall(selectedSource: null);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CountDownText extends StatefulWidget {
  const CountDownText({super.key});

  @override
  State<CountDownText> createState() => _CountDownTextState();
}

class _CountDownTextState extends State<CountDownText> {
  int countdown = 30;

  @override
  initState() {
    super.initState();
    // start timeout timer (30 sec)
    ConnectionTimer.getInstance().startConnectionTimeoutTimer(() {
      // onFinish
    }, onTick: (tick) {
      setState(() {
        countdown = 30 - tick;
      });
    });
  }

  @override
  void dispose() {
    ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${S.of(context).v3_select_screen_ios_countdown} 0:$countdown',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: context.tokens.color.vsdswColorWarning,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

//ignore: must_be_immutable
class SelectScreenDialog extends Dialog {
  SelectScreenDialog({
    super.key,
    required this.hostName,
    required this.isExtensionEnable,
    required this.annotationModel,
  }) {
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
    annotationModel.presentSourceType = SourceType.Screen;
  }

  final List<StreamSubscription<DesktopCapturerSource>> _subscriptions = [];
  final Map<String, DesktopCapturerSource> _sources = {};
  final bool isExtensionEnable;
  final AnnotationModel annotationModel;
  static DesktopCapturerSource? _selectedSource;
  static StateSetter? _stateSetter;
  static Timer? _timer;
  late BuildContext ctx;
  bool _systemAudio = false;
  bool _isExtensionSelected = false;

  bool get platformIsDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  String hostName;

  @override
  Widget build(BuildContext context) {
    hostName =
        hostName.length > 20 ? '${hostName.substring(0, 20)}...' : hostName;
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
                padding: const EdgeInsets.only(left: 32, top: 24),
                child: Stack(
                  children: <Widget>[
                    Column(
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
                          sprintf(S.current.v3_present_select_screen_subtitle,
                              [hostName]),
                          style: TextStyle(
                            color: context.tokens.color.vsdswColorOnSurface,
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          width: 48,
                          height: 48,
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
                                  onTap: (index) async {
                                    _selectedSource = null;
                                    if (index == 2) {
                                      if (isExtensionEnable) {
                                        _isExtensionSelected = true;
                                      } else {
                                        tabController.animateTo(
                                            tabController.previousIndex);
                                      }
                                    } else {
                                      _isExtensionSelected = false;
                                      Future.delayed(
                                          const Duration(milliseconds: 300),
                                          () {
                                        _getSources(index == 0
                                            ? SourceType.Screen
                                            : SourceType.Window);
                                      });
                                    }
                                    switch (index) {
                                      case 0:
                                        annotationModel.presentSourceType =
                                            SourceType.Screen;
                                        break;
                                      case 1:
                                        annotationModel.presentSourceType =
                                            SourceType.Window;
                                        break;
                                      case 2:
                                        annotationModel.presentSourceType =
                                            null;
                                        break;
                                    }
                                  },
                                  tabs: [
                                    Tab(
                                      child: buildTabWidget(
                                          context,
                                          S.current
                                              .present_select_screen_entire),
                                    ),
                                    Tab(
                                      child: buildTabWidget(
                                          context,
                                          S.current
                                              .present_select_screen_window),
                                    ),
                                    Tab(
                                      child: buildTabWidget(
                                          context,
                                          S.current
                                              .v3_present_select_screen_extension,
                                          enable: isExtensionEnable),
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
                                      _buildGridView(SourceType.Screen),
                                      _buildGridView(SourceType.Window),
                                      const Align(
                                        alignment: Alignment.center,
                                        child: ScreenExtensionPage(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 96,
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 33),
                                child: Row(
                                  children: <Widget>[
                                    if (platformIsDesktop &&
                                        tabController.index ==
                                            SourceType.Screen.index)
                                      SizedBox(
                                        height: 48,
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: _systemAudio,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(2.0),
                                              ),
                                              side: WidgetStateBorderSide
                                                  .resolveWith(
                                                (states) => BorderSide(
                                                    width: 1.0,
                                                    color: context.tokens.color
                                                        .vsdswColorPrimary),
                                              ),
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  _systemAudio = value!;
                                                });
                                              },
                                            ),
                                            const Gap(8),
                                            Text(
                                              S.current
                                                  .v3_present_select_screen_share_audio,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Inter',
                                                  color: context.tokens.color
                                                      .vsdswColorOnSurface),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const Spacer(),
                                    createButton(
                                      text: S
                                          .of(context)
                                          .present_select_screen_cancel,
                                      textColor: context
                                          .tokens.color.vsdswColorSecondary,
                                      backgroundColor: Colors.transparent,
                                      onPressed: () {
                                        cancel();
                                      },
                                    ),
                                    createButton(
                                      text: S.current.v3_main_select_role_share,
                                      textColor: context
                                          .tokens.color.vsdswColorOnPrimary,
                                      backgroundColor: context
                                          .tokens.color.vsdswColorPrimary,
                                      onPressed: () {
                                        ChannelProvider channelProvider =
                                            Provider.of<ChannelProvider>(
                                                context,
                                                listen: false);
                                        if (channelProvider
                                            .isConnectAvailable()) {
                                          _ok(_selectedSource, _systemAudio,
                                              _isExtensionSelected);
                                        } else {
                                          Toast.makeFeatureReconnectToast(
                                              channelProvider.reconnectState,
                                              channelProvider.reconnectState ==
                                                      ChannelReconnectState
                                                          .reconnecting
                                                  ? S.current
                                                      .main_feature_reconnecting_toast
                                                  : S.current
                                                      .main_feature_reconnect_fail_toast);
                                        }
                                      },
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
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTabWidget(BuildContext context, String text,
      {bool enable = true}) {
    return Container(
      alignment: Alignment.center,
      width: 338.67,
      height: 48,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Inter',
          color: enable ? null : context.tokens.color.vsdswColorOnDisabled,
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
          shadows: backgroundColor != Colors.transparent
              ? [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.31),
                    blurRadius: 24,
                    offset: const Offset(0, 16),
                    spreadRadius: 0,
                  )
                ]
              : null,
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
    Navigator.pop<CustomDesktopCaptureSource>(ctx, null);
  }

  String _getShareName(
      DesktopCapturerSource? selectedSource, bool isExtensionSelected) {
    if (isExtensionSelected) {
      return 'extension';
    }
    if (selectedSource == null) {
      return 'screen';
    }

    return selectedSource.type == SourceType.Screen ? 'screen' : 'application';
  }

  void _ok(DesktopCapturerSource? selectedSource, bool systemAudio,
      bool isExtensionSelected) async {
    trackEvent(
      'click_share_type',
      EventCategory.session,
      target: _getShareName(selectedSource, isExtensionSelected),
    );

    _timer?.cancel();
    for (var element in _subscriptions) {
      element.cancel();
    }
    if (isExtensionSelected) {
      await FlutterVirtualDisplay.instance.startVirtualDisplay();
      _selectedSource =
          (await desktopCapturer.getSources(types: [SourceType.Screen])).last;
      Navigator.pop<CustomDesktopCaptureSource>(
          ctx,
          CustomDesktopCaptureSource(
              _selectedSource, false, isExtensionSelected));
      annotationModel.selectedSource = null;
    } else {
      annotationModel.selectedSource = selectedSource;
      annotationModel.setScreenIndex(selectedSource?.name ?? '');
      Navigator.pop<CustomDesktopCaptureSource>(
          ctx,
          CustomDesktopCaptureSource(
              selectedSource, systemAudio, isExtensionSelected));
    }
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

  Widget _buildGridView(SourceType type) {
    return Align(
      alignment: Alignment.topCenter,
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.39,
        children:
            _sources.entries.where((element) => element.value.type == type).map(
          (map) {
            return ThumbnailWidget(
              onTap: (source) {
                _selectedSource = source;
                _stateSetter?.call(() {});
              },
              source: map.value,
              selected: _selectedSource?.id == map.value.id,
            );
          },
        ).toList(),
      ),
    );
  }
}

class ScreenExtensionPage extends StatelessWidget {
  const ScreenExtensionPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 286,
          height: 185,
          child: Lottie.asset('assets/lottie_files/screen_extension.json'),
        ),
        const Gap(32),
        Text(
          S.current.v3_present_select_screen_extension_desc,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.tokens.color.vsdswColorTertiary.withOpacity(0.64),
            fontSize: 20,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(8),
        SizedBox(
          width: 600,
          child: Text(
            S.current.v3_present_select_screen_extension_desc2,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.tokens.color.vsdswColorTertiary.withOpacity(0.64),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomDesktopCaptureSource {
  DesktopCapturerSource? selectedSource;
  bool systemAudio = false;
  bool isExtensionSelected = false;

  CustomDesktopCaptureSource(
      this.selectedSource, this.systemAudio, this.isExtensionSelected);
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
    final source = widget.source;
    final sourceName = source.name.length > 20
        ? '${source.name.substring(0, 20)}...'
        : source.name;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              log.info('Selected source id => ${source.id}');
              widget.onTap(source);
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
              child: source.thumbnail != null
                  ? Image.memory(
                      fit: BoxFit.fill,
                      source.thumbnail!,
                      gaplessPlayback: true,
                      // alignment: Alignment.center,
                    )
                  : Container(),
            ),
          ),
        ),
        const Gap(8),
        Text(
          sourceName,
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
