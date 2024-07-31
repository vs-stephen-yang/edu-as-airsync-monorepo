import 'dart:async';

import 'package:flutter_input_injection/flutter_input_injection.dart';
import 'package:display_flutter/protoc/event.pb.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

const _defaultScreenWidth = 1920.0;
const _defaultScreenHeight = 1080.0;
const _maxEventId = 255;
const _eventExpiredTime = 4000; //ms

class EventSlot {
  int? channelId;
  int? eventId;
  int timestamp = 0;

  void clear() {
    channelId = null;
    eventId = null;
    timestamp = 0;
  }

  bool isEmpty() {
    return channelId == null || eventId == null;
  }
}

class TouchEventManager {
  final _eventSlots = List.generate(_maxEventId, (index) => EventSlot());

  final _inputInjection = FlutterInputInjection();

  double _injectScreenWidth = _defaultScreenWidth;
  double _injectScreenHeight = _defaultScreenHeight;

  Timer? _checkTimer;

  void setScreenSize(double screenWidth, double screenHeight) {
    _injectScreenWidth = screenWidth;
    _injectScreenHeight = screenHeight;
  }

  void _startCheckTimer() {
    if (_checkTimer != null && _checkTimer!.isActive) return;

    _checkTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      bool hasActiveEvent = false;
      for (int i = 0; i < _eventSlots.length; i++) {
        final event = _eventSlots[i];
        if (!event.isEmpty()) {
          if (currentTime - event.timestamp > _eventExpiredTime) {
            log.info('event expired slot: $i id: ${event.eventId}');
            event.clear();
            _inputInjection.sendTouch(
                FlutterInputInjection.TOUCH_POINT_END, i, 0, 0);
          } else {
            hasActiveEvent = true;
          }
        }
      }

      if (!hasActiveEvent) {
        stopCheckTimer();
      }
    });
  }

  void stopCheckTimer() {
    _checkTimer?.cancel();
  }

  int? _findSlotById(int channelId, int eventId) {
    for (int i = 0; i < _maxEventId; i++) {
      if (_eventSlots[i].channelId == channelId &&
          _eventSlots[i].eventId == eventId) {
        return i;
      }
    }
    return null;
  }

  int? _acquireSlot(int channelId, int eventId) {
    // find a free slot
    final slot = findFreeSlot();
    if (slot == null) {
      return null;
    }

    _eventSlots[slot].channelId = channelId;
    _eventSlots[slot].eventId = eventId;
    return slot;
  }

  void _releaseSlot(int slot) {
    assert(slot >= 0);
    assert(slot < _maxEventId);

    _eventSlots[slot].channelId = null;
    _eventSlots[slot].eventId = null;
  }

  int? _releaseSlotById(int channelId, int eventId) {
    final slot = _findSlotById(channelId, eventId);
    if (slot == null) {
      return null;
    }

    _releaseSlot(slot);
    return slot;
  }

  int? findFreeSlot() {
    for (int i = 0; i < _maxEventId; i++) {
      if (_eventSlots[i].isEmpty()) {
        return i;
      }
    }
    return null;
  }

  int? _reassignEventId(int channelId, int eventId, int action) {
    switch (action) {
      case FlutterInputInjection.TOUCH_POINT_START:
        return _acquireSlot(channelId, eventId);
      case FlutterInputInjection.TOUCH_POINT_MOVE:
        return _findSlotById(channelId, eventId);
      case FlutterInputInjection.TOUCH_POINT_END:
        return _releaseSlotById(channelId, eventId);
      default:
        return null;
    }
  }

  void releaseEventSlotsByDataChannel(RTCDataChannel dc) {
    for (int i = 0; i < _maxEventId; i++) {
      if (_eventSlots[i].channelId == dc.id) {
        _inputInjection.sendTouch(
            FlutterInputInjection.TOUCH_POINT_END, i, 0, 0);
        _releaseSlot(i);
      }
    }
  }

  void handleTouchEvent(TouchEvent touchEvent, int dcIndex) {
    final id = touchEvent.touchPoints[0].id;

    int action = FlutterInputInjection.TOUCH_POINT_START;

    if (touchEvent.eventType == TouchEvent_TouchEventType.TOUCH_POINT_START) {
      action = FlutterInputInjection.TOUCH_POINT_START;
    } else if (touchEvent.eventType ==
        TouchEvent_TouchEventType.TOUCH_POINT_MOVE) {
      action = FlutterInputInjection.TOUCH_POINT_MOVE;
    } else if (touchEvent.eventType ==
        TouchEvent_TouchEventType.TOUCH_POINT_END) {
      action = FlutterInputInjection.TOUCH_POINT_END;
    }

    final reassignedId = _reassignEventId(dcIndex, id, action);
    if (reassignedId == null) {
      return;
    }

    _eventSlots[reassignedId].timestamp = DateTime.now().millisecondsSinceEpoch;
    _startCheckTimer();

    double remoteX = touchEvent.touchPoints[0].x;
    double remoteY = touchEvent.touchPoints[0].y;

    int injectX = (remoteX * _injectScreenWidth).toInt();
    injectX = injectX.clamp(0, _injectScreenWidth.toInt() - 1);

    int injectY = (remoteY * _injectScreenHeight).toInt();
    injectY = injectY.clamp(0, _injectScreenHeight.toInt() - 1);

    _inputInjection.sendTouch(action, reassignedId, injectX, injectY);
  }
}
