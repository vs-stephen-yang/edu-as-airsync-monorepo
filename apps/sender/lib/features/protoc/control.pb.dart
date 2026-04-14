///
//  Generated code. Do not modify.
//  source: control.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'layout_key_function.pbenum.dart' as $0;

class ClientResolution extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ClientResolution', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'dipsWidth', $pb.PbFieldType.O3)
    ..a<$core.int>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'dipsHeight', $pb.PbFieldType.O3)
    ..a<$core.int>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'widthDeprecated', $pb.PbFieldType.O3)
    ..a<$core.int>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'heightDeprecated', $pb.PbFieldType.O3)
    ..a<$core.int>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'xDpi', $pb.PbFieldType.O3)
    ..a<$core.int>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'yDpi', $pb.PbFieldType.O3)
    ..aInt64(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'screenId')
    ..hasRequiredFields = false
  ;

  ClientResolution._() : super();
  factory ClientResolution({
    $core.int? dipsWidth,
    $core.int? dipsHeight,
    $core.int? widthDeprecated,
    $core.int? heightDeprecated,
    $core.int? xDpi,
    $core.int? yDpi,
    $fixnum.Int64? screenId,
  }) {
    final _result = create();
    if (dipsWidth != null) {
      _result.dipsWidth = dipsWidth;
    }
    if (dipsHeight != null) {
      _result.dipsHeight = dipsHeight;
    }
    if (widthDeprecated != null) {
      _result.widthDeprecated = widthDeprecated;
    }
    if (heightDeprecated != null) {
      _result.heightDeprecated = heightDeprecated;
    }
    if (xDpi != null) {
      _result.xDpi = xDpi;
    }
    if (yDpi != null) {
      _result.yDpi = yDpi;
    }
    if (screenId != null) {
      _result.screenId = screenId;
    }
    return _result;
  }
  factory ClientResolution.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientResolution.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientResolution clone() => ClientResolution()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientResolution copyWith(void Function(ClientResolution) updates) => super.copyWith((message) => updates(message as ClientResolution)) as ClientResolution; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ClientResolution create() => ClientResolution._();
  ClientResolution createEmptyInstance() => create();
  static $pb.PbList<ClientResolution> createRepeated() => $pb.PbList<ClientResolution>();
  @$core.pragma('dart2js:noInline')
  static ClientResolution getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientResolution>(create);
  static ClientResolution? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get dipsWidth => $_getIZ(0);
  @$pb.TagNumber(1)
  set dipsWidth($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDipsWidth() => $_has(0);
  @$pb.TagNumber(1)
  void clearDipsWidth() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get dipsHeight => $_getIZ(1);
  @$pb.TagNumber(2)
  set dipsHeight($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDipsHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearDipsHeight() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get widthDeprecated => $_getIZ(2);
  @$pb.TagNumber(3)
  set widthDeprecated($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWidthDeprecated() => $_has(2);
  @$pb.TagNumber(3)
  void clearWidthDeprecated() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get heightDeprecated => $_getIZ(3);
  @$pb.TagNumber(4)
  set heightDeprecated($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasHeightDeprecated() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeightDeprecated() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get xDpi => $_getIZ(4);
  @$pb.TagNumber(5)
  set xDpi($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasXDpi() => $_has(4);
  @$pb.TagNumber(5)
  void clearXDpi() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get yDpi => $_getIZ(5);
  @$pb.TagNumber(6)
  set yDpi($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasYDpi() => $_has(5);
  @$pb.TagNumber(6)
  void clearYDpi() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get screenId => $_getI64(6);
  @$pb.TagNumber(7)
  set screenId($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasScreenId() => $_has(6);
  @$pb.TagNumber(7)
  void clearScreenId() => clearField(7);
}

class VideoControl_FramerateBoost extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'VideoControl.FramerateBoost', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'enabled')
    ..a<$core.int>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'captureIntervalMs', $pb.PbFieldType.O3)
    ..a<$core.int>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'boostDurationMs', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  VideoControl_FramerateBoost._() : super();
  factory VideoControl_FramerateBoost({
    $core.bool? enabled,
    $core.int? captureIntervalMs,
    $core.int? boostDurationMs,
  }) {
    final _result = create();
    if (enabled != null) {
      _result.enabled = enabled;
    }
    if (captureIntervalMs != null) {
      _result.captureIntervalMs = captureIntervalMs;
    }
    if (boostDurationMs != null) {
      _result.boostDurationMs = boostDurationMs;
    }
    return _result;
  }
  factory VideoControl_FramerateBoost.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VideoControl_FramerateBoost.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VideoControl_FramerateBoost clone() => VideoControl_FramerateBoost()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VideoControl_FramerateBoost copyWith(void Function(VideoControl_FramerateBoost) updates) => super.copyWith((message) => updates(message as VideoControl_FramerateBoost)) as VideoControl_FramerateBoost; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static VideoControl_FramerateBoost create() => VideoControl_FramerateBoost._();
  VideoControl_FramerateBoost createEmptyInstance() => create();
  static $pb.PbList<VideoControl_FramerateBoost> createRepeated() => $pb.PbList<VideoControl_FramerateBoost>();
  @$core.pragma('dart2js:noInline')
  static VideoControl_FramerateBoost getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VideoControl_FramerateBoost>(create);
  static VideoControl_FramerateBoost? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get captureIntervalMs => $_getIZ(1);
  @$pb.TagNumber(2)
  set captureIntervalMs($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCaptureIntervalMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearCaptureIntervalMs() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get boostDurationMs => $_getIZ(2);
  @$pb.TagNumber(3)
  set boostDurationMs($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBoostDurationMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearBoostDurationMs() => clearField(3);
}

class VideoControl extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'VideoControl', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'enable')
    ..aOM<VideoControl_FramerateBoost>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'framerateBoost', subBuilder: VideoControl_FramerateBoost.create)
    ..a<$core.int>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'targetFramerate', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  VideoControl._() : super();
  factory VideoControl({
    $core.bool? enable,
    VideoControl_FramerateBoost? framerateBoost,
    $core.int? targetFramerate,
  }) {
    final _result = create();
    if (enable != null) {
      _result.enable = enable;
    }
    if (framerateBoost != null) {
      _result.framerateBoost = framerateBoost;
    }
    if (targetFramerate != null) {
      _result.targetFramerate = targetFramerate;
    }
    return _result;
  }
  factory VideoControl.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VideoControl.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VideoControl clone() => VideoControl()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VideoControl copyWith(void Function(VideoControl) updates) => super.copyWith((message) => updates(message as VideoControl)) as VideoControl; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static VideoControl create() => VideoControl._();
  VideoControl createEmptyInstance() => create();
  static $pb.PbList<VideoControl> createRepeated() => $pb.PbList<VideoControl>();
  @$core.pragma('dart2js:noInline')
  static VideoControl getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VideoControl>(create);
  static VideoControl? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enable => $_getBF(0);
  @$pb.TagNumber(1)
  set enable($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEnable() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnable() => clearField(1);

  @$pb.TagNumber(4)
  VideoControl_FramerateBoost get framerateBoost => $_getN(1);
  @$pb.TagNumber(4)
  set framerateBoost(VideoControl_FramerateBoost v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasFramerateBoost() => $_has(1);
  @$pb.TagNumber(4)
  void clearFramerateBoost() => clearField(4);
  @$pb.TagNumber(4)
  VideoControl_FramerateBoost ensureFramerateBoost() => $_ensure(1);

  @$pb.TagNumber(5)
  $core.int get targetFramerate => $_getIZ(2);
  @$pb.TagNumber(5)
  set targetFramerate($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(5)
  $core.bool hasTargetFramerate() => $_has(2);
  @$pb.TagNumber(5)
  void clearTargetFramerate() => clearField(5);
}

class AudioControl extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'AudioControl', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'enable')
    ..hasRequiredFields = false
  ;

  AudioControl._() : super();
  factory AudioControl({
    $core.bool? enable,
  }) {
    final _result = create();
    if (enable != null) {
      _result.enable = enable;
    }
    return _result;
  }
  factory AudioControl.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AudioControl.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AudioControl clone() => AudioControl()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AudioControl copyWith(void Function(AudioControl) updates) => super.copyWith((message) => updates(message as AudioControl)) as AudioControl; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AudioControl create() => AudioControl._();
  AudioControl createEmptyInstance() => create();
  static $pb.PbList<AudioControl> createRepeated() => $pb.PbList<AudioControl>();
  @$core.pragma('dart2js:noInline')
  static AudioControl getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AudioControl>(create);
  static AudioControl? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enable => $_getBF(0);
  @$pb.TagNumber(1)
  set enable($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEnable() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnable() => clearField(1);
}

class CursorShapeInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'CursorShapeInfo', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'width', $pb.PbFieldType.O3)
    ..a<$core.int>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'height', $pb.PbFieldType.O3)
    ..a<$core.int>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'hotspotX', $pb.PbFieldType.O3)
    ..a<$core.int>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'hotspotY', $pb.PbFieldType.O3)
    ..a<$core.List<$core.int>>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  CursorShapeInfo._() : super();
  factory CursorShapeInfo({
    $core.int? width,
    $core.int? height,
    $core.int? hotspotX,
    $core.int? hotspotY,
    $core.List<$core.int>? data,
  }) {
    final _result = create();
    if (width != null) {
      _result.width = width;
    }
    if (height != null) {
      _result.height = height;
    }
    if (hotspotX != null) {
      _result.hotspotX = hotspotX;
    }
    if (hotspotY != null) {
      _result.hotspotY = hotspotY;
    }
    if (data != null) {
      _result.data = data;
    }
    return _result;
  }
  factory CursorShapeInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CursorShapeInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CursorShapeInfo clone() => CursorShapeInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CursorShapeInfo copyWith(void Function(CursorShapeInfo) updates) => super.copyWith((message) => updates(message as CursorShapeInfo)) as CursorShapeInfo; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CursorShapeInfo create() => CursorShapeInfo._();
  CursorShapeInfo createEmptyInstance() => create();
  static $pb.PbList<CursorShapeInfo> createRepeated() => $pb.PbList<CursorShapeInfo>();
  @$core.pragma('dart2js:noInline')
  static CursorShapeInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CursorShapeInfo>(create);
  static CursorShapeInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get width => $_getIZ(0);
  @$pb.TagNumber(1)
  set width($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWidth() => $_has(0);
  @$pb.TagNumber(1)
  void clearWidth() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get height => $_getIZ(1);
  @$pb.TagNumber(2)
  set height($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get hotspotX => $_getIZ(2);
  @$pb.TagNumber(3)
  set hotspotX($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHotspotX() => $_has(2);
  @$pb.TagNumber(3)
  void clearHotspotX() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get hotspotY => $_getIZ(3);
  @$pb.TagNumber(4)
  set hotspotY($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasHotspotY() => $_has(3);
  @$pb.TagNumber(4)
  void clearHotspotY() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get data => $_getN(4);
  @$pb.TagNumber(5)
  set data($core.List<$core.int> v) { $_setBytes(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasData() => $_has(4);
  @$pb.TagNumber(5)
  void clearData() => clearField(5);
}

class Capabilities extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Capabilities', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'capabilities')
    ..hasRequiredFields = false
  ;

  Capabilities._() : super();
  factory Capabilities({
    $core.String? capabilities,
  }) {
    final _result = create();
    if (capabilities != null) {
      _result.capabilities = capabilities;
    }
    return _result;
  }
  factory Capabilities.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Capabilities.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Capabilities clone() => Capabilities()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Capabilities copyWith(void Function(Capabilities) updates) => super.copyWith((message) => updates(message as Capabilities)) as Capabilities; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Capabilities create() => Capabilities._();
  Capabilities createEmptyInstance() => create();
  static $pb.PbList<Capabilities> createRepeated() => $pb.PbList<Capabilities>();
  @$core.pragma('dart2js:noInline')
  static Capabilities getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Capabilities>(create);
  static Capabilities? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get capabilities => $_getSZ(0);
  @$pb.TagNumber(1)
  set capabilities($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCapabilities() => $_has(0);
  @$pb.TagNumber(1)
  void clearCapabilities() => clearField(1);
}

class PairingRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'PairingRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'clientName')
    ..hasRequiredFields = false
  ;

  PairingRequest._() : super();
  factory PairingRequest({
    $core.String? clientName,
  }) {
    final _result = create();
    if (clientName != null) {
      _result.clientName = clientName;
    }
    return _result;
  }
  factory PairingRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PairingRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PairingRequest clone() => PairingRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PairingRequest copyWith(void Function(PairingRequest) updates) => super.copyWith((message) => updates(message as PairingRequest)) as PairingRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PairingRequest create() => PairingRequest._();
  PairingRequest createEmptyInstance() => create();
  static $pb.PbList<PairingRequest> createRepeated() => $pb.PbList<PairingRequest>();
  @$core.pragma('dart2js:noInline')
  static PairingRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PairingRequest>(create);
  static PairingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientName => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientName($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasClientName() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientName() => clearField(1);
}

class PairingResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'PairingResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'clientId')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sharedSecret')
    ..hasRequiredFields = false
  ;

  PairingResponse._() : super();
  factory PairingResponse({
    $core.String? clientId,
    $core.String? sharedSecret,
  }) {
    final _result = create();
    if (clientId != null) {
      _result.clientId = clientId;
    }
    if (sharedSecret != null) {
      _result.sharedSecret = sharedSecret;
    }
    return _result;
  }
  factory PairingResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PairingResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PairingResponse clone() => PairingResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PairingResponse copyWith(void Function(PairingResponse) updates) => super.copyWith((message) => updates(message as PairingResponse)) as PairingResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PairingResponse create() => PairingResponse._();
  PairingResponse createEmptyInstance() => create();
  static $pb.PbList<PairingResponse> createRepeated() => $pb.PbList<PairingResponse>();
  @$core.pragma('dart2js:noInline')
  static PairingResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PairingResponse>(create);
  static PairingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get sharedSecret => $_getSZ(1);
  @$pb.TagNumber(2)
  set sharedSecret($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSharedSecret() => $_has(1);
  @$pb.TagNumber(2)
  void clearSharedSecret() => clearField(2);
}

class ExtensionMessage extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ExtensionMessage', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'type')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data')
    ..hasRequiredFields = false
  ;

  ExtensionMessage._() : super();
  factory ExtensionMessage({
    $core.String? type,
    $core.String? data,
  }) {
    final _result = create();
    if (type != null) {
      _result.type = type;
    }
    if (data != null) {
      _result.data = data;
    }
    return _result;
  }
  factory ExtensionMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ExtensionMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ExtensionMessage clone() => ExtensionMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ExtensionMessage copyWith(void Function(ExtensionMessage) updates) => super.copyWith((message) => updates(message as ExtensionMessage)) as ExtensionMessage; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ExtensionMessage create() => ExtensionMessage._();
  ExtensionMessage createEmptyInstance() => create();
  static $pb.PbList<ExtensionMessage> createRepeated() => $pb.PbList<ExtensionMessage>();
  @$core.pragma('dart2js:noInline')
  static ExtensionMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExtensionMessage>(create);
  static ExtensionMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get data => $_getSZ(1);
  @$pb.TagNumber(2)
  set data($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
}

class VideoTrackLayout extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'VideoTrackLayout', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'mediaStreamId')
    ..a<$core.int>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'positionX', $pb.PbFieldType.O3)
    ..a<$core.int>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'positionY', $pb.PbFieldType.O3)
    ..a<$core.int>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'width', $pb.PbFieldType.O3)
    ..a<$core.int>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'height', $pb.PbFieldType.O3)
    ..a<$core.int>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'xDpi', $pb.PbFieldType.O3)
    ..a<$core.int>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'yDpi', $pb.PbFieldType.O3)
    ..aInt64(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'screenId')
    ..hasRequiredFields = false
  ;

  VideoTrackLayout._() : super();
  factory VideoTrackLayout({
    $core.String? mediaStreamId,
    $core.int? positionX,
    $core.int? positionY,
    $core.int? width,
    $core.int? height,
    $core.int? xDpi,
    $core.int? yDpi,
    $fixnum.Int64? screenId,
  }) {
    final _result = create();
    if (mediaStreamId != null) {
      _result.mediaStreamId = mediaStreamId;
    }
    if (positionX != null) {
      _result.positionX = positionX;
    }
    if (positionY != null) {
      _result.positionY = positionY;
    }
    if (width != null) {
      _result.width = width;
    }
    if (height != null) {
      _result.height = height;
    }
    if (xDpi != null) {
      _result.xDpi = xDpi;
    }
    if (yDpi != null) {
      _result.yDpi = yDpi;
    }
    if (screenId != null) {
      _result.screenId = screenId;
    }
    return _result;
  }
  factory VideoTrackLayout.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VideoTrackLayout.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VideoTrackLayout clone() => VideoTrackLayout()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VideoTrackLayout copyWith(void Function(VideoTrackLayout) updates) => super.copyWith((message) => updates(message as VideoTrackLayout)) as VideoTrackLayout; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static VideoTrackLayout create() => VideoTrackLayout._();
  VideoTrackLayout createEmptyInstance() => create();
  static $pb.PbList<VideoTrackLayout> createRepeated() => $pb.PbList<VideoTrackLayout>();
  @$core.pragma('dart2js:noInline')
  static VideoTrackLayout getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VideoTrackLayout>(create);
  static VideoTrackLayout? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mediaStreamId => $_getSZ(0);
  @$pb.TagNumber(1)
  set mediaStreamId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMediaStreamId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMediaStreamId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get positionX => $_getIZ(1);
  @$pb.TagNumber(2)
  set positionX($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPositionX() => $_has(1);
  @$pb.TagNumber(2)
  void clearPositionX() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get positionY => $_getIZ(2);
  @$pb.TagNumber(3)
  set positionY($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPositionY() => $_has(2);
  @$pb.TagNumber(3)
  void clearPositionY() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get width => $_getIZ(3);
  @$pb.TagNumber(4)
  set width($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasWidth() => $_has(3);
  @$pb.TagNumber(4)
  void clearWidth() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get height => $_getIZ(4);
  @$pb.TagNumber(5)
  set height($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearHeight() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get xDpi => $_getIZ(5);
  @$pb.TagNumber(6)
  set xDpi($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasXDpi() => $_has(5);
  @$pb.TagNumber(6)
  void clearXDpi() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get yDpi => $_getIZ(6);
  @$pb.TagNumber(7)
  set yDpi($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasYDpi() => $_has(6);
  @$pb.TagNumber(7)
  void clearYDpi() => clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get screenId => $_getI64(7);
  @$pb.TagNumber(8)
  set screenId($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasScreenId() => $_has(7);
  @$pb.TagNumber(8)
  void clearScreenId() => clearField(8);
}

class VideoLayout extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'VideoLayout', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..pc<VideoTrackLayout>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'videoTrack', $pb.PbFieldType.PM, subBuilder: VideoTrackLayout.create)
    ..aOB(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'supportsFullDesktopCapture')
    ..aInt64(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'primaryScreenId')
    ..hasRequiredFields = false
  ;

  VideoLayout._() : super();
  factory VideoLayout({
    $core.Iterable<VideoTrackLayout>? videoTrack,
    $core.bool? supportsFullDesktopCapture,
    $fixnum.Int64? primaryScreenId,
  }) {
    final _result = create();
    if (videoTrack != null) {
      _result.videoTrack.addAll(videoTrack);
    }
    if (supportsFullDesktopCapture != null) {
      _result.supportsFullDesktopCapture = supportsFullDesktopCapture;
    }
    if (primaryScreenId != null) {
      _result.primaryScreenId = primaryScreenId;
    }
    return _result;
  }
  factory VideoLayout.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VideoLayout.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VideoLayout clone() => VideoLayout()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VideoLayout copyWith(void Function(VideoLayout) updates) => super.copyWith((message) => updates(message as VideoLayout)) as VideoLayout; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static VideoLayout create() => VideoLayout._();
  VideoLayout createEmptyInstance() => create();
  static $pb.PbList<VideoLayout> createRepeated() => $pb.PbList<VideoLayout>();
  @$core.pragma('dart2js:noInline')
  static VideoLayout getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VideoLayout>(create);
  static VideoLayout? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<VideoTrackLayout> get videoTrack => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get supportsFullDesktopCapture => $_getBF(1);
  @$pb.TagNumber(2)
  set supportsFullDesktopCapture($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSupportsFullDesktopCapture() => $_has(1);
  @$pb.TagNumber(2)
  void clearSupportsFullDesktopCapture() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get primaryScreenId => $_getI64(2);
  @$pb.TagNumber(3)
  set primaryScreenId($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPrimaryScreenId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrimaryScreenId() => clearField(3);
}

class SelectDesktopDisplayRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SelectDesktopDisplayRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id')
    ..hasRequiredFields = false
  ;

  SelectDesktopDisplayRequest._() : super();
  factory SelectDesktopDisplayRequest({
    $core.String? id,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    return _result;
  }
  factory SelectDesktopDisplayRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SelectDesktopDisplayRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SelectDesktopDisplayRequest clone() => SelectDesktopDisplayRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SelectDesktopDisplayRequest copyWith(void Function(SelectDesktopDisplayRequest) updates) => super.copyWith((message) => updates(message as SelectDesktopDisplayRequest)) as SelectDesktopDisplayRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SelectDesktopDisplayRequest create() => SelectDesktopDisplayRequest._();
  SelectDesktopDisplayRequest createEmptyInstance() => create();
  static $pb.PbList<SelectDesktopDisplayRequest> createRepeated() => $pb.PbList<SelectDesktopDisplayRequest>();
  @$core.pragma('dart2js:noInline')
  static SelectDesktopDisplayRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SelectDesktopDisplayRequest>(create);
  static SelectDesktopDisplayRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

enum KeyboardLayout_KeyAction_Action {
  function, 
  character, 
  notSet
}

class KeyboardLayout_KeyAction extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, KeyboardLayout_KeyAction_Action> _KeyboardLayout_KeyAction_ActionByTag = {
    1 : KeyboardLayout_KeyAction_Action.function,
    2 : KeyboardLayout_KeyAction_Action.character,
    0 : KeyboardLayout_KeyAction_Action.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'KeyboardLayout.KeyAction', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..e<$0.LayoutKeyFunction>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'function', $pb.PbFieldType.OE, defaultOrMaker: $0.LayoutKeyFunction.UNKNOWN, valueOf: $0.LayoutKeyFunction.valueOf, enumValues: $0.LayoutKeyFunction.values)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'character')
    ..hasRequiredFields = false
  ;

  KeyboardLayout_KeyAction._() : super();
  factory KeyboardLayout_KeyAction({
    $0.LayoutKeyFunction? function,
    $core.String? character,
  }) {
    final _result = create();
    if (function != null) {
      _result.function = function;
    }
    if (character != null) {
      _result.character = character;
    }
    return _result;
  }
  factory KeyboardLayout_KeyAction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KeyboardLayout_KeyAction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  KeyboardLayout_KeyAction clone() => KeyboardLayout_KeyAction()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  KeyboardLayout_KeyAction copyWith(void Function(KeyboardLayout_KeyAction) updates) => super.copyWith((message) => updates(message as KeyboardLayout_KeyAction)) as KeyboardLayout_KeyAction; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static KeyboardLayout_KeyAction create() => KeyboardLayout_KeyAction._();
  KeyboardLayout_KeyAction createEmptyInstance() => create();
  static $pb.PbList<KeyboardLayout_KeyAction> createRepeated() => $pb.PbList<KeyboardLayout_KeyAction>();
  @$core.pragma('dart2js:noInline')
  static KeyboardLayout_KeyAction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KeyboardLayout_KeyAction>(create);
  static KeyboardLayout_KeyAction? _defaultInstance;

  KeyboardLayout_KeyAction_Action whichAction() => _KeyboardLayout_KeyAction_ActionByTag[$_whichOneof(0)]!;
  void clearAction() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $0.LayoutKeyFunction get function => $_getN(0);
  @$pb.TagNumber(1)
  set function($0.LayoutKeyFunction v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasFunction() => $_has(0);
  @$pb.TagNumber(1)
  void clearFunction() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get character => $_getSZ(1);
  @$pb.TagNumber(2)
  set character($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCharacter() => $_has(1);
  @$pb.TagNumber(2)
  void clearCharacter() => clearField(2);
}

class KeyboardLayout_KeyBehavior extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'KeyboardLayout.KeyBehavior', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..m<$core.int, KeyboardLayout_KeyAction>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'actions', entryClassName: 'KeyboardLayout.KeyBehavior.ActionsEntry', keyFieldType: $pb.PbFieldType.OU3, valueFieldType: $pb.PbFieldType.OM, valueCreator: KeyboardLayout_KeyAction.create, packageName: const $pb.PackageName('remoting.protocol'))
    ..hasRequiredFields = false
  ;

  KeyboardLayout_KeyBehavior._() : super();
  factory KeyboardLayout_KeyBehavior({
    $core.Map<$core.int, KeyboardLayout_KeyAction>? actions,
  }) {
    final _result = create();
    if (actions != null) {
      _result.actions.addAll(actions);
    }
    return _result;
  }
  factory KeyboardLayout_KeyBehavior.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KeyboardLayout_KeyBehavior.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  KeyboardLayout_KeyBehavior clone() => KeyboardLayout_KeyBehavior()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  KeyboardLayout_KeyBehavior copyWith(void Function(KeyboardLayout_KeyBehavior) updates) => super.copyWith((message) => updates(message as KeyboardLayout_KeyBehavior)) as KeyboardLayout_KeyBehavior; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static KeyboardLayout_KeyBehavior create() => KeyboardLayout_KeyBehavior._();
  KeyboardLayout_KeyBehavior createEmptyInstance() => create();
  static $pb.PbList<KeyboardLayout_KeyBehavior> createRepeated() => $pb.PbList<KeyboardLayout_KeyBehavior>();
  @$core.pragma('dart2js:noInline')
  static KeyboardLayout_KeyBehavior getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KeyboardLayout_KeyBehavior>(create);
  static KeyboardLayout_KeyBehavior? _defaultInstance;

  @$pb.TagNumber(1)
  $core.Map<$core.int, KeyboardLayout_KeyAction> get actions => $_getMap(0);
}

class KeyboardLayout extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'KeyboardLayout', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..m<$core.int, KeyboardLayout_KeyBehavior>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'keys', entryClassName: 'KeyboardLayout.KeysEntry', keyFieldType: $pb.PbFieldType.OU3, valueFieldType: $pb.PbFieldType.OM, valueCreator: KeyboardLayout_KeyBehavior.create, packageName: const $pb.PackageName('remoting.protocol'))
    ..hasRequiredFields = false
  ;

  KeyboardLayout._() : super();
  factory KeyboardLayout({
    $core.Map<$core.int, KeyboardLayout_KeyBehavior>? keys,
  }) {
    final _result = create();
    if (keys != null) {
      _result.keys.addAll(keys);
    }
    return _result;
  }
  factory KeyboardLayout.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KeyboardLayout.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  KeyboardLayout clone() => KeyboardLayout()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  KeyboardLayout copyWith(void Function(KeyboardLayout) updates) => super.copyWith((message) => updates(message as KeyboardLayout)) as KeyboardLayout; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static KeyboardLayout create() => KeyboardLayout._();
  KeyboardLayout createEmptyInstance() => create();
  static $pb.PbList<KeyboardLayout> createRepeated() => $pb.PbList<KeyboardLayout>();
  @$core.pragma('dart2js:noInline')
  static KeyboardLayout getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KeyboardLayout>(create);
  static KeyboardLayout? _defaultInstance;

  @$pb.TagNumber(1)
  $core.Map<$core.int, KeyboardLayout_KeyBehavior> get keys => $_getMap(0);
}

class TransportInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'TransportInfo', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'protocol')
    ..hasRequiredFields = false
  ;

  TransportInfo._() : super();
  factory TransportInfo({
    $core.String? protocol,
  }) {
    final _result = create();
    if (protocol != null) {
      _result.protocol = protocol;
    }
    return _result;
  }
  factory TransportInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransportInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransportInfo clone() => TransportInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransportInfo copyWith(void Function(TransportInfo) updates) => super.copyWith((message) => updates(message as TransportInfo)) as TransportInfo; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TransportInfo create() => TransportInfo._();
  TransportInfo createEmptyInstance() => create();
  static $pb.PbList<TransportInfo> createRepeated() => $pb.PbList<TransportInfo>();
  @$core.pragma('dart2js:noInline')
  static TransportInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransportInfo>(create);
  static TransportInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get protocol => $_getSZ(0);
  @$pb.TagNumber(1)
  set protocol($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasProtocol() => $_has(0);
  @$pb.TagNumber(1)
  void clearProtocol() => clearField(1);
}

class PeerConnectionParameters extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'PeerConnectionParameters', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'remoting.protocol'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'preferredMinBitrateBps', $pb.PbFieldType.O3)
    ..a<$core.int>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'preferredMaxBitrateBps', $pb.PbFieldType.O3)
    ..aOB(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'requestIceRestart')
    ..aOB(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'requestSdpRestart')
    ..hasRequiredFields = false
  ;

  PeerConnectionParameters._() : super();
  factory PeerConnectionParameters({
    $core.int? preferredMinBitrateBps,
    $core.int? preferredMaxBitrateBps,
    $core.bool? requestIceRestart,
    $core.bool? requestSdpRestart,
  }) {
    final _result = create();
    if (preferredMinBitrateBps != null) {
      _result.preferredMinBitrateBps = preferredMinBitrateBps;
    }
    if (preferredMaxBitrateBps != null) {
      _result.preferredMaxBitrateBps = preferredMaxBitrateBps;
    }
    if (requestIceRestart != null) {
      _result.requestIceRestart = requestIceRestart;
    }
    if (requestSdpRestart != null) {
      _result.requestSdpRestart = requestSdpRestart;
    }
    return _result;
  }
  factory PeerConnectionParameters.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PeerConnectionParameters.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PeerConnectionParameters clone() => PeerConnectionParameters()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PeerConnectionParameters copyWith(void Function(PeerConnectionParameters) updates) => super.copyWith((message) => updates(message as PeerConnectionParameters)) as PeerConnectionParameters; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PeerConnectionParameters create() => PeerConnectionParameters._();
  PeerConnectionParameters createEmptyInstance() => create();
  static $pb.PbList<PeerConnectionParameters> createRepeated() => $pb.PbList<PeerConnectionParameters>();
  @$core.pragma('dart2js:noInline')
  static PeerConnectionParameters getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PeerConnectionParameters>(create);
  static PeerConnectionParameters? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get preferredMinBitrateBps => $_getIZ(0);
  @$pb.TagNumber(1)
  set preferredMinBitrateBps($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPreferredMinBitrateBps() => $_has(0);
  @$pb.TagNumber(1)
  void clearPreferredMinBitrateBps() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get preferredMaxBitrateBps => $_getIZ(1);
  @$pb.TagNumber(2)
  set preferredMaxBitrateBps($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPreferredMaxBitrateBps() => $_has(1);
  @$pb.TagNumber(2)
  void clearPreferredMaxBitrateBps() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get requestIceRestart => $_getBF(2);
  @$pb.TagNumber(3)
  set requestIceRestart($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRequestIceRestart() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequestIceRestart() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get requestSdpRestart => $_getBF(3);
  @$pb.TagNumber(4)
  set requestSdpRestart($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRequestSdpRestart() => $_has(3);
  @$pb.TagNumber(4)
  void clearRequestSdpRestart() => clearField(4);
}

