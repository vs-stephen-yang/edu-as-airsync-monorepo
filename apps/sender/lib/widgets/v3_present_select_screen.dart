import 'dart:async';
import 'dart:io';

import 'package:display_cast_flutter/annotation/annotation_model.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/audio_switch_manager.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_cast_flutter/utilities/version_util.dart';
import 'package:display_cast_flutter/widgets/V3_focus.dart';
import 'package:display_cast_flutter/widgets/toast.dart';
import 'package:display_cast_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_cast_flutter/widgets/v3_back_button.dart';
import 'package:display_cast_flutter/widgets/v3_custom_white_button.dart';
import 'package:display_cast_flutter/widgets/v3_scroll_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_virtual_display/flutter_virtual_display.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:sprintf/sprintf.dart';

class V3PresentSelectScreen extends StatelessWidget {
  const V3PresentSelectScreen({super.key});

  bool get platformIsDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);

    final audioSwitchManager = context.read<AudioSwitchManager>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (platformIsDesktop) {
        // MacOS and Windows
        await _handleDesktopPlatform(
            context, channelProvider, audioSwitchManager);
      } else {
        // Android and iOS
        if (Platform.isAndroid) {
          // Android specific
          await Helper.requestCapturePermission();
          await _requestBackgroundPermission();
        }
        var value = CustomDesktopCaptureSource(null, true, false);
        await channelProvider.presentStart(
            selectedSource: value.selectedSource,
            systemAudio: value.systemAudio);
      }
    });

    if (Platform.isIOS) {
      return _buildIosView(context, channelProvider);
    }
    return const SizedBox();
  }

  Future<void> _handleDesktopPlatform(BuildContext context,
      ChannelProvider provider, AudioSwitchManager audioSwitchManager) async {
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context, listen: false);
    bool isSupported = (Platform.isWindows || VersionUtil.isOpenVersion)
        ? (await FlutterVirtualDisplay.instance.isSupported() ?? false)
        : false;

    final isVirtualAudioMissing =
        await audioSwitchManager.isVirtualAudioMissing();
    if (!context.mounted) return;
    await showDialog<CustomDesktopCaptureSource>(
      context: context,
      builder: (context) {
        return SelectScreenDialog(
          hostName: provider.deviceName ?? '',
          isExtensionEnable:
              (Platform.isWindows || VersionUtil.isOpenVersion) && isSupported,
          annotationModel: context.read<AnnotationModel>(),
          isVirtualAudioMissing: isVirtualAudioMissing,
        );
      },
    ).then((value) async {
      log.info('selectedSource: ${value?.selectedSource?.type})');
      if (value != null && value.selectedSource != null) {
        if (WebRTC.platformIsDesktop &&
            value.selectedSource?.type != SourceType.Window) {
          await provider.presentStart(
              selectedSource: value.selectedSource,
              systemAudio: value.systemAudio,
              autoVirtualDisplay: value.isExtensionSelected);
        } else {
          await provider.presentStart(selectedSource: value.selectedSource);
        }
      } else {
        if (Platform.isWindows || VersionUtil.isOpenVersion) {
          await FlutterVirtualDisplay.instance.stopVirtualDisplay();
        }
        // moderator mode
        if (provider.moderatorStatus) {
          await provider.presentStop();
          await presentStateProvider.presentModeratorWaitPage();
        } else {
          await provider.presentStop();
          await provider.presentEnd();
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
                label: S.of(context).v3_lbl_select_screen_ios_back,
                identifier: 'v3_qa_select_screen_ios_back',
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
                    'assets/images/v3_ic_ios_start_sharing.svg',
                    excludeFromSemantics: true,
                  ),
                ),
                Padding(padding: context.tokens.spacing.vsdswSpacingLg),
                SizedBox(
                  width: 327,
                  child: V3AutoHyphenatingText(
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
                Padding(padding: context.tokens.spacing.vsdswSpacingLg),
                V3CustomWhiteButton(
                  label: S.of(context).v3_lbl_select_screen_ios_start_sharing,
                  identifier: 'v3_qa_select_screen_ios_start_sharing',
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

class SelectScreenDialog extends StatefulWidget {
  final String hostName;
  final bool isExtensionEnable;
  final AnnotationModel annotationModel;
  final bool isVirtualAudioMissing;

  const SelectScreenDialog({
    super.key,
    required this.hostName,
    required this.isExtensionEnable,
    required this.annotationModel,
    required this.isVirtualAudioMissing,
  });

  @override
  State<SelectScreenDialog> createState() => _SelectScreenDialogState();
}

class _SelectScreenDialogState extends State<SelectScreenDialog> {
  StreamSubscription? _virtualDisplaySubscription;
  StreamSubscription? _virtualDisplayErrorSubscription;
  final List<StreamSubscription<DesktopCapturerSource>> _subscriptions = [];
  final Map<String, DesktopCapturerSource> _sources = {};
  DesktopCapturerSource? _selectedSource;
  Timer? _timer;
  bool _systemAudio = false;
  bool _isExtensionSelected = false;
  bool _enableAudioCheckbox = true;
  bool _isSubmitting = false;

  bool get platformIsDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      _getSources([SourceType.Screen, SourceType.Window]);
    });

    _subscriptions.add(desktopCapturer.onAdded.stream.listen((source) {
      if (!mounted) return;
      setState(() {
        _sources[source.id] = source;
      });
    }));

    _subscriptions.add(desktopCapturer.onRemoved.stream.listen((source) {
      if (!mounted) return;
      setState(() {
        _sources.remove(source.id);
      });
    }));

    _subscriptions
        .add(desktopCapturer.onThumbnailChanged.stream.listen((source) {
      if (!mounted) return;
      setState(() {});
    }));
    widget.annotationModel.presentSourceType = SourceType.Screen;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _virtualDisplaySubscription?.cancel();
    for (var element in _subscriptions) {
      element.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hostName = widget.hostName.length > 20
        ? '${widget.hostName.substring(0, 20)}...'
        : widget.hostName;

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 661, maxWidth: 1081),
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
                        V3AutoHyphenatingText(
                          S.of(context).present_role_cast_screen,
                          style: TextStyle(
                            color: context.tokens.color.vsdswColorOnSurface,
                            fontSize: 24,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Gap(8),
                        V3AutoHyphenatingText(
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
                      child: V3Focus(
                        identifier: 'v3_qa_select_screen_close',
                        child: InkWell(
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            width: 48,
                            height: 48,
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color:
                                  context.tokens.color.vsdswColorSurfaceInverse,
                              semanticLabel:
                                  S.of(context).v3_lbl_select_screen_close,
                            ),
                          ),
                          onTap: () => _cancel(),
                        ),
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
                  child: DefaultTabController(
                    length: 3,
                    child: Builder(builder: (context) {
                      final sourceSelected =
                          _selectedSource != null || _isExtensionSelected;
                      TabController tabController =
                          DefaultTabController.of(context);
                      double bottomHeight = 55;
                      if (platformIsDesktop && _enableAudioCheckbox) {
                        bottomHeight += 48;
                        if (widget.isVirtualAudioMissing) {
                          bottomHeight += 48;
                        }
                      }
                      final sc = ScrollController();
                      return Column(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 33),
                            constraints: const BoxConstraints(maxHeight: 48),
                            child: V3Scrollbar(
                              controller: sc,
                              child: SingleChildScrollView(
                                controller: sc,
                                child: TabBar(
                                  onTap: (index) async {
                                    _selectedSource = null;
                                    if (index == 2) {
                                      if (widget.isExtensionEnable) {
                                        _isExtensionSelected = true;
                                      } else {
                                        tabController.animateTo(
                                            tabController.previousIndex);
                                      }
                                    } else {
                                      _isExtensionSelected = false;
                                    }
                                    switch (index) {
                                      case 0:
                                        widget.annotationModel
                                                .presentSourceType =
                                            SourceType.Screen;
                                        break;
                                      case 1:
                                        widget.annotationModel
                                                .presentSourceType =
                                            SourceType.Window;
                                        break;
                                      case 2:
                                        widget.annotationModel
                                            .presentSourceType = null;
                                        break;
                                    }
                                    if (!mounted) return;
                                    setState(() {
                                      _enableAudioCheckbox = (index != 1);
                                    });
                                  },
                                  tabs: [
                                    V3Focus(
                                      identifier: 'v3_qa_select_screen_entire',
                                      child: _buildTabWidget(
                                          context,
                                          S.current
                                              .present_select_screen_entire),
                                    ),
                                    V3Focus(
                                      identifier: 'v3_qa_select_screen_window',
                                      child: _buildTabWidget(
                                          context,
                                          S.current
                                              .present_select_screen_window),
                                    ),
                                    V3Focus(
                                      identifier:
                                          'v3_qa_select_screen_extension',
                                      child: _buildTabWidget(
                                          context,
                                          S.current
                                              .v3_present_select_screen_extension,
                                          enable: widget.isExtensionEnable),
                                    ),
                                  ],
                                  labelColor:
                                      context.tokens.color.vsdswColorSecondary,
                                  unselectedLabelColor:
                                      context.tokens.color.vsdswColorOnSurface,
                                  indicatorColor:
                                      context.tokens.color.vsdswColorPrimary,
                                ),
                              ),
                            ),
                          ),
                          const Gap(8),
                          Expanded(
                            child: Container(
                              color: context.tokens.color.vsdswColorSurface200,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 64),
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
                          const Gap(10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 33),
                            constraints:
                                BoxConstraints(maxHeight: bottomHeight),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  if (platformIsDesktop &&
                                      _enableAudioCheckbox) ...[
                                    Row(
                                      children: [
                                        const Gap(5),
                                        V3Focus(
                                          identifier:
                                              'v3_qa_select_screen_audio',
                                          child: Checkbox(
                                            semanticLabel: S
                                                .of(context)
                                                .v3_lbl_select_screen_audio,
                                            value: _systemAudio,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(2.0),
                                            ),
                                            side: WidgetStateBorderSide
                                                .resolveWith(
                                              (states) => BorderSide(
                                                  width: 1.0,
                                                  color: (!widget
                                                          .isVirtualAudioMissing)
                                                      ? context.tokens.color
                                                          .vsdswColorPrimary
                                                      : context.tokens.color
                                                          .vsdswColorDisabled),
                                            ),
                                            onChanged:
                                                (!widget.isVirtualAudioMissing)
                                                    ? (bool? value) {
                                                        if (!mounted) {
                                                          return;
                                                        }
                                                        setState(() {
                                                          _systemAudio = value!;
                                                        });
                                                      }
                                                    : null,
                                          ),
                                        ),
                                        const Gap(8),
                                        Flexible(
                                          child: V3AutoHyphenatingText(
                                            S.current
                                                .v3_present_select_screen_share_audio,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Inter',
                                                color: (!widget
                                                        .isVirtualAudioMissing)
                                                    ? context.tokens.color
                                                        .vsdswColorOnSurface
                                                    : context.tokens.color
                                                        .vsdswColorDisabled),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (widget.isVirtualAudioMissing)
                                      MergeSemantics(
                                        child: Row(
                                          children: [
                                            const Gap(8),
                                            SvgPicture.asset(
                                              width: 16,
                                              height: 16,
                                              'assets/images/v3_ic_audio_driver_warning.svg',
                                            ),
                                            const Gap(8),
                                            Flexible(
                                              child: V3AutoHyphenatingText(
                                                S.current
                                                    .v3_present_select_screen_mac_audio_driver,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'Inter',
                                                    color: context.tokens.color
                                                        .vsdswColorWarning),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      _createButton(
                                        label: S
                                            .of(context)
                                            .v3_lbl_select_screen_cancel,
                                        identifier:
                                            'v3_qa_select_screen_cancel',
                                        text: S
                                            .of(context)
                                            .present_select_screen_cancel,
                                        textColor: context
                                            .tokens.color.vsdswColorPrimary,
                                        backgroundColor: Colors.transparent,
                                        borderColor: context
                                            .tokens.color.vsdswColorSecondary,
                                        onPressed: () => _cancel(),
                                      ),
                                      _createButton(
                                        label: S
                                            .of(context)
                                            .v3_lbl_select_screen_share,
                                        identifier: 'v3_qa_select_screen_share',
                                        text:
                                            S.current.v3_main_select_role_share,
                                        textColor: sourceSelected
                                            ? context.tokens.color
                                                .vsdswColorOnPrimary
                                            : context.tokens.color
                                                .vsdswColorOnDisabled,
                                        backgroundColor: sourceSelected
                                            ? context
                                                .tokens.color.vsdswColorPrimary
                                            : context.tokens.color
                                                .vsdswColorDisabled,
                                        onPressed: () {
                                          if (!sourceSelected ||
                                              _isSubmitting) {
                                            return;
                                          }
                                          setState(() {
                                            _isSubmitting = true;
                                          });
                                          ChannelProvider channelProvider =
                                              Provider.of<ChannelProvider>(
                                                  context,
                                                  listen: false);
                                          if (channelProvider
                                              .isConnectAvailable()) {
                                            _ok(_selectedSource, _systemAudio,
                                                _isExtensionSelected);
                                          } else {
                                            setState(() {
                                              _isSubmitting = false;
                                            });
                                            Toast.makeFeatureReconnectToast(
                                                channelProvider.reconnectState,
                                                channelProvider
                                                            .reconnectState ==
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
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabWidget(BuildContext context, String text,
      {bool enable = true}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: V3AutoHyphenatingText(
            text,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Inter',
              color: enable
                  ? context.tokens.color.vsdswColorOnSurface
                  : context.tokens.color.vsdswColorOnDisabled,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Gap(4),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: context.tokens.color.vsdswColorTertiary,
            borderRadius: const BorderRadius.all(Radius.circular(18.0)),
          ),
        )
      ],
    );
  }

  Widget _createButton(
      {required String label,
      required String identifier,
      required String text,
      required Color textColor,
      required Color backgroundColor,
      required GestureTapCallback onPressed,
      Color? borderColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: V3Focus(
        identifier: identifier,
        label: label,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            alignment: Alignment.center,
            width: 240,
            height: 38,
            clipBehavior: Clip.antiAlias,
            decoration: borderColor == null
                ? ShapeDecoration(
                    color: backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    shadows: backgroundColor != Colors.transparent
                        ? [
                            BoxShadow(
                              color: backgroundColor.withValues(alpha: 0.31),
                              blurRadius: 24,
                              offset: const Offset(0, 16),
                              spreadRadius: 0,
                            )
                          ]
                        : null,
                  )
                : BoxDecoration(
                    border: Border.all(color: borderColor, width: 1.0),
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(9999),
                  ),
            child: V3AutoHyphenatingText(
              text,
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      ),
    );
  }

  void _cancel() {
    if (mounted) {
      Navigator.pop<CustomDesktopCaptureSource>(context, null);
    }
  }

  String _getShareName(
      DesktopCapturerSource? selectedSource, bool isExtensionSelected) {
    if (isExtensionSelected) return 'extension';
    if (selectedSource == null) return 'screen';
    return selectedSource.type == SourceType.Screen ? 'screen' : 'application';
  }

  void _clearVirtualDisplaySubscriptions() {
    _virtualDisplaySubscription?.cancel();
    _virtualDisplaySubscription = null;
    _virtualDisplayErrorSubscription?.cancel();
    _virtualDisplayErrorSubscription = null;
  }

  Future<bool> _startAndWaitForVirtualDisplay() async {
    // Clear previous subscription if it exists
    _clearVirtualDisplaySubscriptions();

    // Create a Completer to handle asynchronous waiting
    final completer = Completer<bool>();

    // Set up a listener that triggers when the virtual display starts
    _virtualDisplaySubscription = FlutterVirtualDisplay
        .instance.onVirtualDisplayStarted.stream
        .listen((_) {
      if (!completer.isCompleted) {
        completer.complete(true);
        _clearVirtualDisplaySubscriptions();
        log.info('Virtual display started');
      }
    });

    // Add error handling
    _virtualDisplayErrorSubscription = FlutterVirtualDisplay
        .instance.onVirtualDisplayError.stream
        .listen((errorMsg) {
      if (!completer.isCompleted) {
        completer.complete(false);
        _clearVirtualDisplaySubscriptions();
        log.severe('Virtual display error: $errorMsg');
      }
    });

    // Start the virtual display
    log.info('Starting virtual display');
    final display = await ScreenRetriever.instance.getPrimaryDisplay();
    final scale = (display.scaleFactor ?? 1).toDouble();
    final pixelWidth = (display.size.width * scale).round();
    final pixelHeight = (display.size.height * scale).round();

    final startResult = await FlutterVirtualDisplay.instance
        .startVirtualDisplay(pixelWidth, pixelHeight);

    if (startResult != true) {
      if (!completer.isCompleted) {
        completer.complete(false);
        _clearVirtualDisplaySubscriptions();
        log.warning('Failed to start virtual display');
      }
      return false;
    }

    // Wait for the virtual display to start or timeout
    try {
      final result = await completer.future.timeout(const Duration(seconds: 5));
      if (result) {
        await _waitForVirtualDisplayRegistration();
        if (Platform.isWindows) {
          await _switchToExtendedDisplayMode();
        }
      }
      return result;
    } on TimeoutException {
      log.warning('Timed out waiting for virtual display to start');
      return false;
    } catch (e) {
      log.severe('Unexpected error during virtual display startup: $e');
      return false;
    } finally {
      _clearVirtualDisplaySubscriptions();
    }
  }

  Future<void> _waitForVirtualDisplayRegistration() async {
    const pollingInterval = Duration(milliseconds: 333);
    const maxWait = Duration(seconds: 3);

    final initialSources =
        await desktopCapturer.getSources(types: [SourceType.Screen]);
    final baseScreenNumber = initialSources.length;
    _sources.clear();
    for (var element in initialSources) {
      _sources[element.id] = element;
    }

    StreamSubscription<DesktopCapturerSource> localSubscription =
        desktopCapturer.onAdded.stream.listen((source) {
      _sources[source.id] = source;
    });

    try {
      final stopwatch = Stopwatch()..start();
      while (stopwatch.elapsed <= maxWait) {
        await desktopCapturer.updateSources(types: [SourceType.Screen]);
        // 等待 _subscriptions 更新狀態
        await Future.delayed(const Duration(milliseconds: 50));

        int currentScreenCount =
            _sources.values.where((s) => s.type == SourceType.Screen).length;
        if (currentScreenCount > baseScreenNumber) {
          log.info('Virtual display detected');
          return;
        }
        await Future.delayed(pollingInterval);
      }
      log.warning(
          'Virtual display not detected within timeout; attempting display switch anyway.');
    } finally {
      await localSubscription.cancel();
    }
  }

  Future<void> _switchToExtendedDisplayMode() async {
    final systemRoot = Platform.environment['SystemRoot'];
    if (systemRoot == null) {
      log.warning(
          'SystemRoot environment variable missing; skipping display mode switch.');
      return;
    }

    final candidatePaths = <String>[
      '$systemRoot\\Sysnative\\DisplaySwitch.exe',
      '$systemRoot\\System32\\DisplaySwitch.exe',
      '$systemRoot\\SysWOW64\\DisplaySwitch.exe',
    ];

    String? displaySwitchPath;
    for (final path in candidatePaths) {
      if (await File(path).exists()) {
        displaySwitchPath = path;
        break;
      }
    }

    if (displaySwitchPath == null) {
      log.warning(
          'DisplaySwitch.exe not found in candidate locations; skipping display mode switch.');
      return;
    }

    log.info('Using DisplaySwitch path: $displaySwitchPath');

    // Give Windows a moment to register the virtual display before switching modes.
    await Future.delayed(const Duration(seconds: 1));

    try {
      final result =
          await Process.run(displaySwitchPath, ['/extend'], runInShell: true);
      if (result.exitCode != 0) {
        log.warning(
            'DisplaySwitch.exe failed (exit ${result.exitCode}): ${result.stderr}');
      } else {
        log.info('DisplaySwitch.exe succeeded: ${result.stdout}');
      }
    } catch (error, stackTrace) {
      log.severe(
          'Error while switching display mode to extend', error, stackTrace);
    }
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
      await element.cancel();
    }
    CustomDesktopCaptureSource? captureSource;
    if (isExtensionSelected) {
      final success = await _startAndWaitForVirtualDisplay();
      if (success) {
        _selectedSource = _sources.values.last;
        widget.annotationModel.selectedSource = null;
        captureSource = CustomDesktopCaptureSource(
            _selectedSource, systemAudio, isExtensionSelected);
      } else {
        log.warning('Failed to start virtual display');
        if (mounted) {
          _isSubmitting = false;
        }
      }
    } else {
      widget.annotationModel.selectedSource = selectedSource;
      widget.annotationModel.setScreenIndex(selectedSource?.name ?? '');
      captureSource = CustomDesktopCaptureSource(
          selectedSource, systemAudio, isExtensionSelected);
    }

    if (mounted) {
      Navigator.pop<CustomDesktopCaptureSource>(context, captureSource);
    }
  }

  Future<void> _getSources(List<SourceType> sourceTypes) async {
    try {
      final sources = await desktopCapturer.getSources(types: sourceTypes);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (mounted) {
          desktopCapturer.updateSources(types: sourceTypes);
        } else {
          timer.cancel();
        }
      });
      _sources.clear();
      for (var element in sources) {
        _sources[element.id] = element;
      }
      if (mounted) {
        setState(() {});
      }
      return;
    } catch (e, stackTrace) {
      log.severe('Failed to capture desktop', e, stackTrace);
    }
  }

  Widget _buildGridView(SourceType type) {
    final sc = ScrollController();
    return Align(
      alignment: Alignment.topCenter,
      child: V3Scrollbar(
        controller: sc,
        child: GridView.count(
          controller: sc,
          crossAxisCount: 3,
          childAspectRatio: 1.39,
          children: _sources.entries
              .where((element) => element.value.type == type)
              .map(
            (map) {
              return ThumbnailWidget(
                onTap: (source) {
                  if (mounted) {
                    setState(() {
                      _selectedSource = source;
                    });
                  }
                },
                source: map.value,
                selected: _selectedSource?.id == map.value.id,
              );
            },
          ).toList(),
        ),
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
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 286,
            height: 185,
            child: Lottie.asset('assets/lottie_files/screen_extension.json'),
          ),
          const Gap(32),
          V3AutoHyphenatingText(
            S.current.v3_present_select_screen_extension_desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.tokens.color.vsdswColorOnSurface,
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(8),
          SizedBox(
            child: V3AutoHyphenatingText(
              S.current.v3_present_select_screen_extension_desc2,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.tokens.color.vsdswColorOnSurface,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
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
    final source = widget.source;
    final sourceName = source.name.length > 20
        ? '${source.name.substring(0, 20)}...'
        : source.name;
    return V3Focus(
      label:
          sprintf(S.of(context).v3_lbl_select_screen_source_name, [sourceName]),
      identifier: sprintf('v3_qa_select_screen_source_name_%s', [sourceName]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                log.info('Selected source id => ${source.id}');
                widget.onTap(source);
              },
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(4),
                decoration: widget.selected
                    ? BoxDecoration(
                        border: Border.all(
                            width: 4,
                            color: context.tokens.color.vsdswColorPrimary),
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
          Flexible(
            child: V3AutoHyphenatingText(
              sourceName,
              style: TextStyle(
                  fontSize: 16,
                  color: context.tokens.color.vsdswColorOnSurface,
                  fontWeight:
                      widget.selected ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}
