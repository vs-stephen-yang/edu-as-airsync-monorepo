
import 'dart:developer';

import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:flutter/services.dart';

import 'connect_timer.dart';

class RtcConnectorList {
  static RtcConnectorList _instance = RtcConnectorList._internal();

  static RtcConnectorList getInstance() {
    return _instance;
  }

  RtcConnectorList._internal();

  static final List<RTCConnector> _channelRtcConnectors = <RTCConnector>[];
  static List<RTCConnector> get rtcConnectorList => _channelRtcConnectors;

  void updateSplitScreen() {
    int connecting = 0, lastID = 0;
    for (int i = 0; i < rtcConnectorList.length; i++) {
      if (rtcConnectorList[i].presentationState !=
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
        for (RTCConnector connector in rtcConnectorList) {
          if (connector.presentationState == PresentationState.streaming) {
            connector.sendChangeQuality(true, true);
          }
        }
      } else {
        for (RTCConnector connector in _channelRtcConnectors) {
          if (connector.clientId != null) {
            connector.sendChangeQuality(false, true);
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
    for (int i = 0; i < _channelRtcConnectors.length; i++) {
      if (_channelRtcConnectors[i].presentationState.index <
          PresentationState.occupied.index) {
        _channelRtcConnectors[index].presentationState = PresentationState.occupied;
        return true;
      }
    }
    return false;
  }

  bool isPresenting({index}) {
    bool presenting = false;
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      if (index != null && _channelRtcConnectors.length > index) {
        if (_channelRtcConnectors[index].presentationState ==
            PresentationState.streaming) {
          presenting = true;
        }
      } else {
        for (RTCConnector controller in _channelRtcConnectors) {
          if (controller.presentationState == PresentationState.streaming) {
            presenting |= true;
          }
        }
      }
    } else {
      if (_channelRtcConnectors.isNotEmpty &&
          _channelRtcConnectors[0].presentationState ==
              PresentationState.streaming) {
        presenting = true;
      }
    }
    return presenting;
  }

  bool hasPresenterOccupied({index}) {
    bool presenting = false;
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      if (index != null && _channelRtcConnectors.length > index) {
        if (_channelRtcConnectors[index].presentationState !=
            PresentationState.stopStreaming) {
          presenting = true;
        }
      } else {
        for (RTCConnector controller in _channelRtcConnectors) {
          if (controller.presentationState != PresentationState.stopStreaming) {
            presenting |= true;
          }
        }
      }
    } else {
      if (_channelRtcConnectors.isNotEmpty &&
          _channelRtcConnectors[0].presentationState !=
              PresentationState.stopStreaming) {
        presenting = true;
      }
    }
    return presenting;
  }

  int getPresentingQuantity() {
    int quantity = 0;
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      for (RTCConnector controller in _channelRtcConnectors) {
        if (controller.presentationState == PresentationState.streaming) {
          quantity++;
        }
      }
    }
    return quantity;
  }

  bool isPresenterWaitForStream(String clientId) {
    for (RTCConnector controller in _channelRtcConnectors) {
      if (controller.clientId == clientId &&
          controller.presentationState == PresentationState.waitForStream) {
        return true;
      }
    }
    return false;
  }

  bool isPresenterStreaming(String clientId) {
    for (RTCConnector controller in _channelRtcConnectors) {
      if (controller.clientId == clientId &&
          controller.presentationState.index >= PresentationState.streaming.index) {
        return true;
      }
    }
    return false;
  }

  bool isPresenterNotStopStreaming(String clientId) {
    for (RTCConnector controller in _channelRtcConnectors) {
      if (controller.clientId == clientId &&
          controller.presentationState.index >=
              PresentationState.waitForStream.index) {
        // waitForStream and streaming
        return true;
      }
    }
    return false;
  }

  removeAllPresenters() async {
    RTCConnector? selectedController;
    List<RTCConnector> temp = List.from(_channelRtcConnectors);
    for (int i = temp.length - 1; i >= 0; i--) {
      selectedController = temp[i];
      if (selectedController.clientId != null) {
        try {
          await selectedController.disconnectPeerConnection(sendAnalytics: true);
          await selectedController.disconnectChannel();
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
    List<RTCConnector> temp = List.from(_channelRtcConnectors);
    for (int i = temp.length - 1; i >= 0; i--) {
      selectedController = temp[i];
      if (selectedController.sessionId != null) {
        try {
          await selectedController.disconnectPeerConnection(sendAnalytics: true);
          if (!keepInList) {
            await selectedController.disconnectChannel();
          } else {
            selectedController.sendStopPresent();
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
    int listIndex = ChannelProvider.rtcPlayOrder.getOrderByIndex(index);
    RTCConnector? selectedController = _channelRtcConnectors[listIndex];
    if (selectedController.sessionId != null) {
      try {
        await selectedController.disconnectPeerConnection(sendAnalytics: true);
        await selectedController.disconnectChannel();
        ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
      } on PlatformException catch (e) {
        log(e.toString());
      }
    }
  }
}