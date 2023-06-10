///
//  Generated code. Do not modify.
//  source: control.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use clientResolutionDescriptor instead')
const ClientResolution$json = const {
  '1': 'ClientResolution',
  '2': const [
    const {'1': 'dips_width', '3': 1, '4': 1, '5': 5, '10': 'dipsWidth'},
    const {'1': 'dips_height', '3': 2, '4': 1, '5': 5, '10': 'dipsHeight'},
    const {'1': 'width_deprecated', '3': 3, '4': 1, '5': 5, '10': 'widthDeprecated'},
    const {'1': 'height_deprecated', '3': 4, '4': 1, '5': 5, '10': 'heightDeprecated'},
    const {'1': 'x_dpi', '3': 5, '4': 1, '5': 5, '10': 'xDpi'},
    const {'1': 'y_dpi', '3': 6, '4': 1, '5': 5, '10': 'yDpi'},
    const {'1': 'screen_id', '3': 7, '4': 1, '5': 3, '10': 'screenId'},
  ],
};

/// Descriptor for `ClientResolution`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientResolutionDescriptor = $convert.base64Decode('ChBDbGllbnRSZXNvbHV0aW9uEh0KCmRpcHNfd2lkdGgYASABKAVSCWRpcHNXaWR0aBIfCgtkaXBzX2hlaWdodBgCIAEoBVIKZGlwc0hlaWdodBIpChB3aWR0aF9kZXByZWNhdGVkGAMgASgFUg93aWR0aERlcHJlY2F0ZWQSKwoRaGVpZ2h0X2RlcHJlY2F0ZWQYBCABKAVSEGhlaWdodERlcHJlY2F0ZWQSEwoFeF9kcGkYBSABKAVSBHhEcGkSEwoFeV9kcGkYBiABKAVSBHlEcGkSGwoJc2NyZWVuX2lkGAcgASgDUghzY3JlZW5JZA==');
@$core.Deprecated('Use videoControlDescriptor instead')
const VideoControl$json = const {
  '1': 'VideoControl',
  '2': const [
    const {'1': 'enable', '3': 1, '4': 1, '5': 8, '10': 'enable'},
    const {'1': 'framerate_boost', '3': 4, '4': 1, '5': 11, '6': '.remoting.protocol.VideoControl.FramerateBoost', '10': 'framerateBoost'},
    const {'1': 'target_framerate', '3': 5, '4': 1, '5': 13, '10': 'targetFramerate'},
  ],
  '3': const [VideoControl_FramerateBoost$json],
  '9': const [
    const {'1': 2, '2': 3},
    const {'1': 3, '2': 4},
  ],
  '10': const ['lossless_encode', 'lossless_color'],
};

@$core.Deprecated('Use videoControlDescriptor instead')
const VideoControl_FramerateBoost$json = const {
  '1': 'FramerateBoost',
  '2': const [
    const {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
    const {'1': 'capture_interval_ms', '3': 2, '4': 1, '5': 5, '10': 'captureIntervalMs'},
    const {'1': 'boost_duration_ms', '3': 3, '4': 1, '5': 5, '10': 'boostDurationMs'},
  ],
};

/// Descriptor for `VideoControl`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List videoControlDescriptor = $convert.base64Decode('CgxWaWRlb0NvbnRyb2wSFgoGZW5hYmxlGAEgASgIUgZlbmFibGUSVwoPZnJhbWVyYXRlX2Jvb3N0GAQgASgLMi4ucmVtb3RpbmcucHJvdG9jb2wuVmlkZW9Db250cm9sLkZyYW1lcmF0ZUJvb3N0Ug5mcmFtZXJhdGVCb29zdBIpChB0YXJnZXRfZnJhbWVyYXRlGAUgASgNUg90YXJnZXRGcmFtZXJhdGUahgEKDkZyYW1lcmF0ZUJvb3N0EhgKB2VuYWJsZWQYASABKAhSB2VuYWJsZWQSLgoTY2FwdHVyZV9pbnRlcnZhbF9tcxgCIAEoBVIRY2FwdHVyZUludGVydmFsTXMSKgoRYm9vc3RfZHVyYXRpb25fbXMYAyABKAVSD2Jvb3N0RHVyYXRpb25Nc0oECAIQA0oECAMQBFIPbG9zc2xlc3NfZW5jb2RlUg5sb3NzbGVzc19jb2xvcg==');
@$core.Deprecated('Use audioControlDescriptor instead')
const AudioControl$json = const {
  '1': 'AudioControl',
  '2': const [
    const {'1': 'enable', '3': 1, '4': 1, '5': 8, '10': 'enable'},
  ],
};

/// Descriptor for `AudioControl`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List audioControlDescriptor = $convert.base64Decode('CgxBdWRpb0NvbnRyb2wSFgoGZW5hYmxlGAEgASgIUgZlbmFibGU=');
@$core.Deprecated('Use cursorShapeInfoDescriptor instead')
const CursorShapeInfo$json = const {
  '1': 'CursorShapeInfo',
  '2': const [
    const {'1': 'width', '3': 1, '4': 1, '5': 5, '10': 'width'},
    const {'1': 'height', '3': 2, '4': 1, '5': 5, '10': 'height'},
    const {'1': 'hotspot_x', '3': 3, '4': 1, '5': 5, '10': 'hotspotX'},
    const {'1': 'hotspot_y', '3': 4, '4': 1, '5': 5, '10': 'hotspotY'},
    const {'1': 'data', '3': 5, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `CursorShapeInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cursorShapeInfoDescriptor = $convert.base64Decode('Cg9DdXJzb3JTaGFwZUluZm8SFAoFd2lkdGgYASABKAVSBXdpZHRoEhYKBmhlaWdodBgCIAEoBVIGaGVpZ2h0EhsKCWhvdHNwb3RfeBgDIAEoBVIIaG90c3BvdFgSGwoJaG90c3BvdF95GAQgASgFUghob3RzcG90WRISCgRkYXRhGAUgASgMUgRkYXRh');
@$core.Deprecated('Use capabilitiesDescriptor instead')
const Capabilities$json = const {
  '1': 'Capabilities',
  '2': const [
    const {'1': 'capabilities', '3': 1, '4': 1, '5': 9, '10': 'capabilities'},
  ],
};

/// Descriptor for `Capabilities`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List capabilitiesDescriptor = $convert.base64Decode('CgxDYXBhYmlsaXRpZXMSIgoMY2FwYWJpbGl0aWVzGAEgASgJUgxjYXBhYmlsaXRpZXM=');
@$core.Deprecated('Use pairingRequestDescriptor instead')
const PairingRequest$json = const {
  '1': 'PairingRequest',
  '2': const [
    const {'1': 'client_name', '3': 1, '4': 1, '5': 9, '10': 'clientName'},
  ],
};

/// Descriptor for `PairingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pairingRequestDescriptor = $convert.base64Decode('Cg5QYWlyaW5nUmVxdWVzdBIfCgtjbGllbnRfbmFtZRgBIAEoCVIKY2xpZW50TmFtZQ==');
@$core.Deprecated('Use pairingResponseDescriptor instead')
const PairingResponse$json = const {
  '1': 'PairingResponse',
  '2': const [
    const {'1': 'client_id', '3': 1, '4': 1, '5': 9, '10': 'clientId'},
    const {'1': 'shared_secret', '3': 2, '4': 1, '5': 9, '10': 'sharedSecret'},
  ],
};

/// Descriptor for `PairingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pairingResponseDescriptor = $convert.base64Decode('Cg9QYWlyaW5nUmVzcG9uc2USGwoJY2xpZW50X2lkGAEgASgJUghjbGllbnRJZBIjCg1zaGFyZWRfc2VjcmV0GAIgASgJUgxzaGFyZWRTZWNyZXQ=');
@$core.Deprecated('Use extensionMessageDescriptor instead')
const ExtensionMessage$json = const {
  '1': 'ExtensionMessage',
  '2': const [
    const {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    const {'1': 'data', '3': 2, '4': 1, '5': 9, '10': 'data'},
  ],
};

/// Descriptor for `ExtensionMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionMessageDescriptor = $convert.base64Decode('ChBFeHRlbnNpb25NZXNzYWdlEhIKBHR5cGUYASABKAlSBHR5cGUSEgoEZGF0YRgCIAEoCVIEZGF0YQ==');
@$core.Deprecated('Use videoTrackLayoutDescriptor instead')
const VideoTrackLayout$json = const {
  '1': 'VideoTrackLayout',
  '2': const [
    const {'1': 'screen_id', '3': 8, '4': 1, '5': 3, '10': 'screenId'},
    const {'1': 'media_stream_id', '3': 1, '4': 1, '5': 9, '10': 'mediaStreamId'},
    const {'1': 'position_x', '3': 2, '4': 1, '5': 5, '10': 'positionX'},
    const {'1': 'position_y', '3': 3, '4': 1, '5': 5, '10': 'positionY'},
    const {'1': 'width', '3': 4, '4': 1, '5': 5, '10': 'width'},
    const {'1': 'height', '3': 5, '4': 1, '5': 5, '10': 'height'},
    const {'1': 'x_dpi', '3': 6, '4': 1, '5': 5, '10': 'xDpi'},
    const {'1': 'y_dpi', '3': 7, '4': 1, '5': 5, '10': 'yDpi'},
  ],
};

/// Descriptor for `VideoTrackLayout`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List videoTrackLayoutDescriptor = $convert.base64Decode('ChBWaWRlb1RyYWNrTGF5b3V0EhsKCXNjcmVlbl9pZBgIIAEoA1IIc2NyZWVuSWQSJgoPbWVkaWFfc3RyZWFtX2lkGAEgASgJUg1tZWRpYVN0cmVhbUlkEh0KCnBvc2l0aW9uX3gYAiABKAVSCXBvc2l0aW9uWBIdCgpwb3NpdGlvbl95GAMgASgFUglwb3NpdGlvblkSFAoFd2lkdGgYBCABKAVSBXdpZHRoEhYKBmhlaWdodBgFIAEoBVIGaGVpZ2h0EhMKBXhfZHBpGAYgASgFUgR4RHBpEhMKBXlfZHBpGAcgASgFUgR5RHBp');
@$core.Deprecated('Use videoLayoutDescriptor instead')
const VideoLayout$json = const {
  '1': 'VideoLayout',
  '2': const [
    const {'1': 'video_track', '3': 1, '4': 3, '5': 11, '6': '.remoting.protocol.VideoTrackLayout', '10': 'videoTrack'},
    const {'1': 'supports_full_desktop_capture', '3': 2, '4': 1, '5': 8, '10': 'supportsFullDesktopCapture'},
    const {'1': 'primary_screen_id', '3': 3, '4': 1, '5': 3, '10': 'primaryScreenId'},
  ],
};

/// Descriptor for `VideoLayout`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List videoLayoutDescriptor = $convert.base64Decode('CgtWaWRlb0xheW91dBJECgt2aWRlb190cmFjaxgBIAMoCzIjLnJlbW90aW5nLnByb3RvY29sLlZpZGVvVHJhY2tMYXlvdXRSCnZpZGVvVHJhY2sSQQodc3VwcG9ydHNfZnVsbF9kZXNrdG9wX2NhcHR1cmUYAiABKAhSGnN1cHBvcnRzRnVsbERlc2t0b3BDYXB0dXJlEioKEXByaW1hcnlfc2NyZWVuX2lkGAMgASgDUg9wcmltYXJ5U2NyZWVuSWQ=');
@$core.Deprecated('Use selectDesktopDisplayRequestDescriptor instead')
const SelectDesktopDisplayRequest$json = const {
  '1': 'SelectDesktopDisplayRequest',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `SelectDesktopDisplayRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List selectDesktopDisplayRequestDescriptor = $convert.base64Decode('ChtTZWxlY3REZXNrdG9wRGlzcGxheVJlcXVlc3QSDgoCaWQYASABKAlSAmlk');
@$core.Deprecated('Use keyboardLayoutDescriptor instead')
const KeyboardLayout$json = const {
  '1': 'KeyboardLayout',
  '2': const [
    const {'1': 'keys', '3': 1, '4': 3, '5': 11, '6': '.remoting.protocol.KeyboardLayout.KeysEntry', '10': 'keys'},
  ],
  '3': const [KeyboardLayout_KeyAction$json, KeyboardLayout_KeyBehavior$json, KeyboardLayout_KeysEntry$json],
};

@$core.Deprecated('Use keyboardLayoutDescriptor instead')
const KeyboardLayout_KeyAction$json = const {
  '1': 'KeyAction',
  '2': const [
    const {'1': 'function', '3': 1, '4': 1, '5': 14, '6': '.remoting.protocol.LayoutKeyFunction', '9': 0, '10': 'function'},
    const {'1': 'character', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'character'},
  ],
  '8': const [
    const {'1': 'action'},
  ],
};

@$core.Deprecated('Use keyboardLayoutDescriptor instead')
const KeyboardLayout_KeyBehavior$json = const {
  '1': 'KeyBehavior',
  '2': const [
    const {'1': 'actions', '3': 1, '4': 3, '5': 11, '6': '.remoting.protocol.KeyboardLayout.KeyBehavior.ActionsEntry', '10': 'actions'},
  ],
  '3': const [KeyboardLayout_KeyBehavior_ActionsEntry$json],
};

@$core.Deprecated('Use keyboardLayoutDescriptor instead')
const KeyboardLayout_KeyBehavior_ActionsEntry$json = const {
  '1': 'ActionsEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 13, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.remoting.protocol.KeyboardLayout.KeyAction', '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use keyboardLayoutDescriptor instead')
const KeyboardLayout_KeysEntry$json = const {
  '1': 'KeysEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 13, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.remoting.protocol.KeyboardLayout.KeyBehavior', '10': 'value'},
  ],
  '7': const {'7': true},
};

/// Descriptor for `KeyboardLayout`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyboardLayoutDescriptor = $convert.base64Decode('Cg5LZXlib2FyZExheW91dBI/CgRrZXlzGAEgAygLMisucmVtb3RpbmcucHJvdG9jb2wuS2V5Ym9hcmRMYXlvdXQuS2V5c0VudHJ5UgRrZXlzGnkKCUtleUFjdGlvbhJCCghmdW5jdGlvbhgBIAEoDjIkLnJlbW90aW5nLnByb3RvY29sLkxheW91dEtleUZ1bmN0aW9uSABSCGZ1bmN0aW9uEh4KCWNoYXJhY3RlchgCIAEoCUgAUgljaGFyYWN0ZXJCCAoGYWN0aW9uGswBCgtLZXlCZWhhdmlvchJUCgdhY3Rpb25zGAEgAygLMjoucmVtb3RpbmcucHJvdG9jb2wuS2V5Ym9hcmRMYXlvdXQuS2V5QmVoYXZpb3IuQWN0aW9uc0VudHJ5UgdhY3Rpb25zGmcKDEFjdGlvbnNFbnRyeRIQCgNrZXkYASABKA1SA2tleRJBCgV2YWx1ZRgCIAEoCzIrLnJlbW90aW5nLnByb3RvY29sLktleWJvYXJkTGF5b3V0LktleUFjdGlvblIFdmFsdWU6AjgBGmYKCUtleXNFbnRyeRIQCgNrZXkYASABKA1SA2tleRJDCgV2YWx1ZRgCIAEoCzItLnJlbW90aW5nLnByb3RvY29sLktleWJvYXJkTGF5b3V0LktleUJlaGF2aW9yUgV2YWx1ZToCOAE=');
@$core.Deprecated('Use transportInfoDescriptor instead')
const TransportInfo$json = const {
  '1': 'TransportInfo',
  '2': const [
    const {'1': 'protocol', '3': 1, '4': 1, '5': 9, '10': 'protocol'},
  ],
};

/// Descriptor for `TransportInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transportInfoDescriptor = $convert.base64Decode('Cg1UcmFuc3BvcnRJbmZvEhoKCHByb3RvY29sGAEgASgJUghwcm90b2NvbA==');
@$core.Deprecated('Use peerConnectionParametersDescriptor instead')
const PeerConnectionParameters$json = const {
  '1': 'PeerConnectionParameters',
  '2': const [
    const {'1': 'preferred_min_bitrate_bps', '3': 1, '4': 1, '5': 5, '10': 'preferredMinBitrateBps'},
    const {'1': 'preferred_max_bitrate_bps', '3': 2, '4': 1, '5': 5, '10': 'preferredMaxBitrateBps'},
    const {'1': 'request_ice_restart', '3': 3, '4': 1, '5': 8, '10': 'requestIceRestart'},
    const {'1': 'request_sdp_restart', '3': 4, '4': 1, '5': 8, '10': 'requestSdpRestart'},
  ],
};

/// Descriptor for `PeerConnectionParameters`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List peerConnectionParametersDescriptor = $convert.base64Decode('ChhQZWVyQ29ubmVjdGlvblBhcmFtZXRlcnMSOQoZcHJlZmVycmVkX21pbl9iaXRyYXRlX2JwcxgBIAEoBVIWcHJlZmVycmVkTWluQml0cmF0ZUJwcxI5ChlwcmVmZXJyZWRfbWF4X2JpdHJhdGVfYnBzGAIgASgFUhZwcmVmZXJyZWRNYXhCaXRyYXRlQnBzEi4KE3JlcXVlc3RfaWNlX3Jlc3RhcnQYAyABKAhSEXJlcXVlc3RJY2VSZXN0YXJ0Ei4KE3JlcXVlc3Rfc2RwX3Jlc3RhcnQYBCABKAhSEXJlcXVlc3RTZHBSZXN0YXJ0');
