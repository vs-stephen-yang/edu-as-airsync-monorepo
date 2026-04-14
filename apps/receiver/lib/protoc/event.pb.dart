///
//  Generated code. Do not modify.
//  source: event.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'event.pbenum.dart';

export 'event.pbenum.dart';

class KeyEvent extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'KeyEvent', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..aOB(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'pressed')
    ..a<$core.int>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'usbKeycode', $pb.PbFieldType.OU3)
    ..a<$core.int>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'lockStates', $pb.PbFieldType.OU3)
    ..aOB(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'capsLockState')
    ..aOB(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'numLockState')
    ..hasRequiredFields = false
  ;

  KeyEvent._() : super();
  factory KeyEvent({
    $core.bool? pressed,
    $core.int? usbKeycode,
    $core.int? lockStates,
    $core.bool? capsLockState,
    $core.bool? numLockState,
  }) {
    final _result = create();
    if (pressed != null) {
      _result.pressed = pressed;
    }
    if (usbKeycode != null) {
      _result.usbKeycode = usbKeycode;
    }
    if (lockStates != null) {
      _result.lockStates = lockStates;
    }
    if (capsLockState != null) {
      _result.capsLockState = capsLockState;
    }
    if (numLockState != null) {
      _result.numLockState = numLockState;
    }
    return _result;
  }
  factory KeyEvent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KeyEvent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  KeyEvent clone() => KeyEvent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  KeyEvent copyWith(void Function(KeyEvent) updates) => super.copyWith((message) => updates(message as KeyEvent)) as KeyEvent; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static KeyEvent create() => KeyEvent._();
  KeyEvent createEmptyInstance() => create();
  static $pb.PbList<KeyEvent> createRepeated() => $pb.PbList<KeyEvent>();
  @$core.pragma('dart2js:noInline')
  static KeyEvent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KeyEvent>(create);
  static KeyEvent? _defaultInstance;

  @$pb.TagNumber(2)
  $core.bool get pressed => $_getBF(0);
  @$pb.TagNumber(2)
  set pressed($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(2)
  $core.bool hasPressed() => $_has(0);
  @$pb.TagNumber(2)
  void clearPressed() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get usbKeycode => $_getIZ(1);
  @$pb.TagNumber(3)
  set usbKeycode($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(3)
  $core.bool hasUsbKeycode() => $_has(1);
  @$pb.TagNumber(3)
  void clearUsbKeycode() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get lockStates => $_getIZ(2);
  @$pb.TagNumber(4)
  set lockStates($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(4)
  $core.bool hasLockStates() => $_has(2);
  @$pb.TagNumber(4)
  void clearLockStates() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get capsLockState => $_getBF(3);
  @$pb.TagNumber(5)
  set capsLockState($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(5)
  $core.bool hasCapsLockState() => $_has(3);
  @$pb.TagNumber(5)
  void clearCapsLockState() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get numLockState => $_getBF(4);
  @$pb.TagNumber(6)
  set numLockState($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(6)
  $core.bool hasNumLockState() => $_has(4);
  @$pb.TagNumber(6)
  void clearNumLockState() => clearField(6);
}

class TextEvent extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'TextEvent', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'text')
    ..hasRequiredFields = false
  ;

  TextEvent._() : super();
  factory TextEvent({
    $core.String? text,
  }) {
    final _result = create();
    if (text != null) {
      _result.text = text;
    }
    return _result;
  }
  factory TextEvent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TextEvent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TextEvent clone() => TextEvent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TextEvent copyWith(void Function(TextEvent) updates) => super.copyWith((message) => updates(message as TextEvent)) as TextEvent; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TextEvent create() => TextEvent._();
  TextEvent createEmptyInstance() => create();
  static $pb.PbList<TextEvent> createRepeated() => $pb.PbList<TextEvent>();
  @$core.pragma('dart2js:noInline')
  static TextEvent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TextEvent>(create);
  static TextEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => clearField(1);
}

class FractionalCoordinate extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'FractionalCoordinate', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..a<$core.double>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'x', $pb.PbFieldType.OF)
    ..a<$core.double>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'y', $pb.PbFieldType.OF)
    ..aInt64(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'screenId')
    ..hasRequiredFields = false
  ;

  FractionalCoordinate._() : super();
  factory FractionalCoordinate({
    $core.double? x,
    $core.double? y,
    $fixnum.Int64? screenId,
  }) {
    final _result = create();
    if (x != null) {
      _result.x = x;
    }
    if (y != null) {
      _result.y = y;
    }
    if (screenId != null) {
      _result.screenId = screenId;
    }
    return _result;
  }
  factory FractionalCoordinate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FractionalCoordinate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FractionalCoordinate clone() => FractionalCoordinate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FractionalCoordinate copyWith(void Function(FractionalCoordinate) updates) => super.copyWith((message) => updates(message as FractionalCoordinate)) as FractionalCoordinate; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static FractionalCoordinate create() => FractionalCoordinate._();
  FractionalCoordinate createEmptyInstance() => create();
  static $pb.PbList<FractionalCoordinate> createRepeated() => $pb.PbList<FractionalCoordinate>();
  @$core.pragma('dart2js:noInline')
  static FractionalCoordinate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FractionalCoordinate>(create);
  static FractionalCoordinate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get x => $_getN(0);
  @$pb.TagNumber(1)
  set x($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get y => $_getN(1);
  @$pb.TagNumber(2)
  set y($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasY() => $_has(1);
  @$pb.TagNumber(2)
  void clearY() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get screenId => $_getI64(2);
  @$pb.TagNumber(3)
  set screenId($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasScreenId() => $_has(2);
  @$pb.TagNumber(3)
  void clearScreenId() => clearField(3);
}

class MouseEvent extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MouseEvent', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'x', $pb.PbFieldType.O3)
    ..a<$core.int>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'y', $pb.PbFieldType.O3)
    ..e<MouseEvent_MouseButton>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'button', $pb.PbFieldType.OE, defaultOrMaker: MouseEvent_MouseButton.BUTTON_UNDEFINED, valueOf: MouseEvent_MouseButton.valueOf, enumValues: MouseEvent_MouseButton.values)
    ..aOB(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'buttonDown')
    ..a<$core.double>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'wheelDeltaX', $pb.PbFieldType.OF)
    ..a<$core.double>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'wheelDeltaY', $pb.PbFieldType.OF)
    ..a<$core.double>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'wheelTicksX', $pb.PbFieldType.OF)
    ..a<$core.double>(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'wheelTicksY', $pb.PbFieldType.OF)
    ..a<$core.int>(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'deltaX', $pb.PbFieldType.O3)
    ..a<$core.int>(12, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'deltaY', $pb.PbFieldType.O3)
    ..aOM<FractionalCoordinate>(13, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fractionalCoordinate', subBuilder: FractionalCoordinate.create)
    ..hasRequiredFields = false
  ;

  MouseEvent._() : super();
  factory MouseEvent({
    $core.int? x,
    $core.int? y,
    MouseEvent_MouseButton? button,
    $core.bool? buttonDown,
    $core.double? wheelDeltaX,
    $core.double? wheelDeltaY,
    $core.double? wheelTicksX,
    $core.double? wheelTicksY,
    $core.int? deltaX,
    $core.int? deltaY,
    FractionalCoordinate? fractionalCoordinate,
  }) {
    final _result = create();
    if (x != null) {
      _result.x = x;
    }
    if (y != null) {
      _result.y = y;
    }
    if (button != null) {
      _result.button = button;
    }
    if (buttonDown != null) {
      _result.buttonDown = buttonDown;
    }
    if (wheelDeltaX != null) {
      _result.wheelDeltaX = wheelDeltaX;
    }
    if (wheelDeltaY != null) {
      _result.wheelDeltaY = wheelDeltaY;
    }
    if (wheelTicksX != null) {
      _result.wheelTicksX = wheelTicksX;
    }
    if (wheelTicksY != null) {
      _result.wheelTicksY = wheelTicksY;
    }
    if (deltaX != null) {
      _result.deltaX = deltaX;
    }
    if (deltaY != null) {
      _result.deltaY = deltaY;
    }
    if (fractionalCoordinate != null) {
      _result.fractionalCoordinate = fractionalCoordinate;
    }
    return _result;
  }
  factory MouseEvent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MouseEvent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MouseEvent clone() => MouseEvent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MouseEvent copyWith(void Function(MouseEvent) updates) => super.copyWith((message) => updates(message as MouseEvent)) as MouseEvent; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MouseEvent create() => MouseEvent._();
  MouseEvent createEmptyInstance() => create();
  static $pb.PbList<MouseEvent> createRepeated() => $pb.PbList<MouseEvent>();
  @$core.pragma('dart2js:noInline')
  static MouseEvent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MouseEvent>(create);
  static MouseEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get x => $_getIZ(0);
  @$pb.TagNumber(1)
  set x($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get y => $_getIZ(1);
  @$pb.TagNumber(2)
  set y($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasY() => $_has(1);
  @$pb.TagNumber(2)
  void clearY() => clearField(2);

  @$pb.TagNumber(5)
  MouseEvent_MouseButton get button => $_getN(2);
  @$pb.TagNumber(5)
  set button(MouseEvent_MouseButton v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasButton() => $_has(2);
  @$pb.TagNumber(5)
  void clearButton() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get buttonDown => $_getBF(3);
  @$pb.TagNumber(6)
  set buttonDown($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(6)
  $core.bool hasButtonDown() => $_has(3);
  @$pb.TagNumber(6)
  void clearButtonDown() => clearField(6);

  @$pb.TagNumber(7)
  $core.double get wheelDeltaX => $_getN(4);
  @$pb.TagNumber(7)
  set wheelDeltaX($core.double v) { $_setFloat(4, v); }
  @$pb.TagNumber(7)
  $core.bool hasWheelDeltaX() => $_has(4);
  @$pb.TagNumber(7)
  void clearWheelDeltaX() => clearField(7);

  @$pb.TagNumber(8)
  $core.double get wheelDeltaY => $_getN(5);
  @$pb.TagNumber(8)
  set wheelDeltaY($core.double v) { $_setFloat(5, v); }
  @$pb.TagNumber(8)
  $core.bool hasWheelDeltaY() => $_has(5);
  @$pb.TagNumber(8)
  void clearWheelDeltaY() => clearField(8);

  @$pb.TagNumber(9)
  $core.double get wheelTicksX => $_getN(6);
  @$pb.TagNumber(9)
  set wheelTicksX($core.double v) { $_setFloat(6, v); }
  @$pb.TagNumber(9)
  $core.bool hasWheelTicksX() => $_has(6);
  @$pb.TagNumber(9)
  void clearWheelTicksX() => clearField(9);

  @$pb.TagNumber(10)
  $core.double get wheelTicksY => $_getN(7);
  @$pb.TagNumber(10)
  set wheelTicksY($core.double v) { $_setFloat(7, v); }
  @$pb.TagNumber(10)
  $core.bool hasWheelTicksY() => $_has(7);
  @$pb.TagNumber(10)
  void clearWheelTicksY() => clearField(10);

  @$pb.TagNumber(11)
  $core.int get deltaX => $_getIZ(8);
  @$pb.TagNumber(11)
  set deltaX($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(11)
  $core.bool hasDeltaX() => $_has(8);
  @$pb.TagNumber(11)
  void clearDeltaX() => clearField(11);

  @$pb.TagNumber(12)
  $core.int get deltaY => $_getIZ(9);
  @$pb.TagNumber(12)
  set deltaY($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(12)
  $core.bool hasDeltaY() => $_has(9);
  @$pb.TagNumber(12)
  void clearDeltaY() => clearField(12);

  @$pb.TagNumber(13)
  FractionalCoordinate get fractionalCoordinate => $_getN(10);
  @$pb.TagNumber(13)
  set fractionalCoordinate(FractionalCoordinate v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasFractionalCoordinate() => $_has(10);
  @$pb.TagNumber(13)
  void clearFractionalCoordinate() => clearField(13);
  @$pb.TagNumber(13)
  FractionalCoordinate ensureFractionalCoordinate() => $_ensure(10);
}

class ClipboardEvent extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ClipboardEvent', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'mimeType')
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  ClipboardEvent._() : super();
  factory ClipboardEvent({
    $core.String? mimeType,
    $core.List<$core.int>? data,
  }) {
    final _result = create();
    if (mimeType != null) {
      _result.mimeType = mimeType;
    }
    if (data != null) {
      _result.data = data;
    }
    return _result;
  }
  factory ClipboardEvent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClipboardEvent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClipboardEvent clone() => ClipboardEvent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClipboardEvent copyWith(void Function(ClipboardEvent) updates) => super.copyWith((message) => updates(message as ClipboardEvent)) as ClipboardEvent; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ClipboardEvent create() => ClipboardEvent._();
  ClipboardEvent createEmptyInstance() => create();
  static $pb.PbList<ClipboardEvent> createRepeated() => $pb.PbList<ClipboardEvent>();
  @$core.pragma('dart2js:noInline')
  static ClipboardEvent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClipboardEvent>(create);
  static ClipboardEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mimeType => $_getSZ(0);
  @$pb.TagNumber(1)
  set mimeType($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMimeType() => $_has(0);
  @$pb.TagNumber(1)
  void clearMimeType() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
}

class TouchEventPoint extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'TouchEventPoint', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id', $pb.PbFieldType.OU3)
    ..a<$core.double>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'x', $pb.PbFieldType.OF)
    ..a<$core.double>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'y', $pb.PbFieldType.OF)
    ..a<$core.double>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'radiusX', $pb.PbFieldType.OF)
    ..a<$core.double>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'radiusY', $pb.PbFieldType.OF)
    ..a<$core.double>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'angle', $pb.PbFieldType.OF)
    ..a<$core.double>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'pressure', $pb.PbFieldType.OF)
    ..aOM<FractionalCoordinate>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fractionalCoordinate', subBuilder: FractionalCoordinate.create)
    ..hasRequiredFields = false
  ;

  TouchEventPoint._() : super();
  factory TouchEventPoint({
    $core.int? id,
    $core.double? x,
    $core.double? y,
    $core.double? radiusX,
    $core.double? radiusY,
    $core.double? angle,
    $core.double? pressure,
    FractionalCoordinate? fractionalCoordinate,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (x != null) {
      _result.x = x;
    }
    if (y != null) {
      _result.y = y;
    }
    if (radiusX != null) {
      _result.radiusX = radiusX;
    }
    if (radiusY != null) {
      _result.radiusY = radiusY;
    }
    if (angle != null) {
      _result.angle = angle;
    }
    if (pressure != null) {
      _result.pressure = pressure;
    }
    if (fractionalCoordinate != null) {
      _result.fractionalCoordinate = fractionalCoordinate;
    }
    return _result;
  }
  factory TouchEventPoint.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TouchEventPoint.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TouchEventPoint clone() => TouchEventPoint()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TouchEventPoint copyWith(void Function(TouchEventPoint) updates) => super.copyWith((message) => updates(message as TouchEventPoint)) as TouchEventPoint; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TouchEventPoint create() => TouchEventPoint._();
  TouchEventPoint createEmptyInstance() => create();
  static $pb.PbList<TouchEventPoint> createRepeated() => $pb.PbList<TouchEventPoint>();
  @$core.pragma('dart2js:noInline')
  static TouchEventPoint getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TouchEventPoint>(create);
  static TouchEventPoint? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get x => $_getN(1);
  @$pb.TagNumber(2)
  set x($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasX() => $_has(1);
  @$pb.TagNumber(2)
  void clearX() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get y => $_getN(2);
  @$pb.TagNumber(3)
  set y($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasY() => $_has(2);
  @$pb.TagNumber(3)
  void clearY() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get radiusX => $_getN(3);
  @$pb.TagNumber(4)
  set radiusX($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRadiusX() => $_has(3);
  @$pb.TagNumber(4)
  void clearRadiusX() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get radiusY => $_getN(4);
  @$pb.TagNumber(5)
  set radiusY($core.double v) { $_setFloat(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasRadiusY() => $_has(4);
  @$pb.TagNumber(5)
  void clearRadiusY() => clearField(5);

  @$pb.TagNumber(6)
  $core.double get angle => $_getN(5);
  @$pb.TagNumber(6)
  set angle($core.double v) { $_setFloat(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAngle() => $_has(5);
  @$pb.TagNumber(6)
  void clearAngle() => clearField(6);

  @$pb.TagNumber(7)
  $core.double get pressure => $_getN(6);
  @$pb.TagNumber(7)
  set pressure($core.double v) { $_setFloat(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasPressure() => $_has(6);
  @$pb.TagNumber(7)
  void clearPressure() => clearField(7);

  @$pb.TagNumber(8)
  FractionalCoordinate get fractionalCoordinate => $_getN(7);
  @$pb.TagNumber(8)
  set fractionalCoordinate(FractionalCoordinate v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasFractionalCoordinate() => $_has(7);
  @$pb.TagNumber(8)
  void clearFractionalCoordinate() => clearField(8);
  @$pb.TagNumber(8)
  FractionalCoordinate ensureFractionalCoordinate() => $_ensure(7);
}

class TouchEvent extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'TouchEvent', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..e<TouchEvent_TouchEventType>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'eventType', $pb.PbFieldType.OE, defaultOrMaker: TouchEvent_TouchEventType.TOUCH_POINT_UNDEFINED, valueOf: TouchEvent_TouchEventType.valueOf, enumValues: TouchEvent_TouchEventType.values)
    ..pc<TouchEventPoint>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'touchPoints', $pb.PbFieldType.PM, subBuilder: TouchEventPoint.create)
    ..hasRequiredFields = false
  ;

  TouchEvent._() : super();
  factory TouchEvent({
    TouchEvent_TouchEventType? eventType,
    $core.Iterable<TouchEventPoint>? touchPoints,
  }) {
    final _result = create();
    if (eventType != null) {
      _result.eventType = eventType;
    }
    if (touchPoints != null) {
      _result.touchPoints.addAll(touchPoints);
    }
    return _result;
  }
  factory TouchEvent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TouchEvent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TouchEvent clone() => TouchEvent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TouchEvent copyWith(void Function(TouchEvent) updates) => super.copyWith((message) => updates(message as TouchEvent)) as TouchEvent; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TouchEvent create() => TouchEvent._();
  TouchEvent createEmptyInstance() => create();
  static $pb.PbList<TouchEvent> createRepeated() => $pb.PbList<TouchEvent>();
  @$core.pragma('dart2js:noInline')
  static TouchEvent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TouchEvent>(create);
  static TouchEvent? _defaultInstance;

  @$pb.TagNumber(1)
  TouchEvent_TouchEventType get eventType => $_getN(0);
  @$pb.TagNumber(1)
  set eventType(TouchEvent_TouchEventType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasEventType() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventType() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<TouchEventPoint> get touchPoints => $_getList(1);
}

