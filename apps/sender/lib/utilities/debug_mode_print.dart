import 'package:flutter/foundation.dart';

debugModePrint(message, {Type? type}) {
  if (kDebugMode) {
    print('$type, $message');
  }
}
