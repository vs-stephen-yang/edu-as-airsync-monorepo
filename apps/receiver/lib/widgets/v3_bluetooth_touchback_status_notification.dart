import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mirror/bluetooth_touchback_status.dart';

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
        if (value.show) {
          return StatusCard(
            statusMessage: value.statusMessage ?? "",
            progressPercent: value.percent,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
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
  get statusMessage {
    String message = '';
    switch (status) {
      case BluetoothTouchbackStatus.initializing:
        message = S.current.v3_touchback_state_initializing_message;
        break;
      case BluetoothTouchbackStatus.hidProfileServiceStarting:
        message =
            S.current.v3_touchback_state_hidProfileServiceStarting_message;
        break;
      case BluetoothTouchbackStatus.hidProfileServiceStartedSuccess:
        message = S
            .current.v3_touchback_state_hidProfileServiceStartedSuccess_message;
        break;
      case BluetoothTouchbackStatus.deviceFinding:
        message = S.current.v3_touchback_state_deviceFinding_message;
        break;
      case BluetoothTouchbackStatus.deviceFoundSuccess:
        message = S.current.v3_touchback_state_deviceFoundSuccess_message;
        break;
      case BluetoothTouchbackStatus.devicePairing:
        message = S.current.v3_touchback_state_devicePairing_message;
        break;
      case BluetoothTouchbackStatus.devicePairedSuccess:
        message = S.current.v3_touchback_state_devicePairedSuccess_message;
        break;
      case BluetoothTouchbackStatus.hidConnecting:
        message = S.current.v3_touchback_state_hidConnecting_message;
        break;
      case BluetoothTouchbackStatus.hidConnected:
        message = S.current.v3_touchback_state_hidConnected_message;
        break;
      case BluetoothTouchbackStatus.initialized:
        message = S.current.v3_touchback_state_initialized_message;
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
