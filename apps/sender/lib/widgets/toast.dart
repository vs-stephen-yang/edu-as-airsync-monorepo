import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

class Toast {
  static makeToast(String message,
      {int second = 3,
      msgContentColor = Colors.grey,
      msgTextStyle = const TextStyle(color: Colors.white)}) {
    BotToast.showText(
        text: message,
        duration: Duration(seconds: second),
        align: Alignment.center,
        contentColor: msgContentColor,
        textStyle: msgTextStyle);
  }
}
