import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'multicast_info.dart';
// import 'package:flutter_multicast_plugin/flutter_multicast_plugin.dart';

const String defaultMulticastIp = '239.1.1.1';
const int minMulticastPort = 16384;
const int maxMulticastPort = 32768;

class MulticastPresenter {
  final String ip = defaultMulticastIp;
  late final int videoPort;
  late final int audioPort;
  late final int ssrc;
  late final Uint8List keyHex;
  late final Uint8List saltHex;

  static final Random _random = Random();
  static final Random _secureRandom = Random.secure();

  Future<MulticastInfo?> get streamInfo async {
    // final rocData = await FlutterMulticastPlugin.getStreamRoc();
    // if (rocData == null) {
    //   return null;
    // }

    // return MulticastInfo(ip: ip, videoPort: videoPort, audioPort: audioPort, ssrc: ssrc, keyHex: hex.encode(keyHex), saltHex: hex.encode(saltHex), videoRoc: rocData.videoRoc, audioRoc: rocData.audioRoc);
    return MulticastInfo(ip: ip, videoPort: videoPort, audioPort: audioPort, ssrc: ssrc, keyHex: hex.encode(keyHex), saltHex: hex.encode(saltHex), videoRoc: 0, audioRoc: 0);
  }

  MulticastPresenter(){
    videoPort = _generatePort();
    audioPort = videoPort + 1;
    ssrc = _generateSsrc();

    final keyMaterial = _generateEncryptionKey();
    keyHex = keyMaterial.sublist(0, 16);
    saltHex = keyMaterial.sublist(16);
  }


  int _generatePort() {
    return minMulticastPort + _random.nextInt(maxMulticastPort - minMulticastPort + 1);
  }

  int _generateSsrc() {
    int s;
    do {
      s = _random.nextInt(0xFFFFFFFF);
    } while (s == 0); // Avoid SSRC = 0

    return s;
  }

  Uint8List _generateEncryptionKey() {
    return Uint8List.fromList(
        List.generate(30, (index) => _secureRandom.nextInt(256))
    );
  }
}