import 'package:display_cast_flutter/features/protoc/event.pb.dart' as pb;
import 'package:flutter/services.dart';

// Though it is not a subclass of KeyDownEvent, a KeyRepeatEvent is also a key down event.
// Don't assume that keyEvent is! KeyDownEvent only allows key up events.
// Check both KeyDownEvent and KeyRepeatEvent.
bool isKeyDownEvent(KeyEvent event) {
  return event is KeyDownEvent || event is KeyRepeatEvent;
}

pb.KeyEvent toKeyEvent(KeyEvent event) {
  return pb.KeyEvent(
    pressed: isKeyDownEvent(event),
    usbKeycode: event.physicalKey.usbHidUsage,
  );
}
