import 'dart:async';
import 'dart:io';

import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/v3_toast.dart';
import 'package:display_flutter/widgets/v3_bluetooth_touchback_status_notification.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_touchback_one_device_alert.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_mirror/bluetooth_touchback_status.dart';
import 'package:flutter_mirror/mirror_type.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

import 'focus_aware_builder.dart';

class V3StreamingFunction extends StatefulWidget {
  const V3StreamingFunction({
    super.key,
    required this.index,
    this.availableWidth,
  });

  final int index;
  final double? availableWidth;

  @override
  State<StatefulWidget> createState() => _V3StreamingFunctionState();
}

class _V3StreamingFunctionState extends State<V3StreamingFunction> {
  bool isCollapsed = false;
  bool? _ifpSupportsBluetoothHID;
  Timer? autoCollapseTimer;
  double? _currentX;
  double _widgetWidth = 0;
  double _previousWidgetWidth = 0;
  double _previousAvailableWidth = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_ifpSupportsBluetoothHID == null) {
        final String? deviceModel = await DeviceInfoVs.deviceType;
        if (deviceModel != null) {
          if (!mounted) return;
          setState(() {
            _ifpSupportsBluetoothHID = !_isUnsupportedIFPModel(deviceModel);
          });
        }
      }
    });
    _startAutoCollapseTimer();
  }

  @override
  void dispose() {
    autoCollapseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMirrorRequest =
        HybridConnectionList().isMirrorRequest(widget.index);
    final isAirplay = isMirrorRequest &&
        HybridConnectionList()
                .getConnection<MirrorRequest>(widget.index)
                .mirrorType ==
            MirrorType.airplay;

    final isHIDSupported = isAirplay &&
        (_ifpSupportsBluetoothHID ?? false) &&
        HybridConnectionList()
            .getConnection<MirrorRequest>(widget.index)
            .isBluetoothHIDSupported();

    final isStreamingExpandVisible =
        (context.splitScreenRatio == SplitScreenRatio.oneThirdFull ||
                HybridConnectionList.hybridSplitScreenCount.value > 1) &&
            (context.splitScreenRatio.widthFraction >
                SplitScreenRatio.floatingDefault.widthFraction);

    final isRTCWaiting =
        HybridConnectionList().isRTCConnectorWaitForStream(index: widget.index);

    final mirrorStateProvider =
        Provider.of<MirrorStateProvider>(context, listen: false);
    final hasNameLabel = _hasNameLabel();

    // Get available width from parameter or fallback to MediaQuery
    final availableWidth =
        widget.availableWidth ?? MediaQuery.of(context).size.width;

    // Calculate widget width
    getExpandedWidgetSize() {
      // In expanded mode, add width for two drag buttons (27px each = 54px total)
      double baseWidth = 54;
      // Add Touch Back button width (27) with 3 padding
      if (isHIDSupported && !isRTCWaiting) {
        baseWidth += 30;
      }
      // Add streaming collapse/expand button width (27) with 3 padding
      if (isStreamingExpandVisible && !isRTCWaiting) {
        baseWidth += 30;
      }
      // Add streaming mute/unmute button width (27) with 3 padding
      if (!isRTCWaiting) {
        baseWidth += 30;
      }
      // Add streaming stop button width with (27) 3 padding
      baseWidth += 30;
      // Add function minimize/expand button width with (27) 3 padding
      baseWidth += 30;
      return baseWidth;
    }

    _widgetWidth = isCollapsed ? 37 : getExpandedWidgetSize();

    // Initialize position to center only on first build
    _currentX ??= (availableWidth / 2) - (_widgetWidth / 2);

    // Adjust position when availableWidth changes (to maintain relative position)
    if (_previousAvailableWidth != 0 &&
        _previousAvailableWidth != availableWidth) {
      // Calculate center position in the previous available width
      final previousCenter = _currentX! + (_widgetWidth / 2);
      final previousCenterRatio = previousCenter / _previousAvailableWidth;

      // Apply the same ratio to the new available width
      final newCenter = previousCenterRatio * availableWidth;
      _currentX = newCenter - (_widgetWidth / 2);
    }

    // Adjust position when widget width changes (to keep center aligned)
    if (_previousWidgetWidth != 0 && _previousWidgetWidth != _widgetWidth) {
      final currentCenter = _currentX! + (_previousWidgetWidth / 2);
      _currentX = currentCenter - (_widgetWidth / 2);
    }

    _previousWidgetWidth = _widgetWidth;
    _previousAvailableWidth = availableWidth;

    // Clamp position within bounds
    _currentX = _currentX!
        .clamp(0.0, (availableWidth - _widgetWidth).clamp(0, double.infinity));

    final widgetHeight = isCollapsed ? 22.0 : 43.0;
    final totalHeight = isCollapsed ? 22.0 : 51.0; // including bottom padding

    return SizedBox(
      width: availableWidth,
      height: totalHeight,
      child: Stack(
        children: [
          Positioned(
            left: _currentX,
            bottom: 0,
            child: GestureDetector(
              // In collapsed mode, the entire widget is draggable
              onPanUpdate: isCollapsed
                  ? (details) {
                      if (!mounted) return;
                      setState(() {
                        _currentX = (_currentX! + details.delta.dx).clamp(
                            0.0,
                            (availableWidth - _widgetWidth)
                                .clamp(0, double.infinity));
                      });
                    }
                  : null,
              child: Padding(
                padding: isCollapsed
                    ? EdgeInsets.zero
                    : const EdgeInsets.only(bottom: 8),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                    width: _widgetWidth,
                    height: widgetHeight,
                  ),
                  child: Container(
                    padding: isCollapsed ? const EdgeInsets.only(top: 4) : null,
                    decoration: BoxDecoration(
                      color: context.tokens.color.vsdslColorOpacityNeutralXl
                          .withValues(alpha: 0.48),
                      borderRadius: isCollapsed
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50),
                            )
                          : context.tokens.radii.vsdslRadiusFull,
                    ),
                    child: Row(
                      mainAxisAlignment: isCollapsed
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Left drag button (only in expanded mode)
                        if (!isCollapsed) _buildDragButton(availableWidth),
                        Visibility(
                          visible:
                              !isCollapsed && isHIDSupported && !isRTCWaiting,
                          child: V3Focus(
                            label: S
                                .of(context)
                                .v3_lbl_streaming_airplay_touchback,
                            identifier: 'v3_qa_streaming_airplay_touchback',
                            child: SizedBox(
                              width: 27,
                              height: 27,
                              child: _TouchBackButton(
                                widget.index,
                                () => onTouchBackPressed(
                                  mirrorStateProvider,
                                  isMirrorRequest,
                                  context,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Use Visibility Widget to Maintain Focus on the Correct Icon During Collapse/Expand.
                        Visibility(
                          visible: !isCollapsed &&
                              isStreamingExpandVisible &&
                              !isRTCWaiting,
                          child: V3Focus(
                            label: HybridConnectionList()
                                        .enlargedScreenIndex
                                        .value ==
                                    widget.index
                                ? S.of(context).v3_lbl_streaming_view_minimize
                                : S.of(context).v3_lbl_streaming_view_expand,
                            identifier: HybridConnectionList()
                                        .enlargedScreenIndex
                                        .value ==
                                    widget.index
                                ? 'v3_qa_streaming_view_minimize'
                                : 'v3_qa_streaming_view_expand',
                            child: SizedBox(
                              width: 27,
                              height: 27,
                              child: IconButton(
                                icon: SvgPicture.asset(
                                  HybridConnectionList()
                                              .enlargedScreenIndex
                                              .value ==
                                          widget.index
                                      ? 'assets/images/ic_streaming_collapse.svg'
                                      : 'assets/images/ic_streaming_expand.svg',
                                ),
                                focusColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _startAutoCollapseTimer();
                                  if (isMirrorRequest) {
                                    var mirrorConnection =
                                        HybridConnectionList()
                                            .getConnection<MirrorRequest>(
                                                widget.index);
                                    if (mirrorConnection.mirrorState ==
                                        MirrorState.mirroring) {
                                      _updateSizeForSelected(widget.index);
                                      mirrorConnection.trackSessionEvent(
                                          'click_screen_size');
                                      return;
                                    }
                                  }
                                  var webrtcConnector = HybridConnectionList()
                                      .getConnection<RTCConnector>(
                                          widget.index);
                                  if (webrtcConnector
                                      .isChannelConnectAvailable()) {
                                    webrtcConnector
                                        .trackSessionEvent('click_screen_size');

                                    _updateSizeForSelected(widget.index);
                                  } else if (webrtcConnector
                                      .isChannelReconnect()) {
                                    webrtcConnector.clickButtonWhenReconnect =
                                        true;
                                    V3Toast().makeSplitScreenReconnectToast(
                                        context,
                                        S
                                            .of(context)
                                            .main_feature_reconnecting_toast,
                                        widget.index,
                                        isWebRTC: false,
                                        state: webrtcConnector
                                            .reconnectChannelState);
                                  } else {
                                    V3Toast().makeSplitScreenReconnectToast(
                                        context,
                                        S
                                            .of(context)
                                            .main_feature_reconnect_fail_toast,
                                        widget.index,
                                        isWebRTC: false,
                                        state: webrtcConnector
                                            .reconnectChannelState);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !isCollapsed && !isRTCWaiting,
                          child: Consumer<MirrorStateProvider>(
                            builder: (_, mirrorStateProvider, __) {
                              var isMute = HybridConnectionList()
                                  .getAudioDisableStateByIndex(widget.index);
                              return V3Focus(
                                label: isMute
                                    ? S.of(context).v3_lbl_streaming_view_unmute
                                    : S.of(context).v3_lbl_streaming_view_mute,
                                identifier: isMute
                                    ? 'v3_qa_streaming_view_unmute'
                                    : 'v3_qa_streaming_view_mute',
                                child: SizedBox(
                                  width: 27,
                                  height: 27,
                                  child: IconButton(
                                    icon: SvgPicture.asset(
                                      isMute
                                          ? 'assets/images/ic_streaming_unmute.svg'
                                          : 'assets/images/ic_streaming_mute.svg',
                                    ),
                                    focusColor: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      _startAutoCollapseTimer();

                                      if (!mounted) return;
                                      setState(() {
                                        HybridConnectionList()
                                            .updateAudioEnableStateByIndex(
                                                widget.index, isMute, true);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Visibility(
                          visible: !isCollapsed,
                          child: V3Focus(
                            label: S.of(context).v3_lbl_streaming_view_stop,
                            identifier: 'v3_qa_streaming_view_stop',
                            child: SizedBox(
                              width: 27,
                              height: 27,
                              child: IconButton(
                                icon: SvgPicture.asset(
                                  'assets/images/ic_streaming_stop.svg',
                                ),
                                focusColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  if (isMirrorRequest) {
                                    var connection = HybridConnectionList()
                                        .getConnection<MirrorRequest>(
                                            widget.index);
                                    if (connection.mirrorState ==
                                        MirrorState.mirroring) {
                                      if (ChannelProvider.isModeratorMode) {
                                        mirrorStateProvider
                                            .setModeratorIdleMirrorId(
                                                connection.mirrorId,
                                                stopCastEvent: true);
                                      } else {
                                        connection
                                            .trackSessionEvent('stop_cast');
                                        HybridConnectionList()
                                            .stopPresenterBy(widget.index);
                                      }
                                      return;
                                    }
                                  }
                                  RTCConnector webrtcConnector =
                                      HybridConnectionList()
                                          .getConnection<RTCConnector>(
                                              widget.index);
                                  if (webrtcConnector.isChannelReconnect()) {
                                    webrtcConnector.clickButtonWhenReconnect =
                                        true;
                                    V3Toast().makeSplitScreenReconnectToast(
                                        context,
                                        S
                                            .of(context)
                                            .main_feature_reconnecting_toast,
                                        widget.index,
                                        isWebRTC: false,
                                        state: webrtcConnector
                                            .reconnectChannelState);
                                  } else {
                                    webrtcConnector
                                        .trackSessionEvent('stop_cast');

                                    if (ChannelProvider.isModeratorMode) {
                                      HybridConnectionList()
                                          .stopPresenterBy(widget.index);
                                    } else {
                                      HybridConnectionList()
                                          .removePresenterBy(widget.index);
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        V3Focus(
                          label: isCollapsed
                              ? S
                                  .of(context)
                                  .v3_lbl_streaming_view_function_expand
                              : S
                                  .of(context)
                                  .v3_lbl_streaming_view_function_minimize,
                          identifier: isCollapsed
                              ? 'v3_qa_streaming_view_function_expend'
                              : 'v3_qa_streaming_view_function_minimize',
                          child: SizedBox(
                            width: 27,
                            height: 27,
                            child: IconButton(
                              icon: SvgPicture.asset(
                                isCollapsed
                                    ? 'assets/images/ic_expend.svg'
                                    : 'assets/images/ic_minimize.svg',
                                semanticsLabel:
                                    isCollapsed ? 'Expand' : 'Minimize',
                              ),
                              focusColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                _toggleCollapse();
                                if (isCollapsed) {
                                  autoCollapseTimer?.cancel();
                                } else {
                                  _startAutoCollapseTimer();
                                }
                              },
                            ),
                          ),
                        ),
                        if (isAirplay &&
                            mirrorStateProvider.bluetoothTouchbackIndex ==
                                widget.index)
                          ValueListenableBuilder(
                            valueListenable:
                                V3BluetoothStatusNotification.showStatusAlert,
                            builder: (context, value, child) {
                              final showToast =
                                  mirrorStateProvider.bluetoothTouchbackIndex ==
                                      widget.index;
                              final status = value.status;
                              if (showToast) {
                                if (status ==
                                    BluetoothTouchbackStatus.initialized) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    // setState用來更新按鈕狀態
                                    var connection = HybridConnectionList()
                                        .getConnection<MirrorRequest>(
                                            widget.index);
                                    if (!mounted) return;
                                    setState(() {
                                      V3BluetoothStatusNotification
                                              .showStatusAlert.value =
                                          BluetoothProgress(percent: 0.0);
                                      V3Toast().makeBluetoothStateToast(
                                        context,
                                        sprintf(
                                            S
                                                .of(context)
                                                .v3_touchback_success_message,
                                            [connection.deviceName]),
                                        widget.index,
                                        color: context
                                            .tokens.color.vsdslColorSuccess,
                                        icon:
                                            'assets/images/ic_bluetooth_check.svg',
                                        hasNameLabel: hasNameLabel,
                                      );
                                    });
                                  });
                                } else if (status ==
                                        BluetoothTouchbackStatus
                                            .adapterEnabledFailed ||
                                    status ==
                                        BluetoothTouchbackStatus
                                            .devicePairedFailed ||
                                    status ==
                                        BluetoothTouchbackStatus
                                            .hidDisconnected ||
                                    status ==
                                        BluetoothTouchbackStatus
                                            .deviceFoundFailed) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) async {
                                    V3Toast().makeBluetoothStateToast(
                                      context,
                                      S.of(context).v3_touchback_fail_message,
                                      widget.index,
                                      color:
                                          context.tokens.color.vsdslColorError,
                                      icon:
                                          'assets/images/ic_bluetooth_fail.svg',
                                      hasNameLabel: hasNameLabel,
                                    );
                                    await Future.delayed(
                                        const Duration(seconds: 1));
                                    await _disableAllTouchback();
                                  });
                                }
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        // Right drag button (only in expanded mode)
                        if (!isCollapsed) _buildDragButton(availableWidth),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> ensureBluetoothOn(BuildContext context) async {
    final current = await FlutterBluePlus.adapterState.first;
    if (current == BluetoothAdapterState.on) return true;

    // ANDROID：可直接呼叫系統對話框開啟藍牙
    if (!kIsWeb && Platform.isAndroid) {
      await FlutterBluePlus.turnOn(); // 觸發系統啟用藍牙對話框（ACTION_REQUEST_ENABLE）
      try {
        // 等待狀態變為 on（最多 8 秒）
        await FlutterBluePlus.adapterState
            .where((s) => s == BluetoothAdapterState.on)
            .first
            .timeout(const Duration(seconds: 10));
        return true;
      } catch (_) {
        // 若使用者拒絕或逾時，退而求其次導到設定頁
        // await AppSettings.openBluetoothSettings();
        return false;
      }
    }
    return false;
  }

  Future<void> onTouchBackPressed(MirrorStateProvider mirrorStateProvider,
      bool isMirrorRequest, BuildContext context) async {
    EasyThrottle.throttle(
      'onTouchBackPressed',
      const Duration(seconds: 5),
      () async {
        final ok = await ensureBluetoothOn(context);
        if (!ok) {
          return;
        }

        mirrorStateProvider.bluetoothTouchbackIndex = widget.index;
        final hasNameLabel = _hasNameLabel();

        if (isMirrorRequest) {
          var connection =
              HybridConnectionList().getConnection<MirrorRequest>(widget.index);
          if (connection.mirrorState == MirrorState.mirroring) {
            if (connection.touchBackState()) {
              await _disableAllTouchback();
              if (context.mounted) {
                if (!mounted) return;

                setState(() {
                  V3Toast().makeBluetoothStateToast(context,
                      S.current.v3_touchback_disable_message, widget.index,
                      hasNameLabel: hasNameLabel);
                });
              }
            } else {
              if (context.mounted) {
                await showDialog(
                  context: context,
                  barrierColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return FocusAwareBuilder(
                      builder: (primaryFocusNode) => V3TouchbackHintAlert(
                        primaryFocusNode: primaryFocusNode,
                        deviceName: HybridConnectionList()
                            .getConnection<MirrorRequest>(widget.index)
                            .deviceName,
                        onConfirm: () async {},
                      ),
                    );
                  },
                );
              }

              final success = await connection.enableTouchback();
              // 更新尺寸
              mirrorStateProvider.onWidgetSizeChanged();
              log.info('enable bluetooth touchback $success');
              // 更新按鈕狀態
              if (!mounted) return;
              setState(() {
                if (!success) {
                  _showTouchbackAlertDialog(context, mirrorStateProvider);
                }
              });
            }
          }
        }
      },
    );
  }

  bool _hasNameLabel() {
    final connection = HybridConnectionList().getConnection(widget.index);
    if (connection is RTCConnector) {
      return connection.presentationState == PresentationState.streaming &&
          (connection.senderName ?? '').isNotEmpty;
    }
    return false;
  }

  // 不支援HID
  bool _isUnsupportedIFPModel(String deviceModel) {
    final unsupportedModels = [
      // Windows Receiver
      'Windows',
      // Android Receiver
      'IFP105',
      'IFP52_K', //IFP52-1A/B
      'IFP50_3',
    ];
    // 轉成大寫後比較以防大小寫錯誤
    final normalizedModel = deviceModel.toUpperCase();
    return unsupportedModels.any((model) => normalizedModel.contains(model));
  }

  void _startAutoCollapseTimer() {
    autoCollapseTimer?.cancel();
    autoCollapseTimer = Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      setState(() {
        isCollapsed = true;
      });
    });
  }

  void _toggleCollapse() {
    if (!mounted) return;
    setState(() {
      isCollapsed = !isCollapsed;
    });
  }

  _updateSizeForSelected(int selection) {
    if (selection == HybridConnectionList().enlargedScreenIndex.value) {
      HybridConnectionList().enlargedScreenIndex.value = null;
    } else {
      HybridConnectionList().enlargedScreenIndex.value = selection;
    }
    if (HybridConnectionList.hybridSplitScreenCount.value > 1) {
      HybridConnectionList().setSpecifiedSplitScreenWindowQuality(selection,
          HybridConnectionList().enlargedScreenIndex.value == selection);
    }
  }

  _showTouchbackAlertDialog(
      BuildContext context, MirrorStateProvider mirrorStateProvider) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return FocusAwareBuilder(
          builder: (primaryFocusNode) => V3TouchbackAlert(
            primaryFocusNode: primaryFocusNode,
            deviceName: HybridConnectionList()
                .getConnection<MirrorRequest>(widget.index)
                .deviceName,
            onConfirm: () async {
              await _disableAllTouchback();
              mirrorStateProvider.bluetoothTouchbackIndex = widget.index;
              var connection = HybridConnectionList()
                  .getConnection<MirrorRequest>(widget.index);
              if (connection.mirrorState == MirrorState.mirroring) {
                if (!mounted) return;
                setState(() async {
                  final success = await connection.enableTouchback();
                  log.info('change touchback device $success');
                });
              }
            },
          ),
        );
      },
    );
  }

  Future<void> _disableAllTouchback() async {
    V3BluetoothStatusNotification.showStatusAlert.value =
        BluetoothProgress(percent: 0.0);
    for (MirrorRequest request
        in HybridConnectionList().getMirrorMap().values) {
      if (request.mirrorType == MirrorType.airplay) {
        final success = await request.disableTouchback();
        log.info('disable bluetooth touchback $success');
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  Widget _buildDragButton(double availableWidth) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (!mounted) return;
        setState(() {
          _currentX = (_currentX! + details.delta.dx).clamp(
              0.0, (availableWidth - _widgetWidth).clamp(0, double.infinity));
        });
      },
      child: Container(
        width: 27,
        height: 27,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          'assets/images/ic_drag.svg',
          width: 16,
          height: 16,
        ),
      ),
    );
  }
}

class _TouchBackButton extends StatefulWidget {
  const _TouchBackButton(this.index, this.onPressed);

  final int index;
  final VoidCallback onPressed;

  @override
  State<_TouchBackButton> createState() => _TouchBackButtonState();
}

class _TouchBackButtonState extends State<_TouchBackButton> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: V3BluetoothStatusNotification.showStatusAlert,
      builder: (context, value, child) {
        return value.show
            ? Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: context.tokens.color.vsdslColorSurface1000,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.tokens.color.vsdslColorOutline,
                    width: 1,
                  ),
                ),
                child: CircularProgressIndicator(
                  color: context.tokens.color.vsdslColorOnSurfaceInverse,
                  strokeWidth: 2,
                ),
              )
            : IconButton(
                icon: SvgPicture.asset(
                  (HybridConnectionList()
                          .getConnection<MirrorRequest>(widget.index)
                          .touchBackState())
                      ? 'assets/images/ic_streaming_airplay_touchback_enable.svg'
                      : 'assets/images/ic_streaming_airplay_touchback_disable.svg',
                ),
                focusColor: Colors.transparent,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: widget.onPressed,
              );
      },
    );
  }
}
