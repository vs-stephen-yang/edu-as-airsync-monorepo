import 'package:display_cast_flutter/features/protoc/event.pb.dart' as pb;
import 'package:flutter/services.dart';

pb.KeyEvent toKeyEvent(KeyEvent event) {
  return pb.KeyEvent(
    pressed: event is KeyDownEvent,
    usbKeycode: event.physicalKey.usbHidUsage,
  );
}
