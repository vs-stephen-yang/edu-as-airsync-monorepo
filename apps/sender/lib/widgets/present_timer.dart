import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:flutter/material.dart';

class PresentTimer extends StatelessWidget {
  const PresentTimer({super.key});

  @override
  Widget build(BuildContext context) {
    var textStyle20 = const TextStyle(color: Colors.white, fontSize: 20);
    var textStyle30 = const TextStyle(color: Colors.white, fontSize: 28);
    return SizedBox(
      width: AppConstants.viewStateMenuWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ValueListenableBuilder(
            valueListenable: countHoursValue,
            builder: (BuildContext context, int value, Widget? child) {
              return Text(
                value.toString().padLeft(2, '0'),
                style: textStyle30,
              );
            },
          ),
          Text(S.of(context).present_time_unit_hour, style: textStyle20),
          Text(':', style: textStyle30),
          ValueListenableBuilder(
            valueListenable: countMinutesValue,
            builder: (BuildContext context, int value, Widget? child) {
              return Text(
                value.toString().padLeft(2, '0'),
                style: textStyle30,
              );
            },
          ),
          Text(S.of(context).present_time_unit_min, style: textStyle20),
          Text(':', style: textStyle30),
          ValueListenableBuilder(
            valueListenable: countSecondsValue,
            builder: (BuildContext context, int value, Widget? child) {
              return Text(
                value.toString().padLeft(2, '0'),
                style: textStyle30,
              );
            },
          ),
          Text(S.of(context).present_time_unit_sec, style: textStyle20),
        ],
      ),
    );
  }
}
