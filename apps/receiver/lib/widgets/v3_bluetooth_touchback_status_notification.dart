import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mirror/bluetooth_touchback_status.dart';
import 'package:flutter_mirror/mirror_type.dart';
import 'package:gap/gap.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

import 'focus_aware_builder.dart';

class V3BluetoothStatusNotification extends StatefulWidget {
  const V3BluetoothStatusNotification({super.key});

  static ValueNotifier<BluetoothProgress> showStatusAlert =
      ValueNotifier(BluetoothProgress(percent: 0.0));

  @override
  State createState() => _V3BluetoothStatusNotificationState();
}

class _V3BluetoothStatusNotificationState
    extends State<V3BluetoothStatusNotification> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: V3BluetoothStatusNotification.showStatusAlert,
      builder: (context, value, child) {
        if (value.status ==
            BluetoothTouchbackStatus.hidProfileServiceStartedFailed) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await _disableAllTouchback();
            await showDialog(
              context: context,
              barrierColor: Colors.transparent,
              builder: (BuildContext context) {
                return FocusAwareBuilder(builder: (primaryFocusNode) {
                  return RestartBluetoothWidget(
                    primaryFocusNode,
                    onConfirm: () {
                      openBluetoothSettings();
                    },
                  );
                });
              },
            );
          });
        } else if (value.show) {
          return StatusCard(
            statusMessage: value.getStatusMessage(context),
            progressPercent: value.percent,
          );
        }
        return const SizedBox.shrink();
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

  void openBluetoothSettings() async {
    final platform = MethodChannel('com.mvbcast.crosswalk/settings');
    try {
      await platform.invokeMethod('openBluetoothSettings');
    } on PlatformException catch (e) {
      print("無法開啟藍牙設定頁: ${e.message}");
    }
  }
}

class RestartBluetoothWidget extends StatelessWidget {
  final FocusNode primaryFocusNode;
  final VoidCallback? onConfirm;

  const RestartBluetoothWidget(
    this.primaryFocusNode, {
    super.key,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Stack(
      alignment: Alignment.center,
      children: [
        UnconstrainedBox(
          constrainedAxis: Axis.vertical,
          child: SizedBox(
            width: 266,
            height: 193,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: context.tokens.radii.vsdslRadiusXl,
              ),
              insetPadding: EdgeInsets.zero,
              backgroundColor: context.tokens.color.vsdslColorOnSurfaceInverse,
              elevation: 16.0,
              shadowColor: context.tokens.color.vsdslColorOpacityNeutralSm,
              child: Container(
                padding: const EdgeInsets.all(17),
                child: Column(
                  children: [
                    Expanded(
                      child: V3Scrollbar(
                        controller: scrollController,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  S.current
                                      .v3_touchback_restart_bluetooth_title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        context.tokens.color.vsdslColorNeutral,
                                  ),
                                ),
                              ),
                              const Gap(13),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 13),
                                child: Text(
                                  S.current
                                      .v3_touchback_restart_bluetooth_message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color:
                                        context.tokens.color.vsdslColorNeutral,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Gap(13),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: V3Focus(
                              label: S
                                  .of(context)
                                  .v3_lbl_touchback_restart_bluetooth_btn_cancel,
                              identifier:
                                  'v3_qa_touchback_restart_bluetooth_btn_cancel',
                              child: ElevatedButton(
                                focusNode: primaryFocusNode,
                                style: ElevatedButton.styleFrom(
                                  side: BorderSide(
                                    width: 1.0,
                                    color: context
                                        .tokens.color.vsdslColorSecondary,
                                  ),
                                  elevation: 5.0,
                                  backgroundColor: Colors.white,
                                  // remove onFocused color, this is also ripple color
                                  overlayColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  if (navService.canPop()) {
                                    navService.goBack();
                                  }
                                },
                                child: Text(
                                  S.current
                                      .v3_touchback_restart_bluetooth_btn_cancel,
                                  style: TextStyle(
                                    color: context
                                        .tokens.color.vsdslColorSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Gap(8),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: V3Focus(
                              label: S
                                  .of(context)
                                  .v3_lbl_touchback_restart_bluetooth_btn_restart,
                              identifier:
                                  'v3_qa_touchback_restart_bluetooth_btn_restart',
                              child: ElevatedButton(
                                focusNode: primaryFocusNode,
                                style: ElevatedButton.styleFrom(
                                  elevation: 5.0,
                                  shadowColor:
                                      context.tokens.color.vsdslColorPrimary,
                                  foregroundColor: context
                                      .tokens.color.vsdslColorOnSurfaceInverse,
                                  backgroundColor:
                                      context.tokens.color.vsdslColorPrimary,
                                  // remove onFocused color, this is also ripple color
                                  overlayColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  onConfirm?.call();
                                  if (navService.canPop()) {
                                    navService.goBack();
                                  }
                                },
                                child: Text(
                                  S.current
                                      .v3_touchback_restart_bluetooth_btn_restart,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StatusCard extends StatelessWidget {
  final String statusMessage;
  final double progressPercent; // 範圍 0.0 ~ 1.0

  const StatusCard({
    super.key,
    required this.statusMessage,
    required this.progressPercent,
  });

  @override
  Widget build(BuildContext context) {
    return _buildDialog(
      context: context,
      width: 242,
      height: 49,
      backgroundColor: context.tokens.color.vsdslColorSurface1000,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          _MessageText(message: statusMessage),
        ],
      ),
      progressPercent: progressPercent,
    );
  }

  Widget _buildDialog(
      {required BuildContext context,
      required double width,
      required double height,
      required Color backgroundColor,
      required double progressPercent,
      required Widget child}) {
    return UnconstrainedBox(
      constrainedAxis: Axis.vertical,
      child: SizedBox(
        width: width,
        height: height,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: context.tokens.radii.vsdslRadiusLg,
            side: BorderSide(
              color: context.tokens.color.vsdslColorOutlineVariant,
              width: 0.6,
            ),
          ),
          insetPadding: EdgeInsets.zero,
          backgroundColor: backgroundColor,
          child: ClipRRect(
            borderRadius: context.tokens.radii.vsdslRadiusLg,
            child: Stack(
              children: [
                Positioned.fill(child: child),
                Positioned(
                  left: 2.5,
                  right: 2.5,
                  bottom: 0,
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    minHeight: 5,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.tokens.color.vsdslColorSuccess,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageText extends StatelessWidget {
  final String message;

  const _MessageText({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: AutoSizeText.rich(
        TextSpan(
          text: message,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.normal,
            color: context.tokens.color.vsdslColorOnSurfaceInverse,
          ),
        ),
        textAlign: TextAlign.center,
        minFontSize: 8,
      ),
    );
  }
}

class BluetoothProgress {
  final BluetoothTouchbackStatus? status;
  final double percent;

  BluetoothProgress({this.status, required this.percent}); // 範圍 0.0 ~ 1.0
  String getStatusMessage(BuildContext context) {
    String message = '';
    switch (status) {
      case BluetoothTouchbackStatus.initializing:
        message = S.of(context).v3_touchback_state_initializing_message;
        break;
      case BluetoothTouchbackStatus.hidProfileServiceStarting:
        message =
            S.of(context).v3_touchback_state_hidProfileServiceStarting_message;
        break;
      case BluetoothTouchbackStatus.hidProfileServiceStartedSuccess:
        message = S
            .current.v3_touchback_state_hidProfileServiceStartedSuccess_message;
        break;
      case BluetoothTouchbackStatus.deviceFinding:
        message = S.of(context).v3_touchback_state_deviceFinding_message;
        break;
      case BluetoothTouchbackStatus.deviceFoundSuccess:
        message = S.of(context).v3_touchback_state_deviceFoundSuccess_message;
        break;
      case BluetoothTouchbackStatus.devicePairing:
        message = S.of(context).v3_touchback_state_devicePairing_message;
        break;
      case BluetoothTouchbackStatus.devicePairedSuccess:
        message = S.of(context).v3_touchback_state_devicePairedSuccess_message;
        break;
      case BluetoothTouchbackStatus.hidConnecting:
        message = S.of(context).v3_touchback_state_hidConnecting_message;
        break;
      case BluetoothTouchbackStatus.hidConnected:
        message = S.of(context).v3_touchback_state_hidConnected_message;
        break;
      case BluetoothTouchbackStatus.initialized:
        message = S.of(context).v3_touchback_state_initialized_message;
        break;
      case BluetoothTouchbackStatus.closedByUser:
      case BluetoothTouchbackStatus.adapterEnabling:
      case BluetoothTouchbackStatus.adapterEnabledSuccess:
      case BluetoothTouchbackStatus.adapterEnabledFailed:
      case BluetoothTouchbackStatus.adapterUnsupported:
      case BluetoothTouchbackStatus.deviceFoundFailed:
      case BluetoothTouchbackStatus.devicePairedFailed:
      case BluetoothTouchbackStatus.deviceUnpaired:
      case BluetoothTouchbackStatus.hidDisconnecting:
      case BluetoothTouchbackStatus.hidDisconnected:
      case BluetoothTouchbackStatus.hidProfileServiceStartedFailed:
      case null:
        message = '';
        break;
    }
    return message;
  }

  get show {
    return percent > 0 && percent != 1.0;
  }
}
