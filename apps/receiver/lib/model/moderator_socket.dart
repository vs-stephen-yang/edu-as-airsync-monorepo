import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:display_flutter/model/stream/StreamPeerlist.dart';
import 'package:display_flutter/model/stream/StreamResponse.dart';
import 'package:display_flutter/model/stream/StreamSocket.dart';
import 'package:display_flutter/model/bean/moderator_peer_message.dart';
import 'package:display_flutter/model/bean/moderator_role.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/utility/ApiResponseFactory.dart';
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
    var _name = name.isNotEmpty ? name : 'name';
    var _id = id.isNotEmpty ? id : uuid.v4();
    print('moderator[name: $_name id:$_id]');
    return moderator = ModeratorRole(
        id: _id, name: _name, remark: 'remark', status: 'sss', extra: {});
  }

  Socket connectAndListen(BuildContext context) {
    print('ConnectionBloc connectAndListen');
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
    print('ConnectionBloc disconnect');
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

  static const String DISMISS = 'dismiss';
  static const String EVENT = 'event';
  static const String UPDATE_DISPLAY_LIST = 'update_display_list';
  static const String DISPLAY_STATE_UPDATE = 'display-state-update';
  static const String UNSET_MODERATOR = 'unset-moderator';

  setupCustomEventStreamSocket() {
    var socketEvent = [
      DISMISS,
      EVENT,
      UPDATE_DISPLAY_LIST,
      DISPLAY_STATE_UPDATE,
      UNSET_MODERATOR,
    ];
    for (var element in socketEvent) {
      socket.on(element, (_) async {
        log('$element: $_');
        if (element == UNSET_MODERATOR) {
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
    print('peer-action: ${message.toJson()}');
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
      'status': "",
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
    print('api: $api');
    var request = http.Request('PATCH', api);
    request.body = json.encode({'code': code, 'moderator': moderator});
    request.headers.addAll(headers);
    http.StreamedResponse streamedResponse = await request.send();
    try {
      dynamic response =
          await ApiResponseFactory.returnResponse(streamedResponse);
      log('unBindFromDisplay: $response');
      setModeratorResponse.addResponseMessage(response);
      setModeratorHasNewData = true;
      return response;
    } catch (err) {
      print('err: $err');
      setModeratorResponse.addResponseMessage({0 as dynamic: err});
      setModeratorHasNewData = true;
    }
  }

  Future bindToDisplay(code, otp, token) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var api = Uri.parse('$gatewayUrl/presentation/displays/moderator');
    print('bindToDisplay api: $api');
    var request = http.Request('POST', api);
    request.body =
        json.encode({'code': code, 'otp': otp, 'moderator': moderator});
    request.headers.addAll(headers);
    http.StreamedResponse streamedResponse = await request.send();
    try {
      dynamic response =
          await ApiResponseFactory.returnResponse(streamedResponse);
      print('bindToDisplay: $response');
      setModeratorResponse.addResponseMessage(response);
      setModeratorHasNewData = true;

      getDisplayState(code);
      return response;
    } catch (err) {
      print('bindToDisplay err: $err');
      setModeratorResponse.addResponseMessage({0 as dynamic: err});
      setModeratorHasNewData = true;
    }
  }

  Future queryDisplay(code) async {
    var headers = {'Content-Type': 'application/json'};
    var api = Uri.parse('$gatewayUrl/presentation/displays?code=$code');
    print('api: $api');
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
      print('err: $err');
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
