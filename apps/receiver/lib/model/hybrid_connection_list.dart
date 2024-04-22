import 'dart:developer';

import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/stream_function.dart';
import 'connect_timer.dart';

class HybridConnectionList {
  static final HybridConnectionList _instance =
      HybridConnectionList._internal();

  //private "Named constructors"
  HybridConnectionList._internal();

  // passes the instantiation to the _instance object
  factory HybridConnectionList() => _instance;

  static const int maxHybridConnection = 6;

  static const int maxHybridSplitScreen = 4;

  static ValueNotifier<int> hybridSplitScreenCount = ValueNotifier(0);

  final List<dynamic> _hybridConnectionList =
      List.filled(maxHybridConnection, null);

  T getConnection<T>(int index) {
    return _hybridConnectionList[index];
  }

  void addConnection(connection) {
    int checkIndex = _hybridConnectionList.indexOf(connection);
    if (checkIndex != -1) return;
    int index = _hybridConnectionList.indexOf(null);
    if (index != -1) {
      _hybridConnectionList[index] = connection;
    }
    _remainingTimeOnOff();
  }

  void removeConnection(connection) {
    int index = _hybridConnectionList.indexOf(connection);
    if (index != -1) {
      _hybridConnectionList[_hybridConnectionList.indexOf(connection)] = null;
      for (index; index < _hybridConnectionList.length - 1; index++) {
        if (_hybridConnectionList[index + 1] != null) {
          _hybridConnectionList[index] = _hybridConnectionList[index + 1];
          _hybridConnectionList[index + 1] = null;
        }
      }
    }
    _remainingTimeOnOff();
  }

  void updateSplitScreen() {
    int inConnectionNumber = 0;
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
    hybridSplitScreenCount.value = 0; // workaround to trigger value changed.
    hybridSplitScreenCount.value = inConnectionNumber;

    if (inConnectionNumber == 0) {
      StreamFunction.streamFunctionState.value = stateStandby;
    }
    Home.isShowDisplayCode.value = inConnectionNumber == 0 ? true : false;
    Home.showTitleBottomBar.value = inConnectionNumber == 0 ? true : false;

    _handleSplitScreenQualityPreset();
  }

  // Any type of connection is presenting
  bool isPresenting({index}) {
    bool presenting = false;
    if (index != null) {
      var connection = _hybridConnectionList[index];
      if (connection is RTCConnector &&
          (connection.presentationState == PresentationState.streaming ||
              connection.presentationState ==
                  PresentationState.pauseStreaming)) {
        presenting = true;
      } else if (connection is MirrorRequest &&
          connection.mirrorState == MirrorState.mirroring) {
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
    for (var connection in _hybridConnectionList.nonNulls) {
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

  int getConnectionCount() {
    return _hybridConnectionList.nonNulls.length;
  }

  bool isRTCConnector(int index) {
    return _hybridConnectionList[index] is RTCConnector;
  }

  bool isMirrorRequest(int index) {
    return _hybridConnectionList[index] is MirrorRequest;
  }

  //RTCConnector function region
  void _handleSplitScreenQualityPreset() {
    if (hybridSplitScreenCount.value < 2) {
      for (var connection in _hybridConnectionList.nonNulls) {
        if (connection is RTCConnector &&
            connection.presentationState == PresentationState.streaming) {
          connection.sendChangeQuality(true, true);
        }
      }
    } else {
      for (var connection in _hybridConnectionList.nonNulls) {
        if (connection is RTCConnector && connection.clientId != null) {
          connection.sendChangeQuality(false, true);
        }
      }
    }
  }

  void setSpecifiedSplitScreenWindowQuality(int selection, bool hasSelected) {
    var rtcConnectorMap = getRtcConnectorMap();
    if (selection == -1) {
      rtcConnectorMap.values.first.sendChangeQuality(true, true);
    } else {
      for (RTCConnector rtcConnector in rtcConnectorMap.values) {
        if (rtcConnector.clientId != null) {
          rtcConnector.sendChangeQuality(
              (rtcConnector == rtcConnectorMap[selection] && hasSelected),
              (rtcConnector == rtcConnectorMap[selection] || !hasSelected));
        }
      }
    }
  }

  bool isPresenterWaitForStream(String clientId) {
    for (var connection in _hybridConnectionList.nonNulls) {
      if (connection is RTCConnector &&
          connection.clientId == clientId &&
          connection.presentationState == PresentationState.waitForStream) {
        return true;
      }
    }
    return false;
  }

  bool isPresenterStreaming(String clientId) {
    for (var connection in _hybridConnectionList.nonNulls) {
      if (connection is RTCConnector &&
          connection.clientId == clientId &&
          (connection.presentationState.index) >=
              PresentationState.streaming.index) {
        return true;
      }
    }
    return false;
  }

  bool isPresenterNotStopStreaming(String clientId) {
    for (var connection in _hybridConnectionList.nonNulls) {
      if (connection is RTCConnector &&
          connection.clientId == clientId &&
          (connection.presentationState.index) >=
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
          await rtcConnector?.disconnectPeerConnection(sendAnalytics: true);
          await rtcConnector?.disconnectChannel();
          // need some delay to prevent exception:
          // 'package:flutter/src/rendering/object.dart': Failed assertion: line 2250 pos 12: '!_debugDisposed': is not true.
          await Future.delayed(const Duration(milliseconds: 300));
        } on PlatformException catch (e) {
          log(e.toString());
        }
      }
    }
    hybridSplitScreenCount.value = 0; // workaround to trigger value changed.
    hybridSplitScreenCount.value = mirroringCount();
  }

  reorderPresenters(RTCConnector? selectedRtcConnector) {
    int index = _hybridConnectionList.indexOf(selectedRtcConnector);
    if (index != -1) {
      for (int i = 0; i < _hybridConnectionList.length; i++) {
        if (_hybridConnectionList[i] != null &&
            _hybridConnectionList[i] is RTCConnector) {
          RTCConnector rtcConnector = _hybridConnectionList[i];
          //Place presenting presenter to the front position, order by if presenting
          if ((i < index &&
                  rtcConnector.presentationState !=
                      PresentationState.streaming) ||
              (i > index &&
                  rtcConnector.presentationState ==
                      PresentationState.streaming)) {
            _hybridConnectionList[i] = selectedRtcConnector;
            _hybridConnectionList[index] = rtcConnector;
            break;
          }
        }
      }
    }
  }

  _remainingTimeOnOff() {
    int connecting = 0;
    for (var connection in _hybridConnectionList.nonNulls) {
      if (connection is RTCConnector) {
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
      });
    }
  }

  //End of RTCConnector function region

  updateAudioEnableStateByIndex(
      int index, bool enable, bool setIsAudioEnabled) {
    var connection = _hybridConnectionList[index];
    if (connection != null && connection is RTCConnector) {
      connection.controlAudio(enable, setIsAudioEnabled: setIsAudioEnabled);
    } else if (connection != null && connection is MirrorRequest) {
      connection.controlAudio(enable, setIsAudioEnabled: setIsAudioEnabled);
    }
  }

  bool getAudioDisableStateByIndex(int index) {
    var connection = _hybridConnectionList[index];
    if (connection != null && connection is RTCConnector) {
      return !connection.getAudioEnabled();
    } else if (connection != null && connection is MirrorRequest) {
      return !connection.getAudioEnabled();
    }
    return false;
  }

  removePresenterBy(int index) async {
    var connection = _hybridConnectionList[index];
    if (connection != null && connection is RTCConnector) {
      if (connection.sessionId != null) {
        try {
          await connection.disconnectPeerConnection(sendAnalytics: true);
          await connection.disconnectChannel();
        } on PlatformException catch (e) {
          log(e.toString());
        }
      }
    } else if (connection != null && connection is MirrorRequest) {
      connection.stopMirror();
    }
  }

  Map<int, RTCConnector> getRtcConnectorMap() {
    final Map<int, RTCConnector> rtcConnectorMap = {};
    for (int i = 0; i < _hybridConnectionList.length; i++) {
      if (_hybridConnectionList[i] != null &&
          _hybridConnectionList[i] is RTCConnector) {
        rtcConnectorMap[i] = _hybridConnectionList[i];
      }
    }
    return rtcConnectorMap;
  }

  Map<int, MirrorRequest> getMirrorMap() {
    final Map<int, MirrorRequest> mirrorMap = {};
    for (int i = 0; i < _hybridConnectionList.length; i++) {
      if (_hybridConnectionList[i] != null &&
          _hybridConnectionList[i] is MirrorRequest) {
        mirrorMap[i] = _hybridConnectionList[i];
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
