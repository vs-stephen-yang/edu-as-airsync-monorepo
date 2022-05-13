import 'dart:convert';
import 'dart:developer';

import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/utility/random_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ControlSocket extends ChangeNotifier {
  late Socket mControlSocketIO;
  late String _mGatewayUrl, displayCode, instanceId, token;
  final int _MAX_RECONNECT_ATTEMPTS = 5;
  int _displayReconnectAttempts = 0;

  static ControlSocket _instance = ControlSocket.internal();

  static ControlSocket getInstance() {
    return _instance;
  }

  ControlSocket.internal();

  void connect() {
    // TODO:mDisplaySocketReConnect
    // mDisplaySocketReConnect.setValue(false);

    mControlSocketIO = io(
        _mGatewayUrl,
        OptionBuilder()
            .enableForceNew()
            .enableReconnection()
            .setReconnectionAttempts(_MAX_RECONNECT_ATTEMPTS)
            .setQuery({
          'socketCustomEvent': displayCode,
          'role': 'display',
          'deviceId': instanceId,
          'token': token
        }).build());

    mControlSocketIO
        .onConnect((data) => _printControlSocketLog('connect', data));
    mControlSocketIO
        .onConnecting((data) => _printControlSocketLog('connecting', data));
    mControlSocketIO.onConnectError((data) => () {
          _printControlSocketLog('connect_error', data);
          if (_displayReconnectAttempts >= _MAX_RECONNECT_ATTEMPTS) {
            _displayReconnectAttempts = 0;

            Future.delayed(const Duration(seconds: 5), () {
              // TODO:mDisplaySocketReConnect
              // mDisplaySocketReConnect.postValue(true);
              connect();
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
        displayCode, (data) => () {
              _printControlSocketLog(displayCode, data);
              // TODO:handleDisplayResponse
              // handleDisplayResponse(data);
            });
    mControlSocketIO.connect();
  }

  void _disconnectControlSocket() {
    mControlSocketIO.disconnect();
  }

  void sendMessageToControlSocket(BuildContext context, String messageFor,
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
      mControlSocketIO.emit(messageFor, reply);
    } else if (action != null) {
      var content = json.encode({
        'messageFor': allow,
        'action': action,
        'display': messageFor,
        'streamer': AppConfig.of(context)?.appVersion,
        'capacities': '[]'
      });

      log('sendMessageToControlSocket: $content');
      mControlSocketIO.emit(messageFor, content);
    } else {
      var content = jsonEncode({
        'messageFor': displayCode,
        'action': 'display-state-update',
        // 'action': 'display-state-update',
        'code': showCode,
        'delegate': showDelegate,
        'uiState': String,
        'presentationState': presentationState,
        'extra': String,
        'messageId': RandomString.getRandomString(21),
        'nextId': RandomString.getRandomString(21),
      });
      log('sendMessageToControlSocket: $content');
      mControlSocketIO.emit(messageFor, content);
    }
  }

  void _printControlSocketLog(String event, dynamic args) {
    log("mDisplaySocketIO: $event $args");
  }

}
