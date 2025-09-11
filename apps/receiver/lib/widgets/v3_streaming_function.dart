import 'dart:async';

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
import 'package:display_flutter/widgets/split_screen_function.dart';
import 'package:display_flutter/widgets/v3_bluetooth_touchback_status_notification.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_touchback_one_device_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mirror/bluetooth_touchback_status.dart';
import 'package:flutter_mirror/mirror_type.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

import 'focus_aware_builder.dart';

class V3StreamingFunction extends StatefulWidget {
  const V3StreamingFunction({super.key, required this.index});

  final int index;

  @override
  State<StatefulWidget> createState() => _V3StreamingFunctionState();
}

class _V3StreamingFunctionState extends State<V3StreamingFunction> {
  bool isCollapsed = false;
  bool? _ifpSupportsBluetoothHID;
  Timer? autoCollapseTimer;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_ifpSupportsBluetoothHID == null) {
        final String? deviceModel = await DeviceInfoVs.deviceType;
        if (deviceModel != null) {
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

    final mirrorStateProvider =
        Provider.of<MirrorStateProvider>(context, listen: false);
    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding:
            isCollapsed ? EdgeInsets.zero : const EdgeInsets.only(bottom: 8),
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            width: isCollapsed
                ? 37
                : ((context.splitScreenRatio == SplitScreenRatio.oneThirdFull ||
                                HybridConnectionList
                                        .hybridSplitScreenCount.value >
                                    1) &&
                            (context.splitScreenRatio.widthFraction >
                                SplitScreenRatio.floatingDefault.widthFraction)
                        ? 140
                        : 106) +
                    (isAirplay ? 45 : 0), // 增加按鈕的空間
            height: isCollapsed ? 22 : 43,
          ),
          child: Container(
            padding: isCollapsed ? const EdgeInsets.only(top: 4) : null,
            decoration: BoxDecoration(
              color: context.tokens.color.vsdslColorOpacityNeutralXl
                  .withOpacity(0.48),
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
                if (isHIDSupported)
                  Visibility(
                    visible: !isCollapsed,
                    child: V3Focus(
                      label: S.of(context).v3_lbl_streaming_airplay_touchback,
                      identifier: 'v3_qa_streaming_airplay_touchback',
                      child: SizedBox(
                        width: 27,
                        height: 27,
                        child: IconButton(
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
                          onPressed: () async {
                            mirrorStateProvider.bluetoothTouchbackIndex =
                                widget.index;
                            if (isMirrorRequest) {
                              var connection = HybridConnectionList()
                                  .getConnection<MirrorRequest>(widget.index);
                              if (connection.mirrorState ==
                                  MirrorState.mirroring) {
                                if (connection.touchBackState()) {
                                  await _disableAllTouchback();
                                  if (context.mounted) {
                                    setState(() {
                                      V3Toast().makeBluetoothStateToast(
                                          context,
                                          S.current
                                              .v3_touchback_disable_message,
                                          widget.index,
                                          _layerLink);
                                    });
                                  }
                                } else {
                                  final success =
                                      await connection.enableTouchback();
                                  // 更新尺寸
                                  mirrorStateProvider.onWidgetSizeChanged();
                                  log.info(
                                      'enable bluetooth touchback $success');
                                  // 更新按鈕狀態
                                  setState(() {
                                    if (!success) {
                                      _showTouchbackAlertDialog(
                                          context, mirrorStateProvider);
                                    }
                                  });
                                }
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                // Use Visibility Widget to Maintain Focus on the Correct Icon During Collapse/Expand.
                Visibility(
                  visible: !isCollapsed &&
                      (context.splitScreenRatio ==
                              SplitScreenRatio.oneThirdFull ||
                          HybridConnectionList.hybridSplitScreenCount.value >
                              1) &&
                      (context.splitScreenRatio.widthFraction >
                          SplitScreenRatio.floatingDefault.widthFraction),
                  child: V3Focus(
                    label: HybridConnectionList().enlargedScreenIndex.value ==
                            widget.index
                        ? S.of(context).v3_lbl_streaming_view_minimize
                        : S.of(context).v3_lbl_streaming_view_expand,
                    identifier:
                        HybridConnectionList().enlargedScreenIndex.value ==
                                widget.index
                            ? 'v3_qa_streaming_view_minimize'
                            : 'v3_qa_streaming_view_expand',
                    child: SizedBox(
                      width: 27,
                      height: 27,
                      child: IconButton(
                        icon: SvgPicture.asset(
                          HybridConnectionList().enlargedScreenIndex.value ==
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
                            var mirrorConnection = HybridConnectionList()
                                .getConnection<MirrorRequest>(widget.index);
                            if (mirrorConnection.mirrorState ==
                                MirrorState.mirroring) {
                              _updateSizeForSelected(widget.index);
                              mirrorConnection
                                  .trackSessionEvent('click_screen_size');
                              return;
                            }
                          }
                          var webrtcConnector = HybridConnectionList()
                              .getConnection<RTCConnector>(widget.index);
                          if (webrtcConnector.isChannelConnectAvailable()) {
                            webrtcConnector
                                .trackSessionEvent('click_screen_size');

                            _updateSizeForSelected(widget.index);
                          } else if (webrtcConnector.isChannelReconnect()) {
                            webrtcConnector.clickButtonWhenReconnect = true;
                            V3Toast().makeSplitScreenReconnectToast(
                                context,
                                S.of(context).main_feature_reconnecting_toast,
                                widget.index,
                                isWebRTC: false,
                                state: webrtcConnector.reconnectChannelState);
                          } else {
                            V3Toast().makeSplitScreenReconnectToast(
                                context,
                                S.of(context).main_feature_reconnect_fail_toast,
                                widget.index,
                                isWebRTC: false,
                                state: webrtcConnector.reconnectChannelState);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: !isCollapsed,
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
                                .getConnection<MirrorRequest>(widget.index);
                            if (connection.mirrorState ==
                                MirrorState.mirroring) {
                              if (ChannelProvider.isModeratorMode) {
                                mirrorStateProvider.setModeratorIdleMirrorId(
                                    connection.mirrorId,
                                    stopCastEvent: true);
                              } else {
                                connection.trackSessionEvent('stop_cast');
                                HybridConnectionList()
                                    .stopPresenterBy(widget.index);
                              }
                              return;
                            }
                          }
                          RTCConnector webrtcConnector = HybridConnectionList()
                              .getConnection<RTCConnector>(widget.index);
                          if (webrtcConnector.isChannelReconnect()) {
                            webrtcConnector.clickButtonWhenReconnect = true;
                            V3Toast().makeSplitScreenReconnectToast(
                                context,
                                S.of(context).main_feature_reconnecting_toast,
                                widget.index,
                                isWebRTC: false,
                                state: webrtcConnector.reconnectChannelState);
                          } else {
                            webrtcConnector.trackSessionEvent('stop_cast');

                            if (ChannelProvider.isModeratorMode) {
                              HybridConnectionList()
                                  .stopPresenterBy(widget.index);
                            } else {
                              SplitScreenFunction.isMenuOnList.value.fillRange(
                                  0,
                                  SplitScreenFunction.isMenuOnList.value.length,
                                  false);
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
                      ? S.of(context).v3_lbl_streaming_view_function_expand
                      : S.of(context).v3_lbl_streaming_view_function_minimize,
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
                        semanticsLabel: isCollapsed ? 'Expand' : 'Minimize',
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
                    mirrorStateProvider.bluetoothTouchbackIndex == widget.index)
                  ValueListenableBuilder(
                    valueListenable:
                        V3BluetoothStatusNotification.showStatusAlert,
                    builder: (context, value, child) {
                      final showToast =
                          mirrorStateProvider.bluetoothTouchbackIndex ==
                              widget.index;
                      final status = value.status;
                      if (showToast) {
                        if (status == BluetoothTouchbackStatus.initialized) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            // setState用來更新按鈕狀態
                            var connection = HybridConnectionList()
                                .getConnection<MirrorRequest>(widget.index);
                            setState(() {
                              V3BluetoothStatusNotification.showStatusAlert
                                  .value = BluetoothProgress(percent: 0.0);
                              V3Toast().makeBluetoothStateToast(
                                context,
                                sprintf(
                                    S.of(context).v3_touchback_success_message,
                                    [connection.deviceName]),
                                widget.index,
                                _layerLink,
                                color: context.tokens.color.vsdslColorSuccess,
                                icon: 'assets/images/ic_bluetooth_check.svg',
                              );
                            });
                          });
                        } else if (status ==
                                BluetoothTouchbackStatus.adapterEnabledFailed ||
                            status ==
                                BluetoothTouchbackStatus.devicePairedFailed ||
                            status ==
                                BluetoothTouchbackStatus.hidDisconnected ||
                            status ==
                                BluetoothTouchbackStatus.deviceFoundFailed) {
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) async {
                            V3Toast().makeBluetoothStateToast(
                              context,
                              S.of(context).v3_touchback_fail_message,
                              widget.index,
                              _layerLink,
                              color: context.tokens.color.vsdslColorError,
                              icon: 'assets/images/ic_bluetooth_fail.svg',
                            );
                            await Future.delayed(const Duration(seconds: 1));
                            await _disableAllTouchback();
                          });
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
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
      setState(() {
        isCollapsed = true;
      });
    });
  }

  void _toggleCollapse() {
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
}
