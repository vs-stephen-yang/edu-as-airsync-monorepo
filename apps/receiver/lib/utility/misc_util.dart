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
