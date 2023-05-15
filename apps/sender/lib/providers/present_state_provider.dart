import 'dart:async';

import 'package:display_cast_flutter/features/webrtc_helper.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/debug_mode_print.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:uuid/uuid.dart';

enum ViewState {
  idle,
  waitReady,
  selectScreen,
  presentStart,
}

class PresentStateProvider extends ChangeNotifier {
  PresentStateProvider(BuildContext context) {
    _urlGateway = AppConfig.of(context)!.settings.urlGateway;
    _webRTCHelper = WebRTCHelper(AppConfig.of(context)!.settings.urlGetIce);
  }

  ViewState get state => _currentState;
  ViewState _currentState = ViewState.idle;
  Timer? _presentTimer;
  final _userId = (const Uuid()).v4();
  late final String _urlGateway;
  late dynamic _msgDisplay;
  late WebRTCHelper? _webRTCHelper;
  late io.Socket? _socket;

  setViewState(ViewState newViewState) {
    _currentState = newViewState;
    if (_presentTimer != null) {
      _presentTimer!.cancel();
      _presentTimer = null;
    }
    notifyListeners();
  }

  Future<void> presentTo(
      {required String displayCode, required String otp}) async {
    debugModePrint('presentTo: displayCode: $displayCode, otp: $otp');
    _presentTimer = Timer(const Duration(seconds: 30), () {
      presentStop();
    });
    displayCode = displayCode.replaceAll('-', '');

    _socket = io.io(
        _urlGateway,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNew()
            .setQuery({
              "userid": _userId,
              "socketCustomEvent": displayCode,
              "role": "presenter",
            })
            .build());

    _socket?.onConnect((_) {
      debugModePrint('connected to display');

      _socket?.on("display-ready", (msg) async {
        debugModePrint('display-ready: $msg');
        _msgDisplay = msg;
        presentSelectScreen();
      });

      _socket?.emit("create-presenter", {
        "messageFor": displayCode,
        "action": "join",
        "status": "open",
        "extra": {
          "presenter": {
            "id": _userId,
            "name": null,
            "remark": "",
            "status": "",
            "extra": {}
          },
          "display": {"code": displayCode, "token": ""}
        }
      });

      _socket?.emit("join-display", {
        "messageFor": displayCode,
        "action": "join",
        "status": "open",
        "extra": {
          "presenter": {
            "id": _userId,
            "name": null,
            "remark": "",
            "status": "",
            "extra": {}
          },
          "moderator": null,
          "display": {"code": displayCode, "setId": "5tovgl636ge"}
        }
      });
    });
    setViewState(ViewState.waitReady);
  }

  Future<void> presentSelectScreen() async {
    setViewState(ViewState.selectScreen);
  }

  Future<void> presentToTimeout() async {
    setViewState(ViewState.idle);
  }

  Future<void> presentStart({required dynamic selectedSource}) async {
    await _webRTCHelper?.makeCall(
      _msgDisplay['extra']['signal']['url'],
      _msgDisplay['extra']['setClientId'],
      _msgDisplay['extra']['setAllowedPeer'],
      selectedSource,
    );
    setViewState(ViewState.presentStart);
  }

  Future<void> presentStop() async {
    try {
      await _webRTCHelper?.hangUp();

      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
    } catch (e) {
      debugModePrint(e);
    }
    setViewState(ViewState.idle);
  }
}
