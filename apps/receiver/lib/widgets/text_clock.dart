import 'dart:async';

import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/main_common.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TextClock extends StatefulWidget {
  const TextClock({super.key});

  @override
  State createState() => _TextClockState();
}

class _TextClockState extends State<TextClock> {
  var _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Set the initial values.
    _updateTime();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: MyApp.updatedLocale,
      builder: (BuildContext context, bool value, Widget? child) {
        var now = DateTime.now();
        final time =
            DateFormat('hh:mm a', AppPreferences().locale?.languageCode)
                .format(now);
        return Text(
          time,
          style: const TextStyle(
            color: AppColors.primaryWhiteA50,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }

  _updateTime() {
    setState(() {
      _now = DateTime.now();
      _timer = Timer(
        const Duration(seconds: 60) - Duration(seconds: _now.second),
        _updateTime,
      );
    });
  }
}
