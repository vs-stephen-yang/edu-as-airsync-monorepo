import 'package:flutter_input_injection/flutter_input_injection.dart';
import 'package:display_flutter/protoc/event.pb.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

const defaultScreenWidth = 1920.0;
const defaultScreenHeight = 1080.0;
const maxEventId = 255;

class EventSlot {
  int channelId = -1;
  int eventId = -1;
}

class TouchEventManager {
  final List<EventSlot> _eventSlots =
  List.generate(maxEventId, (index) => EventSlot());
  final _flutterInputInjectionPlugin = FlutterInputInjection();
  double _injectScreenWidth = defaultScreenWidth;
  double _injectScreenHeight = defaultScreenHeight;

  void setScreenSize(double screenWidth, double screenHeight) {
    _injectScreenWidth = screenWidth;
    _injectScreenHeight = screenHeight;
  }

  int findSlotById(int channelId, int eventId) {
    int slot = -1;
    for (int i = 0; i < maxEventId; i++) {
      if (_eventSlots[i].channelId == channelId &&
          _eventSlots[i].eventId == eventId) {
        slot = i;
        break;
      }
    }
    return slot;
  }

  int acquireSlot(int channelId, int eventId) {
    // find a free slot
    int slot = findFreeSlot();
    if (slot < 0) {
      return -1;
    }

    _eventSlots[slot].channelId = channelId;
    _eventSlots[slot].eventId = eventId;
    return slot;
  }

  void releaseSlot(int slot) {
    assert(slot >= 0);
    assert(slot < maxEventId);

    _eventSlots[slot].channelId = -1;
    _eventSlots[slot].eventId = -1;
  }

  int releaseSlotById(int channelId, int eventId) {
    int slot = findSlotById(channelId, eventId);
    if (slot == -1) {
      return -1;
    }

    releaseSlot(slot);
    return slot;
  }

  int findFreeSlot() {
    for (int i = 0; i < maxEventId; i++) {
      if (_eventSlots[i].channelId == -1) {
        return i;
      }
    }
    return -1;
  }

  int reassignEventId(int channelId, int eventId, int action) {
    switch (action) {
      case FlutterInputInjection.TOUCH_POINT_START:
        return acquireSlot(channelId, eventId);
      case FlutterInputInjection.TOUCH_POINT_MOVE:
        return findSlotById(channelId, eventId);
      case FlutterInputInjection.TOUCH_POINT_END:
        return releaseSlotById(channelId, eventId);
      default:
        return -1;
    }
  }

  void releaseEventSlotsByDataChannel(RTCDataChannel dc) {
    for (int i = 0; i < maxEventId; i++) {
      if (_eventSlots[i].channelId == dc.id) {
        _flutterInputInjectionPlugin.sendTouch(
            FlutterInputInjection.TOUCH_POINT_END, i, 0, 0);
        releaseSlot(i);
      }
    }
  }

  void handleTouchEvent(TouchEvent touchEvent, int dcIndex) {
    int id = touchEvent.touchPoints[0].id;
    int action = FlutterInputInjection.TOUCH_POINT_START;
    if (touchEvent.eventType == TouchEvent_TouchEventType.TOUCH_POINT_START) {
      action = FlutterInputInjection.TOUCH_POINT_START;
    } else if (touchEvent.eventType == TouchEvent_TouchEventType.TOUCH_POINT_MOVE) {
      action = FlutterInputInjection.TOUCH_POINT_MOVE;
    } else if (touchEvent.eventType == TouchEvent_TouchEventType.TOUCH_POINT_END) {
      action = FlutterInputInjection.TOUCH_POINT_END;
    }

    id = reassignEventId(dcIndex, id, action);
    if (id == -1) {
      return;
    }

    double remoteX = touchEvent.touchPoints[0].x;
    double remoteY = touchEvent.touchPoints[0].y;

    int injectX = (remoteX * _injectScreenWidth).toInt();
    injectX = injectX.clamp(0, _injectScreenWidth.toInt() - 1);
    int injectY = (remoteY * _injectScreenHeight).toInt();
    injectY = injectY.clamp(0, _injectScreenHeight.toInt() - 1);

    _flutterInputInjectionPlugin.sendTouch(action, id, injectX, injectY);
  }
}