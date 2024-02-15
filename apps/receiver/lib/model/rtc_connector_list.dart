import 'dart:developer';

import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:flutter/services.dart';

import 'connect_timer.dart';

class RtcConnectorList {
  static final RtcConnectorList _instance = RtcConnectorList._internal();

  //private "Named constructors"
  RtcConnectorList._internal();

  // passes the instantiation to the _instance object
  factory RtcConnectorList() => _instance;

  final List<RTCConnector?> rtcConnectorList = List.filled(6, null);

  void addRTCConnector(RTCConnector rtcConnector) {
    int checkIndex = rtcConnectorList.indexOf(rtcConnector);
    if (checkIndex != -1) return;
    int index = rtcConnectorList.indexOf(null);
    if (index != -1) {
      rtcConnectorList[index] = rtcConnector;
    }
    _remainingTimeOnOff();
  }

  void removeRTCConnector(RTCConnector rtcConnector) {
    int index = rtcConnectorList.indexOf(rtcConnector);
    if (index != -1) {
      rtcConnectorList[rtcConnectorList.indexOf(rtcConnector)] = null;
    }
    _remainingTimeOnOff();
  }

  void updateSplitScreen() {
    int connecting = 0, lastID = 0;
    for (int i = 0; i < rtcConnectorList.nonNulls.length; i++) {
      if (rtcConnectorList[i]?.presentationState !=
          PresentationState.stopStreaming) {
        connecting++;
        lastID = i;
      }
    }
    SplitScreen.mapSplitScreen.value[keySplitScreenCount] = connecting;
    SplitScreen.mapSplitScreen.value[keySplitScreenLastId] = lastID;
    // Using below method to trigger value changed.
    // https://github.com/flutter/flutter/issues/29958
    SplitScreen.mapSplitScreen.value =
        Map.from(SplitScreen.mapSplitScreen.value);
  }

  void handleQualityUpdate({RTCConnector? controller}) {
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      if (SplitScreen.mapSplitScreen.value[keySplitScreenCount] < 2) {
        for (RTCConnector? connector in rtcConnectorList) {
          if (connector?.presentationState == PresentationState.streaming) {
            connector?.sendChangeQuality(true, true);
          }
        }
      } else {
        for (RTCConnector? connector in rtcConnectorList) {
          if (connector?.clientId != null) {
            connector?.sendChangeQuality(false, true);
          }
        }
      }
    } else {
      if (controller != null) {
        controller.sendChangeQuality(true, true);
      }
    }
  }

  bool occupyAvailableRTCConnector(int index) {
    for (int i = 0; i < rtcConnectorList.length; i++) {
      if ((rtcConnectorList[i]?.presentationState.index ?? 0) <
          PresentationState.occupied.index) {
        rtcConnectorList[index]?.presentationState = PresentationState.occupied;
        return true;
      }
    }
    return false;
  }

  bool isPresenting({index}) {
    bool presenting = false;
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      if (index != null) {
        if (rtcConnectorList[index]?.presentationState ==
            PresentationState.streaming) {
          presenting = true;
        }
      } else {
        for (RTCConnector? controller in rtcConnectorList) {
          if (controller?.presentationState == PresentationState.streaming) {
            presenting |= true;
          }
        }
      }
    } else {
      if (rtcConnectorList.isNotEmpty &&
          rtcConnectorList[0]?.presentationState ==
              PresentationState.streaming) {
        presenting = true;
      }
    }
    return presenting;
  }

  bool hasPresenterOccupied({index}) {
    bool presenting = false;
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      if (index != null) {
        if (rtcConnectorList[index]?.presentationState !=
            PresentationState.stopStreaming) {
          presenting = true;
        }
      } else {
        for (RTCConnector? controller in rtcConnectorList) {
          if (controller != null &&
              controller.presentationState != PresentationState.stopStreaming) {
            presenting |= true;
          }
        }
      }
    } else {
      if (rtcConnectorList.isNotEmpty &&
          rtcConnectorList[0]?.presentationState !=
              PresentationState.stopStreaming) {
        presenting = true;
      }
    }
    return presenting;
  }

  int getPresentingQuantity() {
    int quantity = 0;
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      for (RTCConnector? controller in rtcConnectorList) {
        if (controller?.presentationState == PresentationState.streaming) {
          quantity++;
        }
      }
    }
    return quantity;
  }

  bool isPresenterWaitForStream(String clientId) {
    for (RTCConnector? controller in rtcConnectorList) {
      if (controller?.clientId == clientId &&
          controller?.presentationState == PresentationState.waitForStream) {
        return true;
      }
    }
    return false;
  }

  bool isPresenterStreaming(String clientId) {
    for (RTCConnector? controller in rtcConnectorList) {
      if (controller?.clientId == clientId &&
          (controller?.presentationState.index ?? 0) >=
              PresentationState.streaming.index) {
        return true;
      }
    }
    return false;
  }

  bool isPresenterNotStopStreaming(String clientId) {
    for (RTCConnector? controller in rtcConnectorList) {
      if (controller?.clientId == clientId &&
          (controller?.presentationState.index ?? 0) >=
              PresentationState.waitForStream.index) {
        // waitForStream and streaming
        return true;
      }
    }
    return false;
  }

  removeAllPresenters() async {
    RTCConnector? selectedController;
    List<RTCConnector?> temp = List.from(rtcConnectorList);
    for (int i = temp.length - 1; i >= 0; i--) {
      selectedController = temp[i];
      if (selectedController?.clientId != null) {
        try {
          await selectedController?.disconnectPeerConnection(
              sendAnalytics: true);
          await selectedController?.disconnectChannel();
          // need some delay to prevent exception:
          // 'package:flutter/src/rendering/object.dart': Failed assertion: line 2250 pos 12: '!_debugDisposed': is not true.
          await Future.delayed(const Duration(milliseconds: 300));
        } on PlatformException catch (e) {
          log(e.toString());
        }
      }
    }
  }

  /// a session ID is generated due to the act of presenting.
  removeOtherPresenters({bool keepInList = false}) async {
    RTCConnector? selectedController;
    List<RTCConnector?> temp = List.from(rtcConnectorList);
    for (int i = temp.length - 1; i >= 0; i--) {
      selectedController = temp[i];
      if (selectedController?.sessionId != null) {
        try {
          await selectedController?.disconnectPeerConnection(
              sendAnalytics: true);
          if (!keepInList) {
            await selectedController?.disconnectChannel();
          } else {
            selectedController?.sendStopPresent();
          }
          // need some delay to prevent exception:
          // 'package:flutter/src/rendering/object.dart': Failed assertion: line 2250 pos 12: '!_debugDisposed': is not true.
          await Future.delayed(const Duration(milliseconds: 300));
        } on PlatformException catch (e) {
          log(e.toString());
        }
      }
    }
  }

  removePresenterBy(int index) async {
    RTCConnector? selectedController = rtcConnectorList[index];
    if (selectedController?.sessionId != null) {
      try {
        await selectedController?.disconnectPeerConnection(sendAnalytics: true);
        await selectedController?.disconnectChannel();
        ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
      } on PlatformException catch (e) {
        log(e.toString());
      }
    }
  }

  _remainingTimeOnOff() {
    int connecting = 0;
    for (var element in rtcConnectorList) {
      if (element != null) {
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
        SplitScreen.mapSplitScreen.value[keySplitScreenCount] = 0;
        SplitScreen.mapSplitScreen.value =
            Map.from(SplitScreen.mapSplitScreen.value);
      });
    }
  }
}
