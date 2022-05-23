import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:display_flutter/model/webrtc_Info.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/utility/get_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class ControlSocket {
  late IO.Socket mControlSocketIO;
  late String _mGatewayUrl, _appVersion;
  final int _MAX_RECONNECT_ATTEMPTS = 5;
  int _displayReconnectAttempts = 0;
  StreamResponse socketResponse = StreamResponse();

  WebRTCInfo mWebRTCInfo = WebRTCInfo.getInstance();

  static ControlSocket _instance = ControlSocket.internal();

  static ControlSocket getInstance() {
    return _instance;
  }

  ControlSocket.internal();

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
            .setReconnectionAttempts(_MAX_RECONNECT_ATTEMPTS)
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
    mControlSocketIO.onConnectError((data) => () {
          _printControlSocketLog('connect_error', data);
          if (_displayReconnectAttempts >= _MAX_RECONNECT_ATTEMPTS) {
            _displayReconnectAttempts = 0;

            Future.delayed(const Duration(seconds: 5), () {
          connect(appConfig);
            });
      }
    });
    mControlSocketIO
        .onDisconnect((data) => _printControlSocketLog('disconnect', data));
    mControlSocketIO.onError((data) => _printControlSocketLog('error', data));
    mControlSocketIO.on(
        'message', (data) => _printControlSocketLog('message', data));
    mControlSocketIO.onReconnecting((data) => () {
      _printControlSocketLog('reconnecting', data);
      _displayReconnectAttempts++;
    });
    mControlSocketIO.on(
        mWebRTCInfo.displayCode,
        (data) => () {
              _printControlSocketLog(mWebRTCInfo.displayCode, data);
              _handleDisplayResponse(data);
            });
    mControlSocketIO.connect();
  }

  void _handleDisplayResponse(dynamic arg) {
    Map response = jsonDecode(arg as String);
    String messageFor = response['messageFor'];
    if (messageFor.isNotEmpty && messageFor == mWebRTCInfo.displayCode) {
      String action = response['action'];
      String userid = response['userid'];
      Map<String, dynamic> extra = response['extra'];

      switch (action) {
        case "set-moderator":
          mWebRTCInfo.moderatorMode = true;
          Map<String, dynamic> moderator = response['moderator'];
          String id = moderator['id'];
          mWebRTCInfo.moderatorId = moderator['id'];
          mWebRTCInfo.moderatorName = moderator['name'];
          mWebRTCInfo.meetingId = extra['moderatedSessionId'];
          int remainingTime =
              extra['endTine'] - DateTime.now().millisecondsSinceEpoch;
          mWebRTCInfo.remainingTime = remainingTime;
          log('Remaining time: $remainingTime');
          List<dynamic> checkPoints = extra['checkPoints'];
          int duration = extra['durationRemaining'];
          for (int i = 0; i < checkPoints.length; i++) {
            if ((duration - checkPoints[i]) > 1000) {
              int point = ((duration - checkPoints[i]) / 1000) as int;
              mWebRTCInfo.remainingTimeCheckPoints.add(point);
              log('checkpoint: $point');
            }
          }
          mWebRTCInfo.isUIStateChanged = true;

          // AppCenterAnalyticsHelper.getInstance().setEventProperties(buildEventProperties());
          socketResponse.addResponseMessage(response);
          break;
        case "unset-moderator":
          mWebRTCInfo.moderatorMode = false;
          mWebRTCInfo.isModeratorLeave = true;
          mWebRTCInfo.moderatorId = "";
          mWebRTCInfo.moderatorName = "";
          mWebRTCInfo.isUIStateChanged = true;
          mWebRTCInfo.meetingId = "";

          // AppCenterAnalyticsHelper.getInstance().setEventProperties(buildEventProperties());
          socketResponse.addResponseMessage(response);
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
            'messageId': '${response['nextId']}',
            'nextId': GetString.getRandomString(21)
          });
          sendMessageToControlSocket(_appVersion, mWebRTCInfo.displayCode,
              reply: reply);
          break;
        case "set-ui-state":
          mWebRTCInfo.isShowCode = extra['code'];
          mWebRTCInfo.isShowDelegate = extra['delegate'];
          mWebRTCInfo.isUIStateChanged = true;

          sendMessageToControlSocket(_appVersion, mWebRTCInfo.displayCode);
          break;
        case "control":
          Map<String, dynamic> status = response['status'];
          if (status != null) {
            String statusAction = status['action'];
            switch (statusAction) {
              case 'setClient':
                String clientId = extra['setClientId'];
                String allowId = extra['setAllowedPeer'];
                if (clientId.isEmpty) {
                  mWebRTCInfo.presentationState =
                      ePresentationState.waitForStream;
                  Map<String, dynamic> presenter = extra['presenter'];
                  mWebRTCInfo.presenterId = presenter['id'];
                  mWebRTCInfo.presenterName = presenter['name'];
                  mWebRTCInfo.isUIStateChanged = true;

                  sendMessageToControlSocket(
                      _appVersion, mWebRTCInfo.displayCode);

                  // AppCenterAnalyticsHelper.getInstance().EventStreamStart();
                  socketResponse.addResponseMessage(response);
                }
                break;
              case "play":
                if (userid == mWebRTCInfo.allowId) {
                  socketResponse.addResponseMessage(response);
                  // streamPlay();
                  // AppCenterAnalyticsHelper.getInstance().EventStreamPlayed();
                }
                break;
              case "stop":
                if (userid == mWebRTCInfo.allowId) {
                  socketResponse.addResponseMessage(response);
                  // AppCenterAnalyticsHelper.getInstance().EventStreamStopped();
                }
                break;
            }
          } else {
            sendMessageToControlSocket(_appVersion, mWebRTCInfo.displayCode,
                allow: userid, action: "denied");
          }
          break;
        case "pauseVideo":
          String nextId = response['nextId'];
          if (userid == mWebRTCInfo.allowId) {
            socketResponse.addResponseMessage(response);
            // streamPause(nextId);
            // AppCenterAnalyticsHelper.getInstance().EventStreamPaused();
          }
          break;
        case "resumeVideo":
          if (userid == mWebRTCInfo.allowId) {
            socketResponse.addResponseMessage(response);
            // streamResume();
            // AppCenterAnalyticsHelper.getInstance().EventStreamResumed();
          }
          break;
      }
    }
  }

  void _disconnectControlSocket() {
    mControlSocketIO.disconnect();
  }

  void sendMessageToControlSocket(String? appVersion, String? messageFor,
      {String? allow,
      String? action,
      String? reply,
      bool? showCode,
      bool? showDelegate,
      String? presentationState}) {
    if (mControlSocketIO == null) {
      log("mDisplaySocketIO is not established.");
      return;
    }

    if (reply != null) {
      log("sendMessageToControlSocket: ${reply.toString()}");
      mControlSocketIO.emit(messageFor!, reply);
    } else if (action != null) {
      var content = json.encode({
        'messageFor': allow,
        'action': action,
        'display': messageFor,
        'streamer': appVersion, //AppConfig.of(context)?.appVersion,
        'capacities': '[]'
      });

      log('sendMessageToControlSocket: $content');
      mControlSocketIO.emit(messageFor!, content);
    } else {
      var content = jsonEncode({
        'messageFor': mWebRTCInfo.displayCode,
        'action': 'display-state-update',
        'status': 'display-state-update',
        'code': showCode,
        'delegate': showDelegate,
        'uiState': String,
        'presentationState': presentationState,
        'extra': String,
        'messageId': GetString.getRandomString(21),
        'nextId': GetString.getRandomString(21),
      });
      log('sendMessageToControlSocket: $content');
      mControlSocketIO.emit(messageFor!, content);
    }
  }

  void _printControlSocketLog(String? event, dynamic args) {
    log("mDisplaySocketIO: $event ${args.toString()}");
  }

  var mStateMachineHistory = Queue<String>();
  static ValueNotifier<String> stateMachine = ValueNotifier('');

  void setStateMachine(String state) {
    log('_setStateMachine: $state');
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
}

class StreamResponse {
  final _response = BehaviorSubject<Map>();
  final _error_response = BehaviorSubject<Exception>();

  void addResponseMessage(message) {
    _response.add(message);
  }

  void addErrorResponseMessage(message) {
    _response.add(message);
  }

  Stream<Map> get getResponse => _response.stream;

  Stream<Exception> get getErrorResponse => _error_response.stream;

  void dispose() {
    _response.close();
    _error_response.close();
  }
}