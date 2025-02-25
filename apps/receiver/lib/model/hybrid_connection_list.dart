import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/screens/v3_home.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'connect_timer.dart';

class HybridConnectionList {
  static final HybridConnectionList _instance =
      HybridConnectionList._internal();

  //private "Named constructors"
  HybridConnectionList._internal();

  // passes the instantiation to the _instance object
  factory HybridConnectionList() => _instance;

  static ensureInitialized() async {
    _deviceType = await DeviceInfoVs.deviceType ?? '';
    if (_support9SplitScreenDevices.contains(_deviceType)) {
      maxHybridConnection = 9;
      maxHybridSplitScreen = 9;
    } else if (_support6SplitScreenDevices.contains(_deviceType)) {
      maxHybridConnection = 6;
      maxHybridSplitScreen = 6;
    } else {
      maxHybridConnection = 6;
      maxHybridSplitScreen = 4;
    }
  }

  static int maxHybridConnection = 6;

  static String _deviceType = '';

  // the following device support 9 split screen
  static final List<String> _support9SplitScreenDevices = [
    'IFP105S',
    'IFP105UW',
    'IFP110',
    'IFP92UW',
    'CDE105UW',
    'CDE92UW',
    'IFP51',
  ];

  // the following device support 6 split screen
  static final List<String> _support6SplitScreenDevices = [
    'IFP105S',
    'IFP105UW',
    'IFP110',
    'IFP92UW',
    'CDE105UW',
    'CDE92UW',
  ];
  static int maxHybridSplitScreen = 4;

  ValueNotifier<int?> enlargedScreenIndex = ValueNotifier(null);

  static ValueNotifier<int> hybridSplitScreenCount = ValueNotifier(0);

  final List<dynamic> _hybridConnectionList =
      List.filled(maxHybridConnection * 2, null);

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
      // If the removing connector's index matches the enlarged index, reset it
      if (index == enlargedScreenIndex.value) {
        Home.enlargedScreenPositionIndex.value = null;
        enlargedScreenIndex.value = null;
      }

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
    _reorderPresentingConnector();

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
    V3Home.isShowDisplayCode.value = inConnectionNumber == 0 ? true : false;
    V3Home.isShowHeaderFooterBar.value = inConnectionNumber == 0 ? true : false;

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

  bool isStopPresenting(int index) {
    bool stopPresenting = true;
    var connection = _hybridConnectionList[index];
    if (connection is RTCConnector &&
        (connection.presentationState != PresentationState.stopStreaming)) {
      stopPresenting = false;
    } else if (connection is MirrorRequest &&
        connection.mirrorState != MirrorState.idle) {
      stopPresenting = false;
    }
    return stopPresenting;
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
    return HybridConnectionList().getRtcConnectorMap().length +
        HybridConnectionList().getModeratorMirrorMap().length;
  }

  bool connectionListFull() {
    return _hybridConnectionList.nonNulls.length >=
        _hybridConnectionList.length;
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
          connection.sendChangeQuality(
              true, true, hybridSplitScreenCount.value);
        }
      }
    } else {
      for (var i = 0; i < _hybridConnectionList.length; i++) {
        var connection = _hybridConnectionList[i];
        if (connection == null) {
          continue;
        }
        if (connection is RTCConnector && connection.clientId != null) {
          connection.sendChangeQuality(i == enlargedScreenIndex.value, true,
              hybridSplitScreenCount.value);
        }
      }
    }
  }

  void setSpecifiedSplitScreenWindowQuality(int selection, bool hasSelected) {
    var rtcConnectorMap = getRtcConnectorMap();
    if (selection == -1) {
      rtcConnectorMap.values.first
          .sendChangeQuality(true, true, hybridSplitScreenCount.value);
    } else {
      for (RTCConnector rtcConnector in rtcConnectorMap.values) {
        if (rtcConnector.clientId != null) {
          rtcConnector.sendChangeQuality(
              (rtcConnector == rtcConnectorMap[selection] && hasSelected),
              (rtcConnector == rtcConnectorMap[selection] || !hasSelected),
              hybridSplitScreenCount.value);
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

  bool isPresenterStopStreaming(String clientId) {
    for (var connection in _hybridConnectionList.nonNulls) {
      if (connection is RTCConnector &&
          connection.clientId == clientId &&
          (connection.presentationState.index) ==
              PresentationState.stopStreaming.index) {
        // stopStreaming
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

  bool isPresenterSharing(String clientId) {
    for (var connection in _hybridConnectionList.nonNulls) {
      if (connection is RTCConnector &&
          connection.clientId == clientId &&
          connection.isModeratorShare) {
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
          await rtcConnector?.disconnectChannel(
              reason: 'User removed the presenter');
          // need some delay to prevent exception:
          // 'package:flutter/src/rendering/object.dart': Failed assertion: line 2250 pos 12: '!_debugDisposed': is not true.
          await Future.delayed(const Duration(milliseconds: 300));
        } on PlatformException catch (e, stack) {
          log.severe('removeAllPresenters', e, stack);
        }
      }
    }
    hybridSplitScreenCount.value = 0; // workaround to trigger value changed.
    hybridSplitScreenCount.value = mirroringCount();
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
      connection.trackSessionEvent('click_sound');

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

  stopPresenterBy(int index) {
    var connection = _hybridConnectionList[index];
    if (connection != null && connection is RTCConnector) {
      if (connection.sessionId != null) {
        try {
          connection.sendStopPresent();
        } on PlatformException catch (e, stack) {
          log.severe("stopPresenterBy", e, stack);
        }
      }
    } else if (connection != null && connection is MirrorRequest) {
      connection.stopMirror();
    }
  }

  removePresenterBy(int index) async {
    var connection = _hybridConnectionList[index];
    if (connection != null && connection is RTCConnector) {
      if (connection.sessionId != null) {
        try {
          await connection.disconnectPeerConnection(sendAnalytics: true);
          await connection.disconnectChannel(
              reason: 'User removed the presenter');
        } on PlatformException catch (e, stack) {
          log.severe('removePresenterBy', e, stack);
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

  Map<int, MirrorRequest> getModeratorMirrorMap() {
    return Map.fromEntries(getMirrorMap()
        .entries
        .where((entry) => entry.value.mirrorState != MirrorState.idle));
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

  _reorderPresentingConnector() {
    final List<dynamic> presentingConnector = [];
    final List<dynamic> notPresentingConnector = [];

    // Separate to list "presenting" connector and "not presenting" connector.
    for (int i = 0; i < _hybridConnectionList.length; i++) {
      if (_hybridConnectionList[i] is RTCConnector) {
        RTCConnector rtcConnector = _hybridConnectionList[i];
        if (rtcConnector.presentationState.index >=
            PresentationState.waitForStream.index) {
          presentingConnector.add(rtcConnector);
        } else {
          notPresentingConnector.add(rtcConnector);
        }
      } else if (_hybridConnectionList[i] is MirrorRequest) {
        MirrorRequest mirrorRequest = _hybridConnectionList[i];
        if (mirrorRequest.mirrorState == MirrorState.mirroring) {
          presentingConnector.add(mirrorRequest);
        } else {
          notPresentingConnector.add(mirrorRequest);
        }
      }
    }

    // Place presenting connector to the front position
    for (int i = 0; i < presentingConnector.length; i++) {
      _hybridConnectionList[i] = presentingConnector[i];
    }
    // Place not presenting connector behind presenting connector
    for (int i = 0; i < notPresentingConnector.length; i++) {
      _hybridConnectionList[i + presentingConnector.length] =
          notPresentingConnector[i];
    }
  }
}
