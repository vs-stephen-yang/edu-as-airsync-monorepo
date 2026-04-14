///
//  Generated code. Do not modify.
//  source: internal.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use controlMessageDescriptor instead')
const ControlMessage$json = const {
  '1': 'ControlMessage',
  '2': const [
    const {'1': 'clipboard_event', '3': 1, '4': 1, '5': 11, '6': '.remoting.protocol.ClipboardEvent', '10': 'clipboardEvent'},
    const {'1': 'client_resolution', '3': 2, '4': 1, '5': 11, '6': '.remoting.protocol.ClientResolution', '10': 'clientResolution'},
    const {'1': 'cursor_shape', '3': 4, '4': 1, '5': 11, '6': '.remoting.protocol.CursorShapeInfo', '10': 'cursorShape'},
    const {'1': 'video_control', '3': 3, '4': 1, '5': 11, '6': '.remoting.protocol.VideoControl', '10': 'videoControl'},
    const {'1': 'audio_control', '3': 5, '4': 1, '5': 11, '6': '.remoting.protocol.AudioControl', '10': 'audioControl'},
    const {'1': 'capabilities', '3': 6, '4': 1, '5': 11, '6': '.remoting.protocol.Capabilities', '10': 'capabilities'},
    const {'1': 'pairing_request', '3': 7, '4': 1, '5': 11, '6': '.remoting.protocol.PairingRequest', '10': 'pairingRequest'},
    const {'1': 'pairing_response', '3': 8, '4': 1, '5': 11, '6': '.remoting.protocol.PairingResponse', '10': 'pairingResponse'},
    const {'1': 'extension_message', '3': 9, '4': 1, '5': 11, '6': '.remoting.protocol.ExtensionMessage', '10': 'extensionMessage'},
    const {'1': 'video_layout', '3': 10, '4': 1, '5': 11, '6': '.remoting.protocol.VideoLayout', '10': 'videoLayout'},
    const {'1': 'select_display', '3': 11, '4': 1, '5': 11, '6': '.remoting.protocol.SelectDesktopDisplayRequest', '10': 'selectDisplay'},
    const {'1': 'keyboard_layout', '3': 12, '4': 1, '5': 11, '6': '.remoting.protocol.KeyboardLayout', '10': 'keyboardLayout'},
    const {'1': 'transport_info', '3': 13, '4': 1, '5': 11, '6': '.remoting.protocol.TransportInfo', '10': 'transportInfo'},
    const {'1': 'peer_connection_parameters', '3': 14, '4': 1, '5': 11, '6': '.remoting.protocol.PeerConnectionParameters', '10': 'peerConnectionParameters'},
  ],
};

/// Descriptor for `ControlMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List controlMessageDescriptor = $convert.base64Decode('Cg5Db250cm9sTWVzc2FnZRJKCg9jbGlwYm9hcmRfZXZlbnQYASABKAsyIS5yZW1vdGluZy5wcm90b2NvbC5DbGlwYm9hcmRFdmVudFIOY2xpcGJvYXJkRXZlbnQSUAoRY2xpZW50X3Jlc29sdXRpb24YAiABKAsyIy5yZW1vdGluZy5wcm90b2NvbC5DbGllbnRSZXNvbHV0aW9uUhBjbGllbnRSZXNvbHV0aW9uEkUKDGN1cnNvcl9zaGFwZRgEIAEoCzIiLnJlbW90aW5nLnByb3RvY29sLkN1cnNvclNoYXBlSW5mb1ILY3Vyc29yU2hhcGUSRAoNdmlkZW9fY29udHJvbBgDIAEoCzIfLnJlbW90aW5nLnByb3RvY29sLlZpZGVvQ29udHJvbFIMdmlkZW9Db250cm9sEkQKDWF1ZGlvX2NvbnRyb2wYBSABKAsyHy5yZW1vdGluZy5wcm90b2NvbC5BdWRpb0NvbnRyb2xSDGF1ZGlvQ29udHJvbBJDCgxjYXBhYmlsaXRpZXMYBiABKAsyHy5yZW1vdGluZy5wcm90b2NvbC5DYXBhYmlsaXRpZXNSDGNhcGFiaWxpdGllcxJKCg9wYWlyaW5nX3JlcXVlc3QYByABKAsyIS5yZW1vdGluZy5wcm90b2NvbC5QYWlyaW5nUmVxdWVzdFIOcGFpcmluZ1JlcXVlc3QSTQoQcGFpcmluZ19yZXNwb25zZRgIIAEoCzIiLnJlbW90aW5nLnByb3RvY29sLlBhaXJpbmdSZXNwb25zZVIPcGFpcmluZ1Jlc3BvbnNlElAKEWV4dGVuc2lvbl9tZXNzYWdlGAkgASgLMiMucmVtb3RpbmcucHJvdG9jb2wuRXh0ZW5zaW9uTWVzc2FnZVIQZXh0ZW5zaW9uTWVzc2FnZRJBCgx2aWRlb19sYXlvdXQYCiABKAsyHi5yZW1vdGluZy5wcm90b2NvbC5WaWRlb0xheW91dFILdmlkZW9MYXlvdXQSVQoOc2VsZWN0X2Rpc3BsYXkYCyABKAsyLi5yZW1vdGluZy5wcm90b2NvbC5TZWxlY3REZXNrdG9wRGlzcGxheVJlcXVlc3RSDXNlbGVjdERpc3BsYXkSSgoPa2V5Ym9hcmRfbGF5b3V0GAwgASgLMiEucmVtb3RpbmcucHJvdG9jb2wuS2V5Ym9hcmRMYXlvdXRSDmtleWJvYXJkTGF5b3V0EkcKDnRyYW5zcG9ydF9pbmZvGA0gASgLMiAucmVtb3RpbmcucHJvdG9jb2wuVHJhbnNwb3J0SW5mb1INdHJhbnNwb3J0SW5mbxJpChpwZWVyX2Nvbm5lY3Rpb25fcGFyYW1ldGVycxgOIAEoCzIrLnJlbW90aW5nLnByb3RvY29sLlBlZXJDb25uZWN0aW9uUGFyYW1ldGVyc1IYcGVlckNvbm5lY3Rpb25QYXJhbWV0ZXJz');
@$core.Deprecated('Use eventMessageDescriptor instead')
const EventMessage$json = const {
  '1': 'EventMessage',
  '2': const [
    const {'1': 'timestamp', '3': 1, '4': 1, '5': 3, '10': 'timestamp'},
    const {'1': 'key_event', '3': 3, '4': 1, '5': 11, '6': '.remoting.protocol.KeyEvent', '10': 'keyEvent'},
    const {'1': 'mouse_event', '3': 4, '4': 1, '5': 11, '6': '.remoting.protocol.MouseEvent', '10': 'mouseEvent'},
    const {'1': 'text_event', '3': 5, '4': 1, '5': 11, '6': '.remoting.protocol.TextEvent', '10': 'textEvent'},
    const {'1': 'touch_event', '3': 6, '4': 1, '5': 11, '6': '.remoting.protocol.TouchEvent', '10': 'touchEvent'},
  ],
};

/// Descriptor for `EventMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eventMessageDescriptor = $convert.base64Decode('CgxFdmVudE1lc3NhZ2USHAoJdGltZXN0YW1wGAEgASgDUgl0aW1lc3RhbXASOAoJa2V5X2V2ZW50GAMgASgLMhsucmVtb3RpbmcucHJvdG9jb2wuS2V5RXZlbnRSCGtleUV2ZW50Ej4KC21vdXNlX2V2ZW50GAQgASgLMh0ucmVtb3RpbmcucHJvdG9jb2wuTW91c2VFdmVudFIKbW91c2VFdmVudBI7Cgp0ZXh0X2V2ZW50GAUgASgLMhwucmVtb3RpbmcucHJvdG9jb2wuVGV4dEV2ZW50Ugl0ZXh0RXZlbnQSPgoLdG91Y2hfZXZlbnQYBiABKAsyHS5yZW1vdGluZy5wcm90b2NvbC5Ub3VjaEV2ZW50Ugp0b3VjaEV2ZW50');
