import 'dart:async';

import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/demo_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:display_cast_flutter/widgets/touch_back_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PresentPresentStartDemo extends StatelessWidget {
  PresentPresentStartDemo({super.key, this.countStartTime = 0});

  final ValueNotifier<int> _countSecondsValue = ValueNotifier(0);
  final ValueNotifier<int> _countMinutesValue = ValueNotifier(0);
  final ValueNotifier<int> _countHoursValue = ValueNotifier(0);

  final ValueNotifier<bool> _presentingState = ValueNotifier(true);
  final GlobalKey<TouchBackButtonState> touchBtnKey = GlobalKey();
  final int countStartTime;

  @override
  Widget build(BuildContext context) {
    DemoProvider demoProvider = Provider.of<DemoProvider>(context);
    if (kIsWeb && countStartTime != 0) {
      final start = (DateTime.now().millisecondsSinceEpoch - countStartTime) ~/ 1000;
      _countSecondsValue.value = start % 60;
      _countMinutesValue.value = (start % 3600) ~/ 60;
      _countHoursValue.value = start ~/ 3600;
    } else {
      _countSecondsValue.value = 0;
      _countMinutesValue.value = 0;
      _countHoursValue.value = 0;
    }
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_presentingState.value) {
        _countSecondsValue.value++;
      }
      if (_countSecondsValue.value == 60) {
        _countSecondsValue.value = 0;
        _countMinutesValue.value++;
      }
      if (_countMinutesValue.value == 60) {
        _countMinutesValue.value = 0;
        _countHoursValue.value++;
      }
      if (!context.mounted) {
        timer.cancel();
      }
    });

    var textStyle20 = const TextStyle(color: Colors.white, fontSize: 20);
    var textStyle30 = const TextStyle(color: Colors.white, fontSize: 28);
    return Column(
      children: [
        const Expanded(flex:2, child: SizedBox()),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: Text(
            S.of(context).present_time,
            style: textStyle30,
          ),
        ),
        SizedBox(
          width: AppConstants.viewStateMenuWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ValueListenableBuilder(
                  valueListenable: _countHoursValue,
                  builder: (BuildContext context, int value, Widget? child) {
                    return Text(
                      value.toString().padLeft(2, '0'),
                      style: textStyle30,
                    );
                  }),
              Text(S.of(context).present_time_unit_hour, style: textStyle20),
              Text(':', style: textStyle30),
              ValueListenableBuilder(
                  valueListenable: _countMinutesValue,
                  builder: (BuildContext context, int value, Widget? child) {
                    return Text(
                      value.toString().padLeft(2, '0'),
                      style: textStyle30,
                    );
                  }),
              Text(S.of(context).present_time_unit_min, style: textStyle20),
              Text(':', style: textStyle30),
              ValueListenableBuilder(
                  valueListenable: _countSecondsValue,
                  builder: (BuildContext context, int value, Widget? child) {
                    return Text(
                      value.toString().padLeft(2, '0'),
                      style: textStyle30,
                    );
                  }),
              Text(S.of(context).present_time_unit_sec, style: textStyle20),
            ],
          ),
        ),
        Expanded(flex:3, child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 38.0),
                child: ValueListenableBuilder(
                  valueListenable: _presentingState,
                  builder: (BuildContext context, value, Widget? child) {
                    return InkWell(
                      onTap: () {
                        _presentingState.value = !_presentingState.value;
                        if (_presentingState.value) {
                          AppAnalytics.instance.trackEvent('resume_clicked_demo');
                        } else {
                          AppAnalytics.instance.trackEvent('pause_clicked_demo');
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            value
                                ? Icons.pause_presentation
                                : Icons.smart_display_outlined,
                            color: Colors.white,
                          ),
                          const Padding(padding: EdgeInsets.only(left: 8)),
                          Text(
                              value
                                  ? S.of(context).present_state_pause
                                  : S.of(context).present_state_resume,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 38.0, top: 20.0),
                child: InkWell(
                  onTap: () {
                    AppAnalytics.instance.trackEvent('stop_present_clicked_demo');
                    demoProvider.isDemoMode = false;
                    demoProvider.setViewState(DemoViewState.off);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cancel_presentation,
                        color: Colors.white,
                      ),
                      const Padding(padding: EdgeInsets.only(left: 8)),
                      Text(S.of(context).present_state_stop,
                          style:
                          const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )),
      ],
    );
  }
}
