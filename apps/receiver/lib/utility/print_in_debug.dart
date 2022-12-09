import 'package:flutter/foundation.dart';

printInDebug(message, {Type? type}) {
  if (kDebugMode) {
    print('$type, $message');
  }
}
