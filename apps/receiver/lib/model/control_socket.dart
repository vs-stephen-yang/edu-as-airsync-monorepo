import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:display_flutter/model/bean/display_message.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/model/webrtc_info.dart';
import 'package:display_flutter/native_view/webrtc.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/utility/get_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class ControlSocket {
  static final ControlSocket _instance = ControlSocket._internal();

  //private "Named constructors"
  ControlSocket._internal();

  // passes the instantiation to the _instance object
  factory ControlSocket() => _instance;

  late IO.Socket mControlSocketIO;
  late String _mGatewayUrl, _appVersion;
  final int _maxReconnectAttempts = 5;
  int _displayReconnectAttempts = 0;

  StreamResponse socketResponse = StreamResponse();

  final List<WebRTCNativeViewController> _webRtcController =
      <WebRTCNativeViewController>[];
  WebRTCInfo mWebRTCInfo = WebRTCInfo.getInstance();

  void connect(AppConfig? appConfig) {
    _mGatewayUrl = appConfig!.settings.apiGateway;
    _appVersion = appConfig.appVersion;

    mControlSocketIO = io(
        _mGatewayUrl,
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

    mControlSocketIO
        .onConnect((data) => _printControlSocketLog('connect', data));
    mControlSocketIO
        .onConnecting((data) => _printControlSocketLog('connecting', data));
    mControlSocketIO.onConnectError((data) {
      _printControlSocketLog('connect_error', data);
      if (_displayReconnectAttempts >= _maxReconnectAttempts) {
        _displayReconnectAttempts = 0;

        Future.delayed(const Duration(seconds: 5), () {
          connect(appConfig);
        });
      }
    });
    mControlSocketIO.on(mWebRTCInfo.displayCode, (data) {
      _printControlSocketLog(mWebRTCInfo.displayCode, data);
      _handleDisplayResponse(data);
    });
    mControlSocketIO.on(
        'message', (data) => _printControlSocketLog('message', data));
    mControlSocketIO.onConnectTimeout(
        (data) => _printControlSocketLog('onConnectTimeout', data));
    mControlSocketIO
        .onDisconnect((data) => _printControlSocketLog('disconnect', data));
    mControlSocketIO.onError((data) => _printControlSocketLog('error', data));
    mControlSocketIO.onReconnecting((data) {
      _printControlSocketLog('reconnecting', data);
      _displayReconnectAttempts++;
    });

    mControlSocketIO.connect();
  }

  void disconnectControlSocket() {
    // https://github.com/rikulo/socket.io-client-dart/issues/108
    mControlSocketIO.dispose();
  }

  void addWebRtcController(WebRTCNativeViewController controller) {
    _webRtcController.add(controller);
    controller.channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "stopConnectionTimeoutTimer":
          ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
          break;
        case "sendMessageToControlSocket":
          sendMessageToControlSocket(mWebRTCInfo.displayCode);
          break;
      }
      return;
    });
  }

  void _handleDisplayResponse(dynamic arg) async {
    String? messageFor = arg['messageFor'];
    if (messageFor != null && messageFor == mWebRTCInfo.displayCode) {
      var resp = DisplayMessage.fromJson(arg);
      var userid = resp.userId;
      switch (resp.action) {
        case "set-moderator":
          mWebRTCInfo.moderatorMode = true;
          Extra extra = Extra.fromJson(resp.extra);
          Moderator moderator = Moderator.fromJson(extra.moderator);
          mWebRTCInfo.moderatorId = moderator.id;
          mWebRTCInfo.moderatorName = moderator.name;
          mWebRTCInfo.meetingId = extra.moderatedSessionId;
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
          mWebRTCInfo.isUIStateChanged = true;

          // AppCenterAnalyticsHelper.getInstance().setEventProperties(buildEventProperties());
          ConnectionTimer.getInstance()
              .startRemainingTimeTimer(mWebRTCInfo.remainingTime, () {
            mWebRTCInfo.moderatorMode = false;
            mWebRTCInfo.isModeratorLeave = true;
            mWebRTCInfo.moderatorId = "";
            mWebRTCInfo.moderatorName = "";

            for (WebRTCNativeViewController controller in _webRtcController) {
              controller.channel.invokeMethod('disconnectP2pClient');
            }
          });
          break;
        case "unset-moderator":
          mWebRTCInfo.moderatorMode = false;
          mWebRTCInfo.isModeratorLeave = true;
          mWebRTCInfo.moderatorId = "";
          mWebRTCInfo.moderatorName = "";
          mWebRTCInfo.isUIStateChanged = true;
          mWebRTCInfo.meetingId = "";

          // AppCenterAnalyticsHelper.getInstance().setEventProperties(buildEventProperties());
          ConnectionTimer.getInstance().stopRemainingTimeTimer();
          break;
        case "get-display-state":
          var reply = json.encode({
            'messageFor': mWebRTCInfo.displayCode,
            'action': 'display-state-update',
            'status': 'display-state-update',
            'presentationState': mWebRTCInfo.presentationState.toString(),
            'code': mWebRTCInfo.isShowCode,
            'delegate': mWebRTCInfo.isShowDelegate,
            'uiState': '[]',
            'extra': '[]',
            'messageId': resp.nextId,
            'nextId': GetString.getRandomString(21)
          });
          sendMessageToControlSocket(mWebRTCInfo.displayCode, reply: reply);
          break;
        case "set-ui-state":
          Extra extra = Extra.fromJson(resp.extra);
          mWebRTCInfo.isShowCode = extra.code!;
          mWebRTCInfo.isShowDelegate = extra.delegate!;
          mWebRTCInfo.isUIStateChanged = true;

          sendMessageToControlSocket(mWebRTCInfo.displayCode);
          break;
        case "control":
          Status status = Status.fromJson(resp.status);
          String? statusAction = status.action;
          switch (statusAction) {
            case 'setClient':
              Extra extra = Extra.fromJson(resp.extra);
              mWebRTCInfo.clientId = extra.setClientId;
              mWebRTCInfo.allowId = extra.setAllowedPeer;
              mWebRTCInfo.nextId = resp.nextId;
              mWebRTCInfo.presentationState = PresentationState.waitForStream;
              Presenter presenter = Presenter.fromJson(extra.presenter);
              mWebRTCInfo.presenterId = presenter.id;
              mWebRTCInfo.presenterName = presenter.name;
              mWebRTCInfo.isUIStateChanged = true;

              sendMessageToControlSocket(mWebRTCInfo.displayCode);

              // AppCenterAnalyticsHelper.getInstance().EventStreamStart();
              if (!mWebRTCInfo.moderatorMode) {
                ConnectionTimer.getInstance().startConnectionTimeoutTimer(() {
                  setStateMachine("ConnectionTimeout onFinish");

                  sendMessageToControlSocket(mWebRTCInfo.displayCode,
                      allow: mWebRTCInfo.allowId, action: 'timeout');

                  for (WebRTCNativeViewController controller
                      in _webRtcController) {
                    controller.channel.invokeMethod('disconnectP2pClient');
                  }
                });
              }
              try {
                WebRTCNativeViewController? selectedController;
                if (SplitScreen.splitScreenEnabled.value) {
                  // todo: find unused view to connect
                  for (WebRTCNativeViewController controller
                      in _webRtcController) {
                    if (await controller.channel
                        .invokeMethod("isNotConnected")) {
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
                  print(
                      'selectedController: ${selectedController.channel.name}');
                  var arg = {
                    'clientId': mWebRTCInfo.clientId,
                    'allowId': mWebRTCInfo.allowId,
                  };
                  final String result = await selectedController.channel
                      .invokeMethod('connectP2pClient', arg);
                  handleP2PClientSuccess(result);
                } else {
                  sendMessageToControlSocket(mWebRTCInfo.displayCode,
                      allow: mWebRTCInfo.allowId, action: 'blocked');
                }
              } on PlatformException catch (e) {
                handleP2PClientFailure(e.code, e.message);
                print(e);
              }
              break;
            case "play":
              if (userid == mWebRTCInfo.allowId) {
                try {
                  await _webRtcController[0].channel.invokeMethod("playVideo");
                } on PlatformException catch (e) {
                  print(e);
                }
                // AppCenterAnalyticsHelper.getInstance().EventStreamPlayed();
              }
              break;
            case "stop":
              if (userid == mWebRTCInfo.presenterId) {
                try {
                  await _webRtcController[0].channel.invokeMethod("stopVideo");
                  ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
                } on PlatformException catch (e) {
                  print(e);
                }
                // AppCenterAnalyticsHelper.getInstance().EventStreamStopped();
              }
              break;
          }
          break;
        case "pauseVideo":
          if (userid == mWebRTCInfo.allowId) {
            try {
              await _webRtcController[0].channel.invokeMethod("pauseVideo");
              handleStreamPauseSuccess(mWebRTCInfo.nextId);
            } on PlatformException catch (e) {
              print(e);
            }
            // AppCenterAnalyticsHelper.getInstance().EventStreamPaused();
          }
          break;
        case "resumeVideo":
          if (userid == mWebRTCInfo.allowId) {
            try {
              await _webRtcController[0].channel.invokeMethod("resumeVideo");
            } on PlatformException catch (e) {
              print(e);
            }
            // AppCenterAnalyticsHelper.getInstance().EventStreamResumed();
          }
          break;
      }
    }
  }

  void sendMessageToControlSocket(String? messageFor,
      {String? allow, String? action, String? reply}) {
    if (reply != null) {
      print('sendMessageToControlSocket reply: $reply');
      mControlSocketIO.emit(messageFor!, json.decode(reply));
    } else if (action != null) {
      var content = json.encode({
        'messageFor': allow,
        'action': action,
        'display': messageFor,
        'streamer': _appVersion,
        'capacities': '[]'
      });

      print('sendMessageToControlSocket action: $content');
      mControlSocketIO.emit(messageFor!, json.decode(content));
    } else {
      var content = json.encode({
        'messageFor': mWebRTCInfo.displayCode,
        'action': 'display-state-update',
        // 'status': 'display-state-update',
        'extra': {
          'uiState': {
            'code': mWebRTCInfo.isShowCode,
            'delegate': mWebRTCInfo.isShowDelegate,
          },
          'presentationState': mWebRTCInfo.presentationState.name,
        },
        'messageId': GetString.getRandomString(21),
        'nextId': GetString.getRandomString(21),
      });
      print('sendMessageToControlSocket: $content');
      mControlSocketIO.emit(messageFor!, json.decode(content));
    }
  }

  void _printControlSocketLog(String? event, dynamic args) {
    print("mControlSocketIO: $event ${args.toString()}");
  }

  var mStateMachineHistory = Queue<String>();
  static ValueNotifier<String> stateMachine = ValueNotifier('');

  void setStateMachine(String state) {
    print('_setStateMachine: $state');
    String msg = "${GetString.getShortTimeString} $state";
    var buffer = StringBuffer();
    buffer.write("\nHistory:");
    for (String s in mStateMachineHistory) {
      buffer.write("\n$s");
    }
    stateMachine.value = buffer.toString();

    if (mStateMachineHistory.length >= 10) {
      mStateMachineHistory.removeLast();
    }
    mStateMachineHistory.addFirst(msg);
  }

  void handleP2PClientSuccess(String result) {
    setStateMachine("connect() onSuccess: $result");
    var content = json.encode({
      'messageFor': mWebRTCInfo.displayCode,
      'action': 'control',
      'status': {'action': 'setClient', 'status': 'ready'},
      'extra': {
        'setClientId': mWebRTCInfo.clientId,
        'setAllowedPeer': mWebRTCInfo.allowId,
        'streamer': _appVersion,
        'platform': 'android',
        'capacities': [],
        'code': mWebRTCInfo.displayCode,
      },
      'direction': 'out',
      'messageId': mWebRTCInfo.nextId,
      'nextId': GetString.getRandomString(21)
    });
    sendMessageToControlSocket(mWebRTCInfo.displayCode,
        reply: content.toString());
  }

  void handleP2PClientFailure(String code, String? message) {
    setStateMachine("connect() onFailure: $code $message");
  }

  void handleStreamPauseSuccess(String? messageId) {
    var content = json.encode({
      'messageFor': mWebRTCInfo.displayCode,
      'userid': mWebRTCInfo.allowId,
      'action': 'pauseVideo',
      'status': 'pauseVideo-ok',
      'messageId': messageId,
      'nextId': GetString.getRandomString(21)
    });
    sendMessageToControlSocket(mWebRTCInfo.displayCode,
        reply: content.toString());
  }
}

class StreamResponse {
  final _response = BehaviorSubject<Map>();
  final _errorResponse = BehaviorSubject<Exception>();

  void addResponseMessage(message) {
    _response.add(message);
  }

  void addErrorResponseMessage(message) {
    _response.add(message);
  }

  Stream<Map> get getResponse => _response.stream;

  Stream<Exception> get getErrorResponse => _errorResponse.stream;

  void dispose() {
    _response.close();
    _errorResponse.close();
  }
}
