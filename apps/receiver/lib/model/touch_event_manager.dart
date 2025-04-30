import 'dart:async';

import 'package:display_flutter/protoc/event.pb.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter_input_injection/flutter_input_injection.dart';

const _defaultScreenWidth = 1920.0;
const _defaultScreenHeight = 1536.0;
const _maxEventId = 255;
const _eventExpiredTime = 4000; //ms

class EventSlot {
  int? channelId;
  int? eventId;
  DateTime? timestamp;

  void clear() {
    channelId = null;
    eventId = null;
    timestamp = null;
  }

  bool isExpired(DateTime now) {
    if (timestamp == null) {
      return false;
    }

    return now.difference(timestamp!).inMilliseconds > _eventExpiredTime;
  }

  bool isEmpty() {
    return channelId == null || eventId == null || timestamp == null;
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
    if (_checkTimer != null) {
      return;
    }

    _checkTimer = Timer.periodic(
      const Duration(seconds: 1),
      _handleExpiredEvents,
    );
  }

  void _handleExpiredEvents(Timer t) {
    final currentTime = DateTime.now();

    bool hasActiveEvent = false;
    for (int i = 0; i < _eventSlots.length; i++) {
      final event = _eventSlots[i];

      if (event.isEmpty()) {
        continue;
      }

      if (event.isExpired(currentTime)) {
        log.info('event expired slot: $i id: ${event.eventId}');
        event.clear();

        _inputInjection.sendTouch(
            FlutterInputInjection.TOUCH_POINT_END, i, 0, 0);
      } else {
        hasActiveEvent = true;
      }
    }

    if (!hasActiveEvent) {
      stopCheckTimer();
    }
  }

  void stopCheckTimer() {
    _checkTimer?.cancel();
    _checkTimer = null;
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

  void releaseEventSlotsByChannelId(int channelId) {
    for (int i = 0; i < _maxEventId; i++) {
      if (_eventSlots[i].channelId == channelId) {
        _inputInjection.sendTouch(
            FlutterInputInjection.TOUCH_POINT_END, i, 0, 0);
        _releaseSlot(i);
      }
    }
  }

  int _convertTouchEventType(TouchEvent_TouchEventType touchEventType) {
    switch (touchEventType) {
      case TouchEvent_TouchEventType.TOUCH_POINT_START:
        return FlutterInputInjection.TOUCH_POINT_START;
      case TouchEvent_TouchEventType.TOUCH_POINT_MOVE:
        return FlutterInputInjection.TOUCH_POINT_MOVE;
      case TouchEvent_TouchEventType.TOUCH_POINT_END:
        return FlutterInputInjection.TOUCH_POINT_END;
      default:
        return FlutterInputInjection.TOUCH_POINT_START;
    }
  }

  void handleKeyEvent(KeyEvent event, int channelId) {
    _inputInjection.sendKey(event.usbKeycode, event.pressed);
  }

  void handleTouchEvent(TouchEvent touchEvent, int channelId) {
    final id = touchEvent.touchPoints[0].id;
    int action = _convertTouchEventType(touchEvent.eventType);
    final reassignedId = _reassignEventId(channelId, id, action);
    if (reassignedId == null) {
      return;
    }

    _eventSlots[reassignedId].timestamp = DateTime.now();
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
