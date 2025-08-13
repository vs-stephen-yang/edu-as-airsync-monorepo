import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_flutter/model/multicast_info.dart';
import 'package:display_flutter/model/remote_screen_utils.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter_multicast_plugin/flutter_multicast_plugin.dart';

const String defaultMulticastIp = '239.1.1.1';
const int minMulticastPort = 16384;
const int maxMulticastPort = 32768;

class MulticastPresenter {
  final String ip = defaultMulticastIp;
  late int videoPort;
  late int audioPort;
  late int ssrc;
  late Uint8List keyHex;
  late Uint8List saltHex;
  late String keyString;

  double _screenWidth = defaultScreenWidth;
  double _screenHeight = defaultScreenHeight;

  bool started = false;

  static final Random _random = Random();
  static final Random _secureRandom = Random.secure();

  Future<MulticastInfo?> get streamInfo async {
    if (!started) {
      return null;
    }
    final rocData = await FlutterMulticastPlugin.getStreamRoc();
    if (rocData == null) {
      return null;
    }

    return MulticastInfo(
      ip: ip,
      videoPort: videoPort,
      audioPort: audioPort,
      ssrc: ssrc,
      keyHex: hex.encode(keyHex),
      saltHex: hex.encode(saltHex),
      videoRoc: rocData.videoRoc,
      audioRoc: rocData.audioRoc,
    );
  }

  MulticastPresenter();

  int _generatePort() {
    return minMulticastPort +
        _random.nextInt(maxMulticastPort - minMulticastPort + 1);
  }

  int _generateSsrc() {
    return 1 + _random.nextInt(0x7FFFFFFF); // range 1 to 2,147,483,647
  }

  Uint8List _generateEncryptionKey() {
    return Uint8List.fromList(
        List.generate(30, (index) => _secureRandom.nextInt(256)));
  }

  Future<bool> start() async {
    if (started) {
      return true;
    }
    videoPort = _generatePort();
    audioPort = videoPort + 1;
    ssrc = _generateSsrc();
    final keyMaterial = _generateEncryptionKey();
    keyHex = keyMaterial.sublist(0, 16);
    saltHex = keyMaterial.sublist(16);
    keyString = hex.encode(keyMaterial);

    final rtpSuccess = await FlutterMulticastPlugin.startRtpStream(
        ip: ip,
        videoPort: videoPort,
        audioPort: audioPort,
        ssrc: ssrc,
        key: keyHex,
        salt: saltHex);

    if (!rtpSuccess) {
      return false;
    }

    log.info(
        'Start multicast with config: videoPort: $videoPort, audioPort: $audioPort, ssrc: $ssrc, keyString: $keyString');

    final (width, height) = await updateScreenSize();
    _screenWidth = width;
    _screenHeight = height;

    String? deviceType = await DeviceInfoVs.deviceType;

    final captureResolution = getMulticastCaptureVideoResolution(
      deviceType,
      _screenWidth,
      _screenHeight,
    );
    log.info(
        'Set capture resolution ${captureResolution.name} for ${_screenWidth}x$_screenHeight $deviceType');

    await FlutterMulticastPlugin.startCapture(resolution: captureResolution);
    started = true;
    return true;
  }

  void stop() async {
    if (!started) {
      return;
    }
    await FlutterMulticastPlugin.stopCapture();
    await FlutterMulticastPlugin.stopRtpStream();
    started = false;
  }
}
