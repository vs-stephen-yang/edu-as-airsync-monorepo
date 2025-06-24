import 'dart:async';

import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/providers/pref_language_provider.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class V3TextClock extends StatefulWidget {
  const V3TextClock({super.key});

  @override
  State<StatefulWidget> createState() => _V3TextClockState();
}

class _V3TextClockState extends State<V3TextClock> {
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
        return V3AutoHyphenatingText(
          DateFormat('hh:mma', prefLanguageProvider.locale?.languageCode)
              .format(DateTime.now()),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: context.tokens.color.vsdslColorOnSurface,
            letterSpacing: -0.48,
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
