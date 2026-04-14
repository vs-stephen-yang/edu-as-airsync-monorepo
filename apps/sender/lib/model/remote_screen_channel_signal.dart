import 'dart:async';
import 'dart:convert';

import 'package:display_cast_flutter/utilities/log.dart';
import 'package:events2/events2.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:ion_sdk_flutter/flutter_ion.dart';
import 'package:uuid/uuid.dart';

class RemoteScreenChannelSignal extends Signal {
  // send a signal message to the peer
  final Function(String message) _sendMessageToPeer;

  final _jsonDecoder = const JsonDecoder();
  final _jsonEncoder = const JsonEncoder();

  final Uuid _uuid = const Uuid();

  // TODO: remove EventEmitter since it's not actively maintained
  final EventEmitter _emitter = EventEmitter();

  RemoteScreenChannelSignal(
    this._sendMessageToPeer,
  );

  // send a signal message to the peer
  void _send(String msg) {
    _sendMessageToPeer(msg);

    log.info('RemoteScreenChannelSignal: Send $msg');
  }

  // receive a signal message from the peer
  void onPeerMessage(String msg) {
    log.info('RemoteScreenChannelSignal: Received $msg');

    try {
      final resp = _jsonDecoder.convert(msg);

      if (resp['method'] != null || resp['result'] != null) {
        if (resp['method'] == 'offer') {
          onnegotiate?.call(
            RTCSessionDescription(
              resp['params']['sdp'],
              resp['params']['type'],
            ),
          );
        } else if (resp['method'] == 'trickle') {
          ontrickle?.call(Trickle.fromMap(resp['params']));
        } else {
          _emitter.emit('message', resp);
        }
      } else if (resp['error'] != null) {
        final code = resp['error']['code'];
        final message = resp['error']['message'];

        log.severe(
            'RemoteScreenChannelSignal: error: code => $code, message => $message');
      }
    } catch (e) {
      log.severe('RemoteScreenChannelSignal: onmessage: err => $e');
    }
  }

  @override
  void close() {}

  @override
  Future<void> connect() async {
    onready?.call();
  }

  @override
  Future<RTCSessionDescription> join(
    String sid,
    String uid,
    RTCSessionDescription offer,
  ) {
    Completer completer = Completer<RTCSessionDescription>();
    final id = _uuid.v4();

    _send(_jsonEncoder.convert(<String, dynamic>{
      'method': 'join',
      'params': {
        'sid': sid,
        'uid': uid,
        'offer': offer.toMap(),
      },
      'id': id,
    }));

    Function(dynamic) handler;
    handler = (resp) {
      if (resp['id'] == id) {
        completer.complete(
          RTCSessionDescription(
            resp['result']['sdp'],
            resp['result']['type'],
          ),
        );
      }
    };
    _emitter.once('message', handler);
    return completer.future as Future<RTCSessionDescription>;
  }

  @override
  Future<RTCSessionDescription> offer(RTCSessionDescription offer) {
    Completer completer = Completer<RTCSessionDescription>();
    var id = _uuid.v4();
    _send(_jsonEncoder.convert(<String, dynamic>{
      'method': 'offer',
      'params': {
        'desc': offer.toMap(),
      },
      'id': id,
    }));

    Function(dynamic) handler;
    handler = (resp) {
      if (resp['id'] == id) {
        completer.complete(
          RTCSessionDescription(
            resp['result']['sdp'],
            resp['result']['type'],
          ),
        );
      }
    };
    _emitter.once('message', handler);
    return completer.future as Future<RTCSessionDescription>;
  }

  @override
  void answer(RTCSessionDescription answer) {
    _send(_jsonEncoder.convert(<String, dynamic>{
      'method': 'answer',
      'params': {
        'desc': answer.toMap(),
      },
    }));
  }

  @override
  void trickle(Trickle trickle) {
    _send(_jsonEncoder.convert(<String, dynamic>{
      'method': 'trickle',
      'params': trickle.toMap(),
    }));
  }
}
