import 'dart:developer';

import 'package:flutter_mirror/airplay_config.dart';
import 'package:flutter_mirror/flutter_mirror_config.dart';
import 'package:flutter_mirror/googlecast_config.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bluetooth_touchback_listener.dart';
import 'flutter_mirror_platform_interface.dart';
import 'flutter_mirror_listener.dart';

class FlutterMirror {
  void registerListener(FlutterMirrorListener listener) {
    return FlutterMirrorPlatform.instance.registerListener(listener);
  }

  void registerBluetoothTouchBackListener(BluetoothTouchbackListener listener) {
    return FlutterMirrorPlatform.instance.
      registerBluetoothTouchBackListener(listener);
  }

  Future<void> initialize(FlutterMirrorConfig config) async {
    await requestPermissions();
    return await FlutterMirrorPlatform.instance.initialize(config);
  }

  Future<void> requestPermissions() async {
    var status = await Permission.location.status;
    if (status != PermissionStatus.granted) {
      log("location permission status: $status");
      status = await Permission.location.request();
      log("update location permission status: $status");
    }

    status = await Permission.nearbyWifiDevices.status;
    if (status != PermissionStatus.granted) {
      log("nearbyWifiDevices permission status: $status");
      status = await Permission.nearbyWifiDevices.request();
      log("update nearbyWifiDevices permission status: $status");
    }

    // TBD: do we need to request bluetooth permissions when actually use it?
    status = await Permission.bluetooth.status;
    if (status != PermissionStatus.granted) {
      log("bluetooth permission status: $status");
      status = await Permission.bluetooth.request();
      log("update bluetooth permission status: $status");
    }

    status = await Permission.bluetoothConnect.status;
    if (status != PermissionStatus.granted) {
      log("bluetoothConnect permission status: $status");
      status = await Permission.bluetoothConnect.request();
      log("update bluetoothConnect permission status: $status");
    }

    status = await Permission.bluetoothScan.status;
    if (status != PermissionStatus.granted) {
      log("bluetoothScan permission status: $status");
      status = await Permission.bluetoothScan.request();
      log("update bluetoothScan permission status: $status");
    }

    return;
  }

  Future<void> enableDump(String? dumpPath) {
    return FlutterMirrorPlatform.instance.enableDump(dumpPath);
  }

  Future<void> startMirrorReplay(
    String mirrorId,
    String videoCodec,
    String videoPath,
  ) {
    return FlutterMirrorPlatform.instance.startMirrorReplay(
      mirrorId,
      videoCodec,
      videoPath,
    );
  }

  Future<void> startAirplay(AirplayConfig config) {
    return FlutterMirrorPlatform.instance.startAirplay(config);
  }

  Future<void> stopAirplay() {
    return FlutterMirrorPlatform.instance.stopAirplay();
  }

  Future<void> startGooglecast(GooglecastConfig config) {
    return FlutterMirrorPlatform.instance.startGooglecast(config);
  }

  Future<void> stopGooglecast() {
    return FlutterMirrorPlatform.instance.stopGooglecast();
  }

  Future<void> startMiracast(String name) {
    return FlutterMirrorPlatform.instance.startMiracast(name);
  }

  Future<void> stopMiracast() {
    return FlutterMirrorPlatform.instance.stopMiracast();
  }

  Future<void> stopMirror(String mirrorId) {
    return FlutterMirrorPlatform.instance.stopMirror(mirrorId);
  }

  Future<void> enableAudio(String mirrorId, bool enable) {
    return FlutterMirrorPlatform.instance.enableAudio(mirrorId, enable);
  }

  Future<void> onMirrorTouch(
      String mirrorId, int touchId, bool touchDown, double x, double y) async {
    return FlutterMirrorPlatform.instance
        .onMirrorTouch(mirrorId, touchId, touchDown, x, y);
  }
}
