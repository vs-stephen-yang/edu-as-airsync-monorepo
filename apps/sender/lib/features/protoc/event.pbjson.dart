///
//  Generated code. Do not modify.
//  source: event.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use keyEventDescriptor instead')
const KeyEvent$json = const {
  '1': 'KeyEvent',
  '2': const [
    const {'1': 'pressed', '3': 2, '4': 1, '5': 8, '10': 'pressed'},
    const {'1': 'usb_keycode', '3': 3, '4': 1, '5': 13, '10': 'usbKeycode'},
    const {'1': 'lock_states', '3': 4, '4': 1, '5': 13, '7': '0', '10': 'lockStates'},
    const {'1': 'caps_lock_state', '3': 5, '4': 1, '5': 8, '10': 'capsLockState'},
    const {'1': 'num_lock_state', '3': 6, '4': 1, '5': 8, '10': 'numLockState'},
  ],
  '4': const [KeyEvent_LockStates$json],
};

@$core.Deprecated('Use keyEventDescriptor instead')
const KeyEvent_LockStates$json = const {
  '1': 'LockStates',
  '2': const [
    const {'1': 'LOCK_STATES_CAPSLOCK', '2': 1},
    const {'1': 'LOCK_STATES_NUMLOCK', '2': 2},
  ],
};

/// Descriptor for `KeyEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyEventDescriptor = $convert.base64Decode('CghLZXlFdmVudBIYCgdwcmVzc2VkGAIgASgIUgdwcmVzc2VkEh8KC3VzYl9rZXljb2RlGAMgASgNUgp1c2JLZXljb2RlEiIKC2xvY2tfc3RhdGVzGAQgASgNOgEwUgpsb2NrU3RhdGVzEiYKD2NhcHNfbG9ja19zdGF0ZRgFIAEoCFINY2Fwc0xvY2tTdGF0ZRIkCg5udW1fbG9ja19zdGF0ZRgGIAEoCFIMbnVtTG9ja1N0YXRlIj8KCkxvY2tTdGF0ZXMSGAoUTE9DS19TVEFURVNfQ0FQU0xPQ0sQARIXChNMT0NLX1NUQVRFU19OVU1MT0NLEAI=');
@$core.Deprecated('Use textEventDescriptor instead')
const TextEvent$json = const {
  '1': 'TextEvent',
  '2': const [
    const {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
  ],
};

/// Descriptor for `TextEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List textEventDescriptor = $convert.base64Decode('CglUZXh0RXZlbnQSEgoEdGV4dBgBIAEoCVIEdGV4dA==');
@$core.Deprecated('Use fractionalCoordinateDescriptor instead')
const FractionalCoordinate$json = const {
  '1': 'FractionalCoordinate',
  '2': const [
    const {'1': 'x', '3': 1, '4': 1, '5': 2, '10': 'x'},
    const {'1': 'y', '3': 2, '4': 1, '5': 2, '10': 'y'},
    const {'1': 'screen_id', '3': 3, '4': 1, '5': 3, '10': 'screenId'},
  ],
};

/// Descriptor for `FractionalCoordinate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fractionalCoordinateDescriptor = $convert.base64Decode('ChRGcmFjdGlvbmFsQ29vcmRpbmF0ZRIMCgF4GAEgASgCUgF4EgwKAXkYAiABKAJSAXkSGwoJc2NyZWVuX2lkGAMgASgDUghzY3JlZW5JZA==');
@$core.Deprecated('Use mouseEventDescriptor instead')
const MouseEvent$json = const {
  '1': 'MouseEvent',
  '2': const [
    const {'1': 'x', '3': 1, '4': 1, '5': 5, '10': 'x'},
    const {'1': 'y', '3': 2, '4': 1, '5': 5, '10': 'y'},
    const {'1': 'button', '3': 5, '4': 1, '5': 14, '6': '.remoting.protocol.MouseEvent.MouseButton', '10': 'button'},
    const {'1': 'button_down', '3': 6, '4': 1, '5': 8, '10': 'buttonDown'},
    const {'1': 'wheel_delta_x', '3': 7, '4': 1, '5': 2, '10': 'wheelDeltaX'},
    const {'1': 'wheel_delta_y', '3': 8, '4': 1, '5': 2, '10': 'wheelDeltaY'},
    const {'1': 'wheel_ticks_x', '3': 9, '4': 1, '5': 2, '10': 'wheelTicksX'},
    const {'1': 'wheel_ticks_y', '3': 10, '4': 1, '5': 2, '10': 'wheelTicksY'},
    const {'1': 'delta_x', '3': 11, '4': 1, '5': 5, '10': 'deltaX'},
    const {'1': 'delta_y', '3': 12, '4': 1, '5': 5, '10': 'deltaY'},
    const {'1': 'fractional_coordinate', '3': 13, '4': 1, '5': 11, '6': '.remoting.protocol.FractionalCoordinate', '10': 'fractionalCoordinate'},
  ],
  '4': const [MouseEvent_MouseButton$json],
};

@$core.Deprecated('Use mouseEventDescriptor instead')
const MouseEvent_MouseButton$json = const {
  '1': 'MouseButton',
  '2': const [
    const {'1': 'BUTTON_UNDEFINED', '2': 0},
    const {'1': 'BUTTON_LEFT', '2': 1},
    const {'1': 'BUTTON_MIDDLE', '2': 2},
    const {'1': 'BUTTON_RIGHT', '2': 3},
    const {'1': 'BUTTON_BACK', '2': 4},
    const {'1': 'BUTTON_FORWARD', '2': 5},
    const {'1': 'BUTTON_MAX', '2': 6},
  ],
};

/// Descriptor for `MouseEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mouseEventDescriptor = $convert.base64Decode('CgpNb3VzZUV2ZW50EgwKAXgYASABKAVSAXgSDAoBeRgCIAEoBVIBeRJBCgZidXR0b24YBSABKA4yKS5yZW1vdGluZy5wcm90b2NvbC5Nb3VzZUV2ZW50Lk1vdXNlQnV0dG9uUgZidXR0b24SHwoLYnV0dG9uX2Rvd24YBiABKAhSCmJ1dHRvbkRvd24SIgoNd2hlZWxfZGVsdGFfeBgHIAEoAlILd2hlZWxEZWx0YVgSIgoNd2hlZWxfZGVsdGFfeRgIIAEoAlILd2hlZWxEZWx0YVkSIgoNd2hlZWxfdGlja3NfeBgJIAEoAlILd2hlZWxUaWNrc1gSIgoNd2hlZWxfdGlja3NfeRgKIAEoAlILd2hlZWxUaWNrc1kSFwoHZGVsdGFfeBgLIAEoBVIGZGVsdGFYEhcKB2RlbHRhX3kYDCABKAVSBmRlbHRhWRJcChVmcmFjdGlvbmFsX2Nvb3JkaW5hdGUYDSABKAsyJy5yZW1vdGluZy5wcm90b2NvbC5GcmFjdGlvbmFsQ29vcmRpbmF0ZVIUZnJhY3Rpb25hbENvb3JkaW5hdGUijgEKC01vdXNlQnV0dG9uEhQKEEJVVFRPTl9VTkRFRklORUQQABIPCgtCVVRUT05fTEVGVBABEhEKDUJVVFRPTl9NSURETEUQAhIQCgxCVVRUT05fUklHSFQQAxIPCgtCVVRUT05fQkFDSxAEEhIKDkJVVFRPTl9GT1JXQVJEEAUSDgoKQlVUVE9OX01BWBAG');
@$core.Deprecated('Use clipboardEventDescriptor instead')
const ClipboardEvent$json = const {
  '1': 'ClipboardEvent',
  '2': const [
    const {'1': 'mime_type', '3': 1, '4': 1, '5': 9, '10': 'mimeType'},
    const {'1': 'data', '3': 2, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `ClipboardEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clipboardEventDescriptor = $convert.base64Decode('Cg5DbGlwYm9hcmRFdmVudBIbCgltaW1lX3R5cGUYASABKAlSCG1pbWVUeXBlEhIKBGRhdGEYAiABKAxSBGRhdGE=');
@$core.Deprecated('Use touchEventPointDescriptor instead')
const TouchEventPoint$json = const {
  '1': 'TouchEventPoint',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    const {'1': 'x', '3': 2, '4': 1, '5': 2, '10': 'x'},
    const {'1': 'y', '3': 3, '4': 1, '5': 2, '10': 'y'},
    const {'1': 'radius_x', '3': 4, '4': 1, '5': 2, '10': 'radiusX'},
    const {'1': 'radius_y', '3': 5, '4': 1, '5': 2, '10': 'radiusY'},
    const {'1': 'angle', '3': 6, '4': 1, '5': 2, '10': 'angle'},
    const {'1': 'pressure', '3': 7, '4': 1, '5': 2, '10': 'pressure'},
    const {'1': 'fractional_coordinate', '3': 8, '4': 1, '5': 11, '6': '.remoting.protocol.FractionalCoordinate', '10': 'fractionalCoordinate'},
  ],
};

/// Descriptor for `TouchEventPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List touchEventPointDescriptor = $convert.base64Decode('Cg9Ub3VjaEV2ZW50UG9pbnQSDgoCaWQYASABKA1SAmlkEgwKAXgYAiABKAJSAXgSDAoBeRgDIAEoAlIBeRIZCghyYWRpdXNfeBgEIAEoAlIHcmFkaXVzWBIZCghyYWRpdXNfeRgFIAEoAlIHcmFkaXVzWRIUCgVhbmdsZRgGIAEoAlIFYW5nbGUSGgoIcHJlc3N1cmUYByABKAJSCHByZXNzdXJlElwKFWZyYWN0aW9uYWxfY29vcmRpbmF0ZRgIIAEoCzInLnJlbW90aW5nLnByb3RvY29sLkZyYWN0aW9uYWxDb29yZGluYXRlUhRmcmFjdGlvbmFsQ29vcmRpbmF0ZQ==');
@$core.Deprecated('Use touchEventDescriptor instead')
const TouchEvent$json = const {
  '1': 'TouchEvent',
  '2': const [
    const {'1': 'event_type', '3': 1, '4': 1, '5': 14, '6': '.remoting.protocol.TouchEvent.TouchEventType', '10': 'eventType'},
    const {'1': 'touch_points', '3': 2, '4': 3, '5': 11, '6': '.remoting.protocol.TouchEventPoint', '10': 'touchPoints'},
  ],
  '4': const [TouchEvent_TouchEventType$json],
};

@$core.Deprecated('Use touchEventDescriptor instead')
const TouchEvent_TouchEventType$json = const {
  '1': 'TouchEventType',
  '2': const [
    const {'1': 'TOUCH_POINT_UNDEFINED', '2': 0},
    const {'1': 'TOUCH_POINT_START', '2': 1},
    const {'1': 'TOUCH_POINT_MOVE', '2': 2},
    const {'1': 'TOUCH_POINT_END', '2': 3},
    const {'1': 'TOUCH_POINT_CANCEL', '2': 4},
  ],
};

/// Descriptor for `TouchEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List touchEventDescriptor = $convert.base64Decode('CgpUb3VjaEV2ZW50EksKCmV2ZW50X3R5cGUYASABKA4yLC5yZW1vdGluZy5wcm90b2NvbC5Ub3VjaEV2ZW50LlRvdWNoRXZlbnRUeXBlUglldmVudFR5cGUSRQoMdG91Y2hfcG9pbnRzGAIgAygLMiIucmVtb3RpbmcucHJvdG9jb2wuVG91Y2hFdmVudFBvaW50Ugt0b3VjaFBvaW50cyKFAQoOVG91Y2hFdmVudFR5cGUSGQoVVE9VQ0hfUE9JTlRfVU5ERUZJTkVEEAASFQoRVE9VQ0hfUE9JTlRfU1RBUlQQARIUChBUT1VDSF9QT0lOVF9NT1ZFEAISEwoPVE9VQ0hfUE9JTlRfRU5EEAMSFgoSVE9VQ0hfUE9JTlRfQ0FOQ0VMEAQ=');
