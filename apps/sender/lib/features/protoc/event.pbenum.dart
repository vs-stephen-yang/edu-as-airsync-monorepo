///
//  Generated code. Do not modify.
//  source: event.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class KeyEvent_LockStates extends $pb.ProtobufEnum {
  static const KeyEvent_LockStates LOCK_STATES_CAPSLOCK = KeyEvent_LockStates._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'LOCK_STATES_CAPSLOCK');
  static const KeyEvent_LockStates LOCK_STATES_NUMLOCK = KeyEvent_LockStates._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'LOCK_STATES_NUMLOCK');

  static const $core.List<KeyEvent_LockStates> values = <KeyEvent_LockStates> [
    LOCK_STATES_CAPSLOCK,
    LOCK_STATES_NUMLOCK,
  ];

  static final $core.Map<$core.int, KeyEvent_LockStates> _byValue = $pb.ProtobufEnum.initByValue(values);
  static KeyEvent_LockStates? valueOf($core.int value) => _byValue[value];

  const KeyEvent_LockStates._($core.int v, $core.String n) : super(v, n);
}

class MouseEvent_MouseButton extends $pb.ProtobufEnum {
  static const MouseEvent_MouseButton BUTTON_UNDEFINED = MouseEvent_MouseButton._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'BUTTON_UNDEFINED');
  static const MouseEvent_MouseButton BUTTON_LEFT = MouseEvent_MouseButton._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'BUTTON_LEFT');
  static const MouseEvent_MouseButton BUTTON_MIDDLE = MouseEvent_MouseButton._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'BUTTON_MIDDLE');
  static const MouseEvent_MouseButton BUTTON_RIGHT = MouseEvent_MouseButton._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'BUTTON_RIGHT');
  static const MouseEvent_MouseButton BUTTON_BACK = MouseEvent_MouseButton._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'BUTTON_BACK');
  static const MouseEvent_MouseButton BUTTON_FORWARD = MouseEvent_MouseButton._(5, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'BUTTON_FORWARD');
  static const MouseEvent_MouseButton BUTTON_MAX = MouseEvent_MouseButton._(6, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'BUTTON_MAX');

  static const $core.List<MouseEvent_MouseButton> values = <MouseEvent_MouseButton> [
    BUTTON_UNDEFINED,
    BUTTON_LEFT,
    BUTTON_MIDDLE,
    BUTTON_RIGHT,
    BUTTON_BACK,
    BUTTON_FORWARD,
    BUTTON_MAX,
  ];

  static final $core.Map<$core.int, MouseEvent_MouseButton> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MouseEvent_MouseButton? valueOf($core.int value) => _byValue[value];

  const MouseEvent_MouseButton._($core.int v, $core.String n) : super(v, n);
}

class TouchEvent_TouchEventType extends $pb.ProtobufEnum {
  static const TouchEvent_TouchEventType TOUCH_POINT_UNDEFINED = TouchEvent_TouchEventType._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'TOUCH_POINT_UNDEFINED');
  static const TouchEvent_TouchEventType TOUCH_POINT_START = TouchEvent_TouchEventType._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'TOUCH_POINT_START');
  static const TouchEvent_TouchEventType TOUCH_POINT_MOVE = TouchEvent_TouchEventType._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'TOUCH_POINT_MOVE');
  static const TouchEvent_TouchEventType TOUCH_POINT_END = TouchEvent_TouchEventType._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'TOUCH_POINT_END');
  static const TouchEvent_TouchEventType TOUCH_POINT_CANCEL = TouchEvent_TouchEventType._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'TOUCH_POINT_CANCEL');

  static const $core.List<TouchEvent_TouchEventType> values = <TouchEvent_TouchEventType> [
    TOUCH_POINT_UNDEFINED,
    TOUCH_POINT_START,
    TOUCH_POINT_MOVE,
    TOUCH_POINT_END,
    TOUCH_POINT_CANCEL,
  ];

  static final $core.Map<$core.int, TouchEvent_TouchEventType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static TouchEvent_TouchEventType? valueOf($core.int value) => _byValue[value];

  const TouchEvent_TouchEventType._($core.int v, $core.String n) : super(v, n);
}

