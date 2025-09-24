import 'dart:async';

import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/providers/pref_language_provider.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
    return Consumer<PrefLanguageProvider>(
      builder: (_, prefLanguageProvider, __) {
        var now = DateTime.now();
        final time =
            DateFormat('hh:mm a', prefLanguageProvider.locale?.languageCode)
                .format(now);
        return V3AutoHyphenatingText(
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
    if (!mounted) return;
    setState(() {
      _now = DateTime.now();
      _timer = Timer(
        const Duration(seconds: 60) - Duration(seconds: _now.second),
        _updateTime,
      );
    });
  }
}
