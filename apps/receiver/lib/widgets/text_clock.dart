import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TextClock extends StatefulWidget {
  const TextClock({Key? key}) : super(key: key);

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
    var now = DateTime.now();
    final time = DateFormat('hh:mm a').format(now);
    return Text(
      time,
      style: const TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.5),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
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
