import 'dart:async';

import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/providers/pref_language_provider.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class V3TextClock extends StatefulWidget {
  const V3TextClock({super.key});

  @override
  State<StatefulWidget> createState() => _V3TextClockState();
}

class _V3TextClockState extends State<V3TextClock> {
  static const _evt = EventChannel('com.mvbcast.crosswalk/time_events');

  final ValueNotifier<bool> _is24h = ValueNotifier<bool>(false);
  StreamSubscription? _sub;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Set the initial values.
    _updateTime();
    _sub = _evt
        .receiveBroadcastStream()
        .map((e) => e == true || e == 1 || e == 'true' || e == '24')
        .listen((v) => _is24h.value = v, onError: (_) {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _sub?.cancel();
    _sub = null;
    _is24h.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultUse24 = MediaQuery.of(context).alwaysUse24HourFormat;
    return Consumer<PrefLanguageProvider>(
      builder: (_, prefLanguageProvider, __) {
        return ValueListenableBuilder<bool>(
          valueListenable: _is24h,
          builder: (context, is24h, _) {
            final use24 = (_sub == null) ? defaultUse24 : is24h;
            final text = DateFormat(
              use24 ? 'HH:mm' : 'hh:mma',
              prefLanguageProvider.locale?.toLanguageTag(),
            ).format(DateTime.now());
            return V3AutoHyphenatingText(
              text,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: context.tokens.color.vsdslColorOnSurface,
                letterSpacing: -0.48,
              ),
            );
          },
        );
      },
    );
  }

  _updateTime() {
    if (!mounted) return;
    setState(() {
      _timer = Timer(
        const Duration(seconds: 60) - Duration(seconds: DateTime.now().second),
        _updateTime,
      );
    });
  }
}
