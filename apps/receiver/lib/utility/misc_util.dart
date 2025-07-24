import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

String generateOTP(Random random) {
  final randomNumber = random.nextInt(10000);
  return randomNumber.toString().padLeft(4, '0');
}

String getPlatformName() {
  if (kIsWeb) {
    return 'Web';
  }

  if (Platform.isIOS) {
    return 'iOS';
  } else if (Platform.isAndroid) {
    return 'Android';
  } else {
    return '';
  }
}

String getDisplayCodeVisualIdentity(String displayCode) {
  String result = displayCode;
  if (displayCode.length > 5) {
    // https://stackoverflow.com/a/56845471/13160681
    result = displayCode
        .replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ")
        .trimRight();
  }
  return result;
}
