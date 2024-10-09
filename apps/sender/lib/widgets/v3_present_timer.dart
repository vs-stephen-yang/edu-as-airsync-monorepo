import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:flutter/material.dart';

class V3PresentTimer extends StatelessWidget {
  const V3PresentTimer({super.key});

  @override
  Widget build(BuildContext context) {
    var textStyle32 = TextStyle(
      color: context.tokens.color.vsdswColorOnSurfaceInverse,
      fontSize: 32,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder(
          valueListenable: countHoursValue,
          builder: (BuildContext context, int value, Widget? child) {
            return Text(
              value.toString().padLeft(2, '0'),
              style: textStyle32,
            );
          },
        ),
        Text(':', style: textStyle32),
        ValueListenableBuilder(
          valueListenable: countMinutesValue,
          builder: (BuildContext context, int value, Widget? child) {
            return Text(
              value.toString().padLeft(2, '0'),
              style: textStyle32,
            );
          },
        ),
        Text(':', style: textStyle32),
        ValueListenableBuilder(
          valueListenable: countSecondsValue,
          builder: (BuildContext context, int value, Widget? child) {
            return Text(
              value.toString().padLeft(2, '0'),
              style: textStyle32,
            );
          },
        ),
      ],
    );
  }
}
