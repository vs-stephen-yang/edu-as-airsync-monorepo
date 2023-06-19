import 'dart:async';
import 'dart:convert';

import 'package:display_cast_flutter/features/webrtc_helper.dart';
import 'package:display_cast_flutter/model/message.dart';
import 'package:display_cast_flutter/model/moderator.dart';
import 'package:display_cast_flutter/model/presenter.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/debug_mode_print.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

enum ViewState {
  idle,
  waitReady,
  selectScreen,
  presentStart,

  //moderator
  moderatorIdle,
  moderatorWait,
}

class PresentStateProvider extends ChangeNotifier {
  PresentStateProvider(BuildContext context) {
    _urlGateway = AppConfig.of(context)!.settings.urlGateway;
    _webRTCHelper = WebRTCHelper(AppConfig.of(context)!.settings.urlGetIce);
  }

  ViewState get state => _currentState;
  ViewState _currentState = ViewState.idle;
  Timer? _presentTimer;
  late final String _urlGateway;
  late dynamic _msgDisplay;
  late WebRTCHelper? _webRTCHelper;
  late io.Socket? _socket;

  Presenter? presenter = Presenter(id: const Uuid().v4());
  Moderator? moderator;
  String? displayCode;
  String? otp;

  setViewState(ViewState newViewState) {
    _currentState = newViewState;
    if (_presentTimer != null) {
      _presentTimer!.cancel();
      _presentTimer = null;
    }
    notifyListeners();
  }

  /// 2023Q2, Presenter generates OTP.
  /// 2023Q3, it's possible to be generated OTP from this Send App. And this should be removed.
  Future<bool> checkDisplayOTP({required String? displayCode, required String? otp}) async {
    var api = Uri.parse('$_urlGateway/presentation/displays/?code=$displayCode&otp=$otp');
    var response = await http.get(api);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> checkModeratorOTP({required String displayCode, required String otp}) async {
    print('zz checkModeratorOTP');
    var api = Uri.parse('$_urlGateway/presentation/displays/moderator?code=$displayCode&otp=$otp');
    var response = await http.get(api);
    switch (response.statusCode) {
      case 200:
      case 201:
        // 有開moderator 有往下跑 顯示UI
        Map<String, dynamic> body = jsonDecode(response.body);
        moderator = Moderator.fromJson(body);
        this.displayCode = displayCode;
        this.otp = otp;
        setViewState(ViewState.moderatorIdle);
        notifyListeners();
        print('zz checkOTP 200 ${response.body} ${moderator?.id}');
        // break;
      return true;
      case 204:
        // 沒開moderator 有往下跑
        this.displayCode = displayCode;
        this.otp = otp;
        print('zz checkOTP 204');
        // break;
      return true;
      case 403:
      // 403 -> Reach maximum presenters
      case 404:
      // 404 -> sendToV1
      case 406:
        // 有開Moderator otp錯誤 沒有往下跑
        // 406 -> Invalid one time password
        // break;
      return false;
      default:
        //log
        // break;
      return false;
    }
    // return response;
  }

  Future<void> presentTo(
      {required String? displayCode, required String otp}) async {
    debugModePrint('presentTo: displayCode: $displayCode, otp: $otp');
    _presentTimer = Timer(const Duration(seconds: 30), () {
      presentEnd();
    });

    _socket = io.io(
        _urlGateway,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNew()
            .setQuery({
              "userid": presenter?.id,
              "socketCustomEvent": displayCode,
              "role": "presenter",
            })
            .build());
    
    _socket?.onConnecting((data) => print('zz onConnecting ${data.toString()}'));

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
          "presenter": presenter?.toJson(),
          "display": {"code": displayCode, "token": ""}
        }
      });

      _socket?.emit("join-display", {
        "messageFor": displayCode,
        "action": "join",
        "status": "open",
        "extra": {
          "presenter": presenter?.toJson(),
          "moderator": moderator?.toJson(),
          "display": {"code": displayCode, "setId": "5tovgl636ge"},
          "signal": {
            "url": "",
          }
        }
      });
    });

    _socket?.on("display-state-update", (msg) async {
      debugModePrint('display-state-update: $msg');
    });

    _socket?.on('update-display-state', (msg) async {
      debugModePrint('update-display-state: $msg');
    });

    _socket?.on("presenter-peer-action", (msg) async {
      debugModePrint('presenter-peer-action: $msg');
      Message message = Message.fromJson(msg);
      if (message.action == 'remove') {
        // stream end
        presentEnd();
      }
      if (message.action == 'stopVideo') {
        // stream stop
        presentStop();
      }
      if (message.action == 'pause' && message.status == 'pause') {
        //stream pause
        presentPause();
      }
      if (message.action == 'resume' && message.status == 'pause') {
        // stream resume
        presentResume();
      }
    });

    _socket?.on('reject-present', (msg) {
      print('zz reject-present $msg');
    });

    _socket?.on('dismiss', (msg) {
      print('zz _socket.dismiss $msg');
    });

    _socket?.on('set-moderator', (msg) {
      print('zz _socket.set-moderator $msg');
      if (msg['action'] == 'set-moderator') {
        moderator = Moderator.fromJson(msg['extra']['moderator']);
        _socket?.emit('join-display', {
          "messageFor": displayCode,
          "action": "join",
          "status": "open",
          "extra": {
            "presenter": presenter?.toJson(),
            "moderator": moderator?.toJson(),
            "display": {"code": displayCode, "setId": "5tovgl636ge"},
            "signal": {
              "url": '',
            }
          }
        });
      }
    });

    _socket?.on('unset-moderator', (msg) => {
      if(msg['action'] == 'unset-moderator') {
        // TODO: 導回首頁
      }
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

  Future<void> presentEnd() async {
    try {
      await _webRTCHelper?.hangUp();

      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
    } catch (e) {
      debugModePrint(e);
    }
    resetMessage();
    setViewState(ViewState.idle);
  }

  Future<void> presentStop() async {
    // handle stream
    _webRTCHelper?.streamStop();

    setViewState(ViewState.moderatorWait);
  }

  Future<void> presentPause() async {
    _socket?.emit('presenter-action', {
      "action": "pause",
      "extra": {
        "presenter": presenter?.toJson(),
        "moderator": moderator?.toJson(),
        "display": {"code": displayCode, "setId": "5tovgl636ge"},
      }
    });

    // handle stream
    _webRTCHelper?.streamPause();
  }

  Future<void> presentResume() async {
    _socket?.emit('presenter-action', {
      "action": "resume",
      "extra": {
        "presenter": presenter?.toJson(),
        "moderator": moderator?.toJson(),
        "display": {"code": displayCode, "setId": "5tovgl636ge"},
      }
    });

    // handle stream
    _webRTCHelper?.streamResume();
  }

  resetMessage() {
    presenter = Presenter(id: const Uuid().v4());
    moderator = null;
  }
}
