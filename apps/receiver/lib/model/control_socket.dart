import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:display_flutter/model/bean/display_message.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/model/webrtc_info.dart';
import 'package:display_flutter/native_view/webrtc.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/utility/get_string.dart';
import 'package:display_flutter/widgets/main_info.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/services.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ControlSocket {
  static final ControlSocket _instance = ControlSocket._internal();

  //private "Named constructors"
  ControlSocket._internal();

  // passes the instantiation to the _instance object
  factory ControlSocket() => _instance;

  late Socket _controlSocketIO;
  final int _maxReconnectAttempts = 5;
  int _displayReconnectAttempts = 0;

  final List<WebRTCNativeViewController> _webRtcController =
      <WebRTCNativeViewController>[];
  WebRTCInfo mWebRTCInfo = WebRTCInfo.getInstance();

  void connect(String apiGateway) {
    _controlSocketIO = io(
        apiGateway,
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()
            .enableForceNew()
            .enableReconnection()
            .setReconnectionAttempts(_maxReconnectAttempts)
            .setQuery({
              'socketCustomEvent': mWebRTCInfo.displayCode,
              'role': 'display',
              'deviceId': mWebRTCInfo.instanceId,
              'token': mWebRTCInfo.token
            })
            .build());

    _controlSocketIO
        .onConnect((data) => _printControlSocketLog('connect', data));
    _controlSocketIO
        .onConnecting((data) => _printControlSocketLog('connecting', data));
    _controlSocketIO.onConnectError((data) {
      _printControlSocketLog('connect_error', data);
      if (_displayReconnectAttempts >= _maxReconnectAttempts) {
        _displayReconnectAttempts = 0;

        Future.delayed(const Duration(seconds: 5), () {
          connect(apiGateway);
        });
      }
    });
    _controlSocketIO.on(mWebRTCInfo.displayCode, (data) {
      _printControlSocketLog(mWebRTCInfo.displayCode, data);
      _handleDisplayResponse(data);
    });
    _controlSocketIO.on(
        'message', (data) => _printControlSocketLog('message', data));
    _controlSocketIO.onConnectTimeout(
        (data) => _printControlSocketLog('onConnectTimeout', data));
    _controlSocketIO
        .onDisconnect((data) => _printControlSocketLog('disconnect', data));
    _controlSocketIO.onError((data) => _printControlSocketLog('error', data));
    _controlSocketIO.onReconnecting((data) {
      _printControlSocketLog('reconnecting', data);
      _displayReconnectAttempts++;
    });

    _controlSocketIO.connect();
  }

  void disconnectControlSocket() {
    // https://github.com/rikulo/socket.io-client-dart/issues/108
    _controlSocketIO.dispose();
  }

  void addWebRtcController(WebRTCNativeViewController controller) {
    _webRtcController.add(controller);
    controller.channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'disposed':
          _webRtcController.remove(controller);
          break;
        case 'onServerDisconnected':
          ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
          break;
        case 'onStreamAdded':
          ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
          controller.nativeViewState.switchConnectionState(false);
          Home.showTitleBottomBar.value = false;
          StreamFunction.showWaitFunction.value = false;
          _handleDisplayStateUpdate(mWebRTCInfo);
          break;
        case 'disconnectedP2pClient':
          controller.nativeViewState.switchConnectionState(false);
          Home.showTitleBottomBar.value = true;
          StreamFunction.showWaitFunction.value = true;
          MainInfo.showMainInfo.value = true;
          break;
      }
      return;
    });
  }

  void _printControlSocketLog(String? event, dynamic args) {
    print("mControlSocketIO: $event ${args.toString()}");
  }

  void _handleDisplayResponse(dynamic arg) async {
    String? messageFor = arg['messageFor'];
    if (messageFor != null && messageFor == mWebRTCInfo.displayCode) {
      var resp = DisplayMessage.fromJson(arg);
      switch (resp.action) {
        // region Moderator
        case "set-moderator":
          mWebRTCInfo.moderatorMode = true;
          Extra extra = Extra.fromJson(resp.extra);
          Moderator moderator = Moderator.fromJson(extra.moderator);
          mWebRTCInfo.moderatorId = moderator.id;
          mWebRTCInfo.moderatorName = moderator.name;
          mWebRTCInfo.meetingId = extra.moderatedSessionId ?? '';
          mWebRTCInfo.remainingTime =
              extra.endTime! - DateTime.now().millisecondsSinceEpoch;
          List<dynamic>? checkPoints = extra.checkPoints;
          int? duration = extra.durationRemaining;
          for (int i = 0; i < checkPoints!.length; i++) {
            if ((duration! - checkPoints[i]) > 1000) {
              double point = ((duration - checkPoints[i]) / 1000);
              mWebRTCInfo.remainingTimeCheckPoints.add(point);
              log('checkpoint: $point');
            }
          }

          // AppCenterAnalyticsHelper.getInstance().setEventProperties(buildEventProperties());
          ConnectionTimer.getInstance()
              .startRemainingTimeTimer(mWebRTCInfo.remainingTime, () {
            mWebRTCInfo.moderatorMode = false;
            mWebRTCInfo.isModeratorLeave = true;
            mWebRTCInfo.moderatorId = "";
            mWebRTCInfo.moderatorName = "";

            for (WebRTCNativeViewController controller in _webRtcController) {
              controller.channel.invokeMethod('remainingTimeTimeOut');
            }
          });
          break;
        case "unset-moderator":
          mWebRTCInfo.moderatorMode = false;
          mWebRTCInfo.isModeratorLeave = true;
          mWebRTCInfo.moderatorId = "";
          mWebRTCInfo.moderatorName = "";
          mWebRTCInfo.meetingId = "";

          // AppCenterAnalyticsHelper.getInstance().setEventProperties(buildEventProperties());
          ConnectionTimer.getInstance().stopRemainingTimeTimer();
          break;
        // endregion Moderator
        // region Present
        case "start-present":
          Extra extra = Extra.fromJson(resp.extra);

          Signal signal = Signal.fromJson(extra.signal);
          mWebRTCInfo.peerToken = signal.token ?? '';
          mWebRTCInfo.peerId = signal.peerId ?? '';

          Presenter presenter = Presenter.fromJson(extra.presenter);
          mWebRTCInfo.presenterId = presenter.id ?? '';
          mWebRTCInfo.presenterName = presenter.name ?? '';

          WebRTCNativeViewController? selectedController;
          if (SplitScreen.splitScreenEnabled.value) {
            // todo: find unused view to connect
            for (WebRTCNativeViewController controller in _webRtcController) {
              if (await controller.channel.invokeMethod("isNotConnected")) {
                selectedController = controller;
                break;
              }
            }
          } else {
            if (await _webRtcController[0]
                .channel
                .invokeMethod("isNotConnected")) {
              selectedController = _webRtcController[0];
            }
          }
          if (selectedController != null) {
            log('selectedController: ${selectedController.channel.name}');
            try {
              // Send wait for stream
              mWebRTCInfo.presentationState = PresentationState.waitForStream;
              _handleDisplayStateUpdate(mWebRTCInfo);
              // Send wait for stream

              if (!mWebRTCInfo.moderatorMode) {
                ConnectionTimer.getInstance().startConnectionTimeoutTimer(
                    mWebRTCInfo, resp.nextId ?? '', selectedController,
                    (webRTCInfo, nextId, controller) {
                  _handleP2PClientReject(webRTCInfo, nextId, 'timeout');

                  controller.channel.invokeMethod('connectionTimeTimeOut');
                  MainInfo.showMainInfo.value = true;
                  controller.nativeViewState.switchConnectionState(false);
                });
              }

              MainInfo.showMainInfo.value = false;
              selectedController.nativeViewState.switchConnectionState(true);
              var arg = {
                'token': mWebRTCInfo.peerToken,
                'peerId': mWebRTCInfo.peerId,
              };
              final String result = await selectedController.channel
                  .invokeMethod('connectP2pClient', arg);
              _handleP2PClientSuccess(mWebRTCInfo, resp.nextId ?? '', result);
              // AppCenterAnalyticsHelper.getInstance().EventStreamStart();
            } on PlatformException catch (e) {
              MainInfo.showMainInfo.value = true;
              selectedController.nativeViewState.switchConnectionState(false);
              _handleP2PClientReject(mWebRTCInfo, resp.nextId ?? '', 'blocked');
              log(e.toString());
            }
          } else {
            log('selectedController is null!');
            _handleP2PClientReject(mWebRTCInfo, resp.nextId ?? '', 'blocked');
          }
          break;
        case "stop-present":
          Extra extra = Extra.fromJson(resp.extra);
          Presenter presenter = Presenter.fromJson(extra.presenter);
          // todo: split screen find controller channel
          if (presenter.id == mWebRTCInfo.presenterId) {
            try {
              await _webRtcController[0].channel.invokeMethod("stopVideo");
              // AppCenterAnalyticsHelper.getInstance().EventStreamStopped();
              ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
            } on PlatformException catch (e) {
              log(e.toString());
            }
          }
          break;
        case "pause-present":
          Extra extra = Extra.fromJson(resp.extra);
          Presenter presenter = Presenter.fromJson(extra.presenter);
          // todo: split screen find controller channel
          if (presenter.id == mWebRTCInfo.presenterId) {
            try {
              await _webRtcController[0].channel.invokeMethod("pauseVideo");
              _handleStreamPauseSuccess(mWebRTCInfo, resp.nextId);
              // AppCenterAnalyticsHelper.getInstance().EventStreamPaused();
            } on PlatformException catch (e) {
              log(e.toString());
            }
          }
          break;
        case "resume-present":
          Extra extra = Extra.fromJson(resp.extra);
          Presenter presenter = Presenter.fromJson(extra.presenter);
          // todo: split screen find controller channel
          if (presenter.id == mWebRTCInfo.presenterId) {
            try {
              await _webRtcController[0].channel.invokeMethod("resumeVideo");
              // AppCenterAnalyticsHelper.getInstance().EventStreamResumed();
            } on PlatformException catch (e) {
              log(e.toString());
            }
          }
          break;
        // endregion  Present
      }
    }
  }

  void _handleDisplayStateUpdate(WebRTCInfo webRTCInfo) {
    var content = json.encode({
      'messageFor': webRTCInfo.presenterId,
      'action': 'display-state-update',
      'status': 'display-state-update',
      'extra': {
        'uiState': {
          'code': webRTCInfo.isShowCode,
          'delegate': webRTCInfo.isShowDelegate,
        },
        'presentationState': webRTCInfo.presentationState.name,
      },
      'messageId': GetString.getRandomString(21),
      'nextId': GetString.getRandomString(21),
    });
    print('mControlSocketIO: _handleDisplayStateUpdate: $content');
    _controlSocketIO.emit(webRTCInfo.displayCode, json.decode(content));
  }

  void _handleP2PClientSuccess(
      WebRTCInfo webRTCInfo, String nextId, String result) {
    var content = json.encode({
      'messageFor': webRTCInfo.displayCode,
      'action': 'start-present',
      'status': 'ready',
      'extra': {
        'presenter': {
          'id': webRTCInfo.presenterId,
          'extra': {
            'constraint': {
              'frameRate': 30,
              'height': 1080,
            },
          },
        },
      },
      'messageId': nextId,
      'nextId': GetString.getRandomString(21)
    });
    print('mControlSocketIO: _handleP2PClientSuccess: $content');
    _controlSocketIO.emit(webRTCInfo.displayCode, json.decode(content));
  }

  void _handleP2PClientReject(
      WebRTCInfo webRTCInfo, String nextId, String reason) {
    var content = json.encode({
      'messageFor': webRTCInfo.displayCode,
      'action': 'reject-present',
      'extra': {
        'presenter': {
          'id': webRTCInfo.presenterId,
        },
        'reason': reason,
      },
      'messageId': nextId,
    });
    print('mControlSocketIO: _handleP2PClientReject: $content');
    _controlSocketIO.emit(webRTCInfo.displayCode, json.decode(content));
  }

  void _handleStreamPauseSuccess(WebRTCInfo webRTCInfo, String? nextId) {
    var content = json.encode({
      'messageFor': webRTCInfo.displayCode,
      'action': 'pause-present',
      'status': 'ok',
      'extra': {
        'presenter': {
          'id': webRTCInfo.presenterId,
        },
      },
      'messageId': nextId,
      'nextId': GetString.getRandomString(21)
    });
    print('mControlSocketIO: _handleStreamPauseSuccess: $content');
    _controlSocketIO.emit(webRTCInfo.displayCode, json.decode(content));
  }
}
