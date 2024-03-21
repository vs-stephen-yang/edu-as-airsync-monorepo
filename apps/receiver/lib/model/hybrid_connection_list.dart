import 'dart:developer';

import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mirror/flutter_mirror.dart';

import '../widgets/stream_function.dart';
import 'connect_timer.dart';

class HybridConnectionList {
  static final HybridConnectionList _instance = HybridConnectionList._internal();

  //private "Named constructors"
  HybridConnectionList._internal();

  // passes the instantiation to the _instance object
  factory HybridConnectionList() => _instance;

  final List<dynamic> hybridConnectionList = List.filled(6, null);

  void addConnection(connection) {
    int checkIndex = hybridConnectionList.indexOf(connection);
    if (checkIndex != -1) return;
    int index = hybridConnectionList.indexOf(null);
    if (index != -1) {
      hybridConnectionList[index] = connection;
    }
    _remainingTimeOnOff();
  }

  void removeConnection(connection) {
    int index = hybridConnectionList.indexOf(connection);
    if (index != -1) {
      hybridConnectionList[hybridConnectionList.indexOf(connection)] = null;
    }
    _remainingTimeOnOff();
  }

  void updateSplitScreen() {
    int inConnectionNumber = 0, lastID = 0;
    for (RTCConnector connector in getRtcConnectorMap().values) {
      if (connector.presentationState != PresentationState.stopStreaming) {
        inConnectionNumber++;
      }
    }
    for (MirrorRequest request in getMirrorMap().values) {
      if (request.mirrorState == MirrorState.mirroring) {
        inConnectionNumber++;
      }
    }
    lastID = hybridConnectionList.indexOf(hybridConnectionList.nonNulls.lastOrNull);

    SplitScreen.mapSplitScreen.value[keySplitScreenCount] = inConnectionNumber;
    SplitScreen.mapSplitScreen.value[keySplitScreenLastId] = lastID;
    // Using below method to trigger value changed.
    // https://github.com/flutter/flutter/issues/29958
    SplitScreen.mapSplitScreen.value =
        Map.from(SplitScreen.mapSplitScreen.value);

    if (inConnectionNumber == 0) {
      StreamFunction.streamFunctionState.value = stateStandby;
    }
    Home.isShowDisplayCode.value = inConnectionNumber == 0 ? true : false;
  }

  // Any type of connection is presenting
  bool isPresenting({index}) {
    bool presenting = false;
    if (index != null) {
      var connection = hybridConnectionList[index];
      if (connection is RTCConnector &&
          (connection.presentationState == PresentationState.streaming ||
              connection.presentationState ==
                  PresentationState.pauseStreaming)) {
        presenting = true;
      } else if (connection is MirrorRequest && connection.mirrorState ==
          MirrorState.mirroring) {
        presenting = true;
      }
    } else {
      for (RTCConnector connector in getRtcConnectorMap().values) {
        if (connector.presentationState != PresentationState.stopStreaming) {
          presenting = true;
        }
      }
      for (MirrorRequest request in getMirrorMap().values) {
        if (request.mirrorState == MirrorState.mirroring) {
          presenting = true;
        }
      }
    }
    return presenting;
  }

  int getPresentingCount() {
    int count = 0;
    for (dynamic connection in hybridConnectionList.nonNulls) {
      if (connection is RTCConnector &&
              (connection.presentationState == PresentationState.streaming ||
                  connection.presentationState ==
                      PresentationState.pauseStreaming ||
                  connection.presentationState ==
                      PresentationState.resumeStreaming) ||
          (connection is MirrorRequest &&
              connection.mirrorState == MirrorState.mirroring)) {
        count++;
      }
    }
    return count;
  }


  //RTCConnector function region
  void handleQualityUpdate({RTCConnector? controller}) {
    if (SplitScreen.mapSplitScreen.value[keySplitScreenCount] < 2) {
      for (RTCConnector? connector in hybridConnectionList) {
        if (connector?.presentationState == PresentationState.streaming) {
          connector?.sendChangeQuality(true, true);
        }
      }
    } else {
      for (RTCConnector? connector in hybridConnectionList) {
        if (connector?.clientId != null) {
          connector?.sendChangeQuality(false, true);
        }
      }
    }
  }

  bool occupyAvailableRTCConnector(int index) {
    for (int i = 0; i < hybridConnectionList.length; i++) {
      if (hybridConnectionList[i] is RTCConnector &&
          (hybridConnectionList[i]?.presentationState.index ?? 0) <
              PresentationState.occupied.index) {
        hybridConnectionList[index]?.presentationState = PresentationState.occupied;
        return true;
      }
    }
    return false;
  }

  bool hasPresenterOccupied({index}) {
    bool presenting = false;
    if (index != null) {
      if (hybridConnectionList[index] is RTCConnector &&
          hybridConnectionList[index]?.presentationState !=
              PresentationState.stopStreaming) {
        presenting = true;
      }
    } else {
      for (RTCConnector? rtcConnector in hybridConnectionList) {
        if (rtcConnector != null &&
            rtcConnector.presentationState != PresentationState.stopStreaming) {
          presenting = true;
        }
      }
    }
    return presenting;
  }

  bool isPresenterWaitForStream(String clientId) {
    for (RTCConnector? rtcConnector in hybridConnectionList) {
      if (rtcConnector != null && rtcConnector.clientId == clientId &&
          rtcConnector.presentationState == PresentationState.waitForStream) {
        return true;
      }
    }
    return false;
  }

  bool isPresenterStreaming(String clientId) {
    for (RTCConnector? rtcConnector in hybridConnectionList) {
      if (rtcConnector != null && rtcConnector.clientId == clientId &&
          (rtcConnector.presentationState.index) >=
              PresentationState.streaming.index) {
        return true;
      }
    }
    return false;
  }

  bool isPresenterNotStopStreaming(String clientId) {
    for (RTCConnector? rtcConnector in hybridConnectionList) {
      if (rtcConnector != null && rtcConnector.clientId == clientId &&
          (rtcConnector.presentationState.index) >=
              PresentationState.waitForStream.index) {
        // waitForStream and streaming
        return true;
      }
    }
    return false;
  }

  removeAllPresenters() async {
    RTCConnector? rtcConnector;
    List<RTCConnector?> temp = List.from(getRtcConnectorMap().values);
    for (int i = temp.length - 1; i >= 0; i--) {
      rtcConnector = temp[i];
      if (rtcConnector?.clientId != null) {
        try {
          await rtcConnector?.disconnectPeerConnection(
              sendAnalytics: true);
          await rtcConnector?.disconnectChannel();
          // need some delay to prevent exception:
          // 'package:flutter/src/rendering/object.dart': Failed assertion: line 2250 pos 12: '!_debugDisposed': is not true.
          await Future.delayed(const Duration(milliseconds: 300));
        } on PlatformException catch (e) {
          log(e.toString());
        }
      }
    }
  }

  _remainingTimeOnOff() {
    int connecting = 0;
    for (var connection in hybridConnectionList) {
      if (connection != null && connection is RTCConnector) {
        connecting += 1;
      }
    }
    if (connecting <= 0) {
      ConnectionTimer.getInstance().stopRemainingTimeTimer();
    } else {
      if (ConnectionTimer.getInstance().remainingTimeTimerIsActive()) {
        return;
      }
      ConnectionTimer.getInstance().startRemainingTimeTimer(() async {
        removeAllPresenters();
        SplitScreen.mapSplitScreen.value[keySplitScreenCount] = mirroringCount();
        SplitScreen.mapSplitScreen.value =
            Map.from(SplitScreen.mapSplitScreen.value);
      });
    }
  }
  //End of RTCConnector function region

  updateAudioEnableStateByIndex(int index, bool enable, {FlutterMirror? mirrorPlugin}) {
    var connection = HybridConnectionList().hybridConnectionList[index];
    if (connection != null && connection is RTCConnector) {
      connection.controlAudio(enable, setIsAudioEnabled: true);
    } else if (connection != null && connection is MirrorRequest) {
      mirrorPlugin?.enableAudio(connection.mirrorId ?? '0', enable);
    }
  }

  bool getAudioDisableStateByIndex(int index, {bool? mirrorAudioEnabled}) {
    var connection = HybridConnectionList().hybridConnectionList[index];
    if (connection != null && connection is RTCConnector) {
      return connection.getAudioState();
    } else if (connection != null && connection is MirrorRequest) {
      return !(mirrorAudioEnabled ?? false);
    }
    return false;
  }

  removePresenterBy(int index, FlutterMirror? mirrorPlugin) async {
    var connection = hybridConnectionList[index];
    if (connection != null && connection is RTCConnector) {
      if (connection.sessionId != null) {
        try {
          await connection.disconnectPeerConnection(sendAnalytics: true);
          await connection.disconnectChannel();
          ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
        } on PlatformException catch (e) {
          log(e.toString());
        }
      }
    } else if (connection != null && connection is MirrorRequest) {
      mirrorPlugin?.stopMirror(connection.mirrorId ?? '0');
    }
  }

  Map<int, RTCConnector> getRtcConnectorMap() {
    final Map<int, RTCConnector> rtcConnectorMap = {};
    for (int i = 0; i < hybridConnectionList.length; i++) {
      if (hybridConnectionList[i] != null &&
          hybridConnectionList[i] is RTCConnector) {
        rtcConnectorMap[i] = hybridConnectionList[i];
      }
    }
    return rtcConnectorMap;
  }

  Map<int, MirrorRequest> getMirrorMap() {
    final Map<int, MirrorRequest> mirrorMap = {};
    for (int i = 0; i < hybridConnectionList.length; i++) {
      if (hybridConnectionList[i] != null &&
          hybridConnectionList[i] is MirrorRequest) {
        mirrorMap[i] = hybridConnectionList[i];
      }
    }
    return mirrorMap;
  }

  //Mirror functions region

  bool isMirroring() {
    bool isMirroring = false;
    for (MirrorRequest request in getMirrorMap().values) {
      if (request.mirrorState == MirrorState.mirroring) {
        isMirroring = true;
      }
    }
    return isMirroring;
  }

  int mirroringCount() {
    int count = 0;
    for (MirrorRequest request in getMirrorMap().values) {
      if (request.mirrorState == MirrorState.mirroring) {
        count++;
      }
    }
    return count;
  }
  //End region of Mirror functions
}
