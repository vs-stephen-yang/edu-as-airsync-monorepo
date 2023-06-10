///
//  Generated code. Do not modify.
//  source: internal.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'event.pb.dart' as $1;
import 'control.pb.dart' as $2;

class ControlMessage extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ControlMessage', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..aOM<$1.ClipboardEvent>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'clipboardEvent', subBuilder: $1.ClipboardEvent.create)
    ..aOM<$2.ClientResolution>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'clientResolution', subBuilder: $2.ClientResolution.create)
    ..aOM<$2.VideoControl>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'videoControl', subBuilder: $2.VideoControl.create)
    ..aOM<$2.CursorShapeInfo>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'cursorShape', subBuilder: $2.CursorShapeInfo.create)
    ..aOM<$2.AudioControl>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'audioControl', subBuilder: $2.AudioControl.create)
    ..aOM<$2.Capabilities>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'capabilities', subBuilder: $2.Capabilities.create)
    ..aOM<$2.PairingRequest>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'pairingRequest', subBuilder: $2.PairingRequest.create)
    ..aOM<$2.PairingResponse>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'pairingResponse', subBuilder: $2.PairingResponse.create)
    ..aOM<$2.ExtensionMessage>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'extensionMessage', subBuilder: $2.ExtensionMessage.create)
    ..aOM<$2.VideoLayout>(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'videoLayout', subBuilder: $2.VideoLayout.create)
    ..aOM<$2.SelectDesktopDisplayRequest>(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'selectDisplay', subBuilder: $2.SelectDesktopDisplayRequest.create)
    ..aOM<$2.KeyboardLayout>(12, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'keyboardLayout', subBuilder: $2.KeyboardLayout.create)
    ..aOM<$2.TransportInfo>(13, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'transportInfo', subBuilder: $2.TransportInfo.create)
    ..aOM<$2.PeerConnectionParameters>(14, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'peerConnectionParameters', subBuilder: $2.PeerConnectionParameters.create)
    ..hasRequiredFields = false
  ;

  ControlMessage._() : super();
  factory ControlMessage({
    $1.ClipboardEvent? clipboardEvent,
    $2.ClientResolution? clientResolution,
    $2.VideoControl? videoControl,
    $2.CursorShapeInfo? cursorShape,
    $2.AudioControl? audioControl,
    $2.Capabilities? capabilities,
    $2.PairingRequest? pairingRequest,
    $2.PairingResponse? pairingResponse,
    $2.ExtensionMessage? extensionMessage,
    $2.VideoLayout? videoLayout,
    $2.SelectDesktopDisplayRequest? selectDisplay,
    $2.KeyboardLayout? keyboardLayout,
    $2.TransportInfo? transportInfo,
    $2.PeerConnectionParameters? peerConnectionParameters,
  }) {
    final _result = create();
    if (clipboardEvent != null) {
      _result.clipboardEvent = clipboardEvent;
    }
    if (clientResolution != null) {
      _result.clientResolution = clientResolution;
    }
    if (videoControl != null) {
      _result.videoControl = videoControl;
    }
    if (cursorShape != null) {
      _result.cursorShape = cursorShape;
    }
    if (audioControl != null) {
      _result.audioControl = audioControl;
    }
    if (capabilities != null) {
      _result.capabilities = capabilities;
    }
    if (pairingRequest != null) {
      _result.pairingRequest = pairingRequest;
    }
    if (pairingResponse != null) {
      _result.pairingResponse = pairingResponse;
    }
    if (extensionMessage != null) {
      _result.extensionMessage = extensionMessage;
    }
    if (videoLayout != null) {
      _result.videoLayout = videoLayout;
    }
    if (selectDisplay != null) {
      _result.selectDisplay = selectDisplay;
    }
    if (keyboardLayout != null) {
      _result.keyboardLayout = keyboardLayout;
    }
    if (transportInfo != null) {
      _result.transportInfo = transportInfo;
    }
    if (peerConnectionParameters != null) {
      _result.peerConnectionParameters = peerConnectionParameters;
    }
    return _result;
  }
  factory ControlMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ControlMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ControlMessage clone() => ControlMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ControlMessage copyWith(void Function(ControlMessage) updates) => super.copyWith((message) => updates(message as ControlMessage)) as ControlMessage; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ControlMessage create() => ControlMessage._();
  ControlMessage createEmptyInstance() => create();
  static $pb.PbList<ControlMessage> createRepeated() => $pb.PbList<ControlMessage>();
  @$core.pragma('dart2js:noInline')
  static ControlMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ControlMessage>(create);
  static ControlMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ClipboardEvent get clipboardEvent => $_getN(0);
  @$pb.TagNumber(1)
  set clipboardEvent($1.ClipboardEvent v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasClipboardEvent() => $_has(0);
  @$pb.TagNumber(1)
  void clearClipboardEvent() => clearField(1);
  @$pb.TagNumber(1)
  $1.ClipboardEvent ensureClipboardEvent() => $_ensure(0);

  @$pb.TagNumber(2)
  $2.ClientResolution get clientResolution => $_getN(1);
  @$pb.TagNumber(2)
  set clientResolution($2.ClientResolution v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasClientResolution() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientResolution() => clearField(2);
  @$pb.TagNumber(2)
  $2.ClientResolution ensureClientResolution() => $_ensure(1);

  @$pb.TagNumber(3)
  $2.VideoControl get videoControl => $_getN(2);
  @$pb.TagNumber(3)
  set videoControl($2.VideoControl v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasVideoControl() => $_has(2);
  @$pb.TagNumber(3)
  void clearVideoControl() => clearField(3);
  @$pb.TagNumber(3)
  $2.VideoControl ensureVideoControl() => $_ensure(2);

  @$pb.TagNumber(4)
  $2.CursorShapeInfo get cursorShape => $_getN(3);
  @$pb.TagNumber(4)
  set cursorShape($2.CursorShapeInfo v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasCursorShape() => $_has(3);
  @$pb.TagNumber(4)
  void clearCursorShape() => clearField(4);
  @$pb.TagNumber(4)
  $2.CursorShapeInfo ensureCursorShape() => $_ensure(3);

  @$pb.TagNumber(5)
  $2.AudioControl get audioControl => $_getN(4);
  @$pb.TagNumber(5)
  set audioControl($2.AudioControl v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasAudioControl() => $_has(4);
  @$pb.TagNumber(5)
  void clearAudioControl() => clearField(5);
  @$pb.TagNumber(5)
  $2.AudioControl ensureAudioControl() => $_ensure(4);

  @$pb.TagNumber(6)
  $2.Capabilities get capabilities => $_getN(5);
  @$pb.TagNumber(6)
  set capabilities($2.Capabilities v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasCapabilities() => $_has(5);
  @$pb.TagNumber(6)
  void clearCapabilities() => clearField(6);
  @$pb.TagNumber(6)
  $2.Capabilities ensureCapabilities() => $_ensure(5);

  @$pb.TagNumber(7)
  $2.PairingRequest get pairingRequest => $_getN(6);
  @$pb.TagNumber(7)
  set pairingRequest($2.PairingRequest v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasPairingRequest() => $_has(6);
  @$pb.TagNumber(7)
  void clearPairingRequest() => clearField(7);
  @$pb.TagNumber(7)
  $2.PairingRequest ensurePairingRequest() => $_ensure(6);

  @$pb.TagNumber(8)
  $2.PairingResponse get pairingResponse => $_getN(7);
  @$pb.TagNumber(8)
  set pairingResponse($2.PairingResponse v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasPairingResponse() => $_has(7);
  @$pb.TagNumber(8)
  void clearPairingResponse() => clearField(8);
  @$pb.TagNumber(8)
  $2.PairingResponse ensurePairingResponse() => $_ensure(7);

  @$pb.TagNumber(9)
  $2.ExtensionMessage get extensionMessage => $_getN(8);
  @$pb.TagNumber(9)
  set extensionMessage($2.ExtensionMessage v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasExtensionMessage() => $_has(8);
  @$pb.TagNumber(9)
  void clearExtensionMessage() => clearField(9);
  @$pb.TagNumber(9)
  $2.ExtensionMessage ensureExtensionMessage() => $_ensure(8);

  @$pb.TagNumber(10)
  $2.VideoLayout get videoLayout => $_getN(9);
  @$pb.TagNumber(10)
  set videoLayout($2.VideoLayout v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasVideoLayout() => $_has(9);
  @$pb.TagNumber(10)
  void clearVideoLayout() => clearField(10);
  @$pb.TagNumber(10)
  $2.VideoLayout ensureVideoLayout() => $_ensure(9);

  @$pb.TagNumber(11)
  $2.SelectDesktopDisplayRequest get selectDisplay => $_getN(10);
  @$pb.TagNumber(11)
  set selectDisplay($2.SelectDesktopDisplayRequest v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasSelectDisplay() => $_has(10);
  @$pb.TagNumber(11)
  void clearSelectDisplay() => clearField(11);
  @$pb.TagNumber(11)
  $2.SelectDesktopDisplayRequest ensureSelectDisplay() => $_ensure(10);

  @$pb.TagNumber(12)
  $2.KeyboardLayout get keyboardLayout => $_getN(11);
  @$pb.TagNumber(12)
  set keyboardLayout($2.KeyboardLayout v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasKeyboardLayout() => $_has(11);
  @$pb.TagNumber(12)
  void clearKeyboardLayout() => clearField(12);
  @$pb.TagNumber(12)
  $2.KeyboardLayout ensureKeyboardLayout() => $_ensure(11);

  @$pb.TagNumber(13)
  $2.TransportInfo get transportInfo => $_getN(12);
  @$pb.TagNumber(13)
  set transportInfo($2.TransportInfo v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasTransportInfo() => $_has(12);
  @$pb.TagNumber(13)
  void clearTransportInfo() => clearField(13);
  @$pb.TagNumber(13)
  $2.TransportInfo ensureTransportInfo() => $_ensure(12);

  @$pb.TagNumber(14)
  $2.PeerConnectionParameters get peerConnectionParameters => $_getN(13);
  @$pb.TagNumber(14)
  set peerConnectionParameters($2.PeerConnectionParameters v) { setField(14, v); }
  @$pb.TagNumber(14)
  $core.bool hasPeerConnectionParameters() => $_has(13);
  @$pb.TagNumber(14)
  void clearPeerConnectionParameters() => clearField(14);
  @$pb.TagNumber(14)
  $2.PeerConnectionParameters ensurePeerConnectionParameters() => $_ensure(13);
}

class EventMessage extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'EventMessage', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..aInt64(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'timestamp')
    ..aOM<$1.KeyEvent>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'keyEvent', subBuilder: $1.KeyEvent.create)
    ..aOM<$1.MouseEvent>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'mouseEvent', subBuilder: $1.MouseEvent.create)
    ..aOM<$1.TextEvent>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'textEvent', subBuilder: $1.TextEvent.create)
    ..aOM<$1.TouchEvent>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'touchEvent', subBuilder: $1.TouchEvent.create)
    ..hasRequiredFields = false
  ;

  EventMessage._() : super();
  factory EventMessage({
    $fixnum.Int64? timestamp,
    $1.KeyEvent? keyEvent,
    $1.MouseEvent? mouseEvent,
    $1.TextEvent? textEvent,
    $1.TouchEvent? touchEvent,
  }) {
    final _result = create();
    if (timestamp != null) {
      _result.timestamp = timestamp;
    }
    if (keyEvent != null) {
      _result.keyEvent = keyEvent;
    }
    if (mouseEvent != null) {
      _result.mouseEvent = mouseEvent;
    }
    if (textEvent != null) {
      _result.textEvent = textEvent;
    }
    if (touchEvent != null) {
      _result.touchEvent = touchEvent;
    }
    return _result;
  }
  factory EventMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EventMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EventMessage clone() => EventMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EventMessage copyWith(void Function(EventMessage) updates) => super.copyWith((message) => updates(message as EventMessage)) as EventMessage; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static EventMessage create() => EventMessage._();
  EventMessage createEmptyInstance() => create();
  static $pb.PbList<EventMessage> createRepeated() => $pb.PbList<EventMessage>();
  @$core.pragma('dart2js:noInline')
  static EventMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EventMessage>(create);
  static EventMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get timestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set timestamp($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => clearField(1);

  @$pb.TagNumber(3)
  $1.KeyEvent get keyEvent => $_getN(1);
  @$pb.TagNumber(3)
  set keyEvent($1.KeyEvent v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasKeyEvent() => $_has(1);
  @$pb.TagNumber(3)
  void clearKeyEvent() => clearField(3);
  @$pb.TagNumber(3)
  $1.KeyEvent ensureKeyEvent() => $_ensure(1);

  @$pb.TagNumber(4)
  $1.MouseEvent get mouseEvent => $_getN(2);
  @$pb.TagNumber(4)
  set mouseEvent($1.MouseEvent v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasMouseEvent() => $_has(2);
  @$pb.TagNumber(4)
  void clearMouseEvent() => clearField(4);
  @$pb.TagNumber(4)
  $1.MouseEvent ensureMouseEvent() => $_ensure(2);

  @$pb.TagNumber(5)
  $1.TextEvent get textEvent => $_getN(3);
  @$pb.TagNumber(5)
  set textEvent($1.TextEvent v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasTextEvent() => $_has(3);
  @$pb.TagNumber(5)
  void clearTextEvent() => clearField(5);
  @$pb.TagNumber(5)
  $1.TextEvent ensureTextEvent() => $_ensure(3);

  @$pb.TagNumber(6)
  $1.TouchEvent get touchEvent => $_getN(4);
  @$pb.TagNumber(6)
  set touchEvent($1.TouchEvent v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasTouchEvent() => $_has(4);
  @$pb.TagNumber(6)
  void clearTouchEvent() => clearField(6);
  @$pb.TagNumber(6)
  $1.TouchEvent ensureTouchEvent() => $_ensure(4);
}

