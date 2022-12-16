import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:display_flutter/model/bean/moderator_peer_message.dart';
import 'package:display_flutter/model/bean/moderator_role.dart';
import 'package:display_flutter/model/stream/stream_response.dart';
import 'package:display_flutter/model/stream/stream_socket.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/utility/api_response_factory.dart';
import 'package:display_flutter/utility/print_in_debug.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:uuid/uuid.dart';

final moderatorSocket = ModeratorSocket();

class ModeratorSocket {
  StreamSocket streamSocket = StreamSocket();
  StreamResponse setModeratorResponse = StreamResponse();
  bool socketHasNewData = false;
  bool peerListHasNewData = false;
  bool setModeratorHasNewData = false;
  bool unsetModeratorHasNewData = false;
  late Socket socket;
  bool socketInit = false;
  late String gatewayUrl;
  Uuid uuid = const Uuid();
  late ModeratorRole moderator;

  ModeratorRole createModerator(String name, String id) {
    var name1 = name.isNotEmpty ? name : 'name';
    var id1 = id.isNotEmpty ? id : uuid.v4();
    printInDebug('moderator[name: $name1 id:$id1]', type: runtimeType);
    return moderator = ModeratorRole(
        id: id1, name: name1, remark: 'remark', status: 'sss', extra: {});
  }

  Socket connectAndListen(BuildContext context) {
    printInDebug('ConnectionBloc connectAndListen', type: runtimeType);
    gatewayUrl = AppConfig.of(context)!.settings.apiGateway;
    socket = io(
        gatewayUrl,
        OptionBuilder()
            .setQuery({'socketCustomEvent': moderator.id, 'role': 'moderator'})
            .setTransports(['websocket'])
            .enableForceNew()
            .build());
    socketInit = true;
    socket.onConnect((_) {
      socket.emit('create-moderator', json.encode(moderator));
      log('onConnect: ${socket.id}');
    });
    socket.onConnectError((data) {
      log('error: $data');
    });
    socket.onDisconnect((_) {
      log('socket disconnect');
    });
    setupCustomEventLog();
    setupCustomEventStreamSocket();
    setupCustomEventStreamPeerlist();
    return socket;
  }

  disconnect() {
    printInDebug('ConnectionBloc disconnect', type: runtimeType);
    if (socketInit) socket.dispose();
  }

  setupCustomEventLog() {
    var logEvent = [
      'fromServer',
      'message',
    ];
    for (var element in logEvent) {
      socket.on(element, (_) {
        log('$element: $_');
      });
    }
  }

  static const String cmdDismiss = 'dismiss';
  static const String cmdEvent = 'event';
  static const String cmdUpdateDisplayList = 'update_display_list';
  static const String cmdDisplayStateUpdate = 'display-state-update';
  static const String cmdUnsetModerator = 'unset-moderator';

  setupCustomEventStreamSocket() {
    var socketEvent = [
      cmdDismiss,
      cmdEvent,
      cmdUpdateDisplayList,
      cmdDisplayStateUpdate,
      cmdUnsetModerator,
    ];
    for (var element in socketEvent) {
      socket.on(element, (_) async {
        log('$element: $_');
        if (element == cmdUnsetModerator) {
          setModeratorResponse.addResponseMessage(_);
          unsetModeratorHasNewData = true;
        } else {
          streamSocket.addResponseMessage(_);
          socketHasNewData = true;
        }
      });
    }
  }

  setupCustomEventStreamPeerlist() {
    var peerlistEvent = [
      'peerlist',
    ];
    for (var element in peerlistEvent) {
      socket.on(element, (_) {
        log('$element: $_');
        setModeratorResponse.addResponseMessage(_);
        peerListHasNewData = true;
      });
    }
  }

  peerAction(action, peer, displayResponse) {
    var message = ModeratorPeerMessage(
        messageFor: moderator.id,
        action: action,
        status: peer['status'],
        extra: {'presenter': peer['presenter'], 'display': displayResponse},
        messageId: uuid.v4(),
        nextId: uuid.v4());
    socket.emit('peer-action', message.toJson());
    printInDebug('peer-action: ${message.toJson()}', type: runtimeType);
  }

  sendPeerListRequest(code) {
    socket.emit('get-peer-list', {
      'messageFor': moderator.id,
      'action': 'get-peer-list',
      'extra': {
        'display': {'code': code},
        'moderator': moderator
      }
    });
  }

  getDisplayList() {
    socket.emit('get-displays', {
      'messageFor': moderator.id,
      'action': 'get-displays',
    });
  }

  getDisplayState(String code) {
    socket.emit('get-display-state', {
      'messageFor': code,
      'action': 'get-display-state',
    });
  }

  Future switchUI(displayCode, code, delegate) async {
    socket.emit('set-ui-state', {
      'messageFor': displayCode,
      'action': 'set-ui-state',
      'status': '',
      'extra': {
        'code': code,
        'delegate': delegate,
      },
    });
  }

  Future unBindFromDisplay(code, token) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var api = Uri.parse('$gatewayUrl/presentation/displays/moderator/unbind');
    printInDebug('api: $api', type: runtimeType);
    var request = http.Request('PATCH', api);
    request.body = json.encode({'code': code, 'moderator': moderator});
    request.headers.addAll(headers);
    http.StreamedResponse streamedResponse = await request.send();
    try {
      dynamic response =
          await ApiResponseFactory.returnResponse(streamedResponse);
      log('unBindFromDisplay: $response');
      setModeratorResponse.addResponseMessage(response);
      unsetModeratorHasNewData = true;
      return response;
    } catch (err) {
      printInDebug('err: $err', type: runtimeType);
      setModeratorResponse.addResponseMessage({0 as dynamic: err});
      unsetModeratorHasNewData = true;
    }
  }

  Future bindToDisplay(code, otp, token) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var api = Uri.parse('$gatewayUrl/presentation/displays/moderator');
    printInDebug('bindToDisplay api: $api', type: runtimeType);
    var request = http.Request('POST', api);
    request.body =
        json.encode({'code': code, 'otp': otp, 'moderator': moderator});
    request.headers.addAll(headers);
    http.StreamedResponse streamedResponse = await request.send();
    try {
      dynamic response =
          await ApiResponseFactory.returnResponse(streamedResponse);
      printInDebug('bindToDisplay: $response', type: runtimeType);
      setModeratorResponse.addResponseMessage(response);
      setModeratorHasNewData = true;

      getDisplayState(code);
      return response;
    } catch (err) {
      printInDebug('bindToDisplay err: $err', type: runtimeType);
      setModeratorResponse.addResponseMessage({0 as dynamic: err});
      setModeratorHasNewData = true;
      rethrow;
    }
  }

  Future queryDisplay(code) async {
    var headers = {'Content-Type': 'application/json'};
    var api = Uri.parse('$gatewayUrl/presentation/displays?code=$code');
    printInDebug('api: $api', type: runtimeType);
    var request = http.Request('GET', api);
    request.headers.addAll(headers);
    http.StreamedResponse streamedResponse = await request.send();
    try {
      dynamic response =
          await ApiResponseFactory.returnResponse(streamedResponse);
      log('queryDisplay: $response');
      setModeratorResponse.addResponseMessage(response);
      setModeratorHasNewData = true;

      getDisplayState(code);
      sendPeerListRequest(code);
      return response;
    } catch (err) {
      printInDebug('err: $err', type: runtimeType);
      setModeratorResponse.addResponseMessage({0 as dynamic: err});
      setModeratorHasNewData = true;
      rethrow;
    }
  }

  bool controlDisplay() {
    if (!socket.connected) {
      return false;
    }
    return true;
  }

  void dispose() {
    streamSocket.dispose();
    setModeratorResponse.dispose();
  }
}
