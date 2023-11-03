import 'dart:math' as math;

import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatusBar extends StatefulWidget {
  const StatusBar({super.key});
  static ValueNotifier<bool> showReamingTime = ValueNotifier(false);
  static ValueNotifier<bool> showReamingTimeAlert = ValueNotifier(false);
  static ValueNotifier<bool> showNetworkStatus = ValueNotifier(false);

  @override
  State createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: AnimatedBuilder(
            animation: Listenable.merge(
                [StatusBar.showReamingTime, StatusBar.showNetworkStatus]),
            builder: (BuildContext context, Widget? child) {
              return Visibility(
                visible: StatusBar.showReamingTime.value ||
                    StatusBar.showNetworkStatus.value,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(10)),
                    color: AppColors.primary_grey_tran,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                          visible: StatusBar.showNetworkStatus.value,
                          child: const Icon(Icons.network_check,
                              color: AppColors.timeout_red)),
                      Visibility(
                        visible: StatusBar.showNetworkStatus.value &&
                            StatusBar.showReamingTime.value,
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Transform.rotate(
                              angle: 90 * math.pi / 180,
                              child: const Icon(Icons.horizontal_rule,
                                  color: AppColors.primary_white)),
                        ),
                      ),
                      StreamBuilder(
                        stream: ConnectionTimer.getInstance()
                            .mRemainingTimeTimeout
                            .stream,
                        builder: (BuildContext context,
                            AsyncSnapshot<int> snapData) {
                          String min = '00', sec = '00';
                          NumberFormat formatter = NumberFormat('00');
                          if (snapData.hasData) {
                            min =
                                formatter.format((snapData.data! / 60).floor());
                            sec = formatter.format(snapData.data! % 60);
                          }
                          String time =
                              S.of(context).main_status_remaining_time;
                          time = time
                              .replaceFirst('%02d', min)
                              .replaceFirst('%02d', sec);
                          return Visibility(
                            visible: StatusBar.showReamingTime.value,
                            child: Text(time,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.timeout_red)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Center(
            child: ValueListenableBuilder(
          valueListenable: StatusBar.showReamingTimeAlert,
          builder: (BuildContext context, bool value, Widget? child) {
            return Visibility(
                visible: value,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.33,
                  height: MediaQuery.of(context).size.height * 0.5,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    color: ControlSocket().isPresenting()
                        ? AppColors.primary_grey_tran
                        : AppColors.primary_grey,
                  ),
                  child: Text(
                    S.of(context).main_limit_time_message,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.white),
                  ),
                ));
          },
        )),
      ],
    );
  }
}
