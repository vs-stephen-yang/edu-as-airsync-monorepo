import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:display_cast_flutter/features/webrtc_helper.dart';
import 'package:display_cast_flutter/features/webrtc_helper_v1.dart';
import 'package:display_cast_flutter/model/displayer.dart';
import 'package:display_cast_flutter/model/message.dart';
import 'package:display_cast_flutter/model/moderator.dart';
import 'package:display_cast_flutter/model/presenter.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/debug_mode_print.dart';
import 'package:display_cast_flutter/widgets/present_select_screen.dart';
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
  moderatorStart,

  settings,
  language,
}

class PresentStateProvider extends ChangeNotifier {
  PresentStateProvider(BuildContext context) {
    _urlGateway = AppConfig.of(context)!.settings.urlGateway;
    _urlIce = AppConfig.of(context)!.settings.urlGetIce;
  }

  ViewState get state => _currentState;
  ViewState _currentState = ViewState.idle;
  Timer? _presentTimer;
  late final String _urlGateway, _urlIce;
  late dynamic _msgDisplay;
  WebRTCHelper? _webRTCHelper;
  io.Socket? _socket;

  Presenter? presenter = Presenter(id: const Uuid().v4());
  Moderator? moderator;
  Displayer? displayer;
  String? displayCode;
  String? otp;
  String? setId;
  bool _v1 = false;
  bool _touchBack = false;
  bool get touchBack => _touchBack;
  bool _exceedMaximumPresenters = false;

  bool get exceedMaximumPresenters => _exceedMaximumPresenters;

  setViewState(ViewState newViewState) {
    _currentState = newViewState;
    if (_presentTimer != null) {
      _presentTimer!.cancel();
      _presentTimer = null;
    }
    notifyListeners();
  }

  setTouchBack(bool touchBack) {
    _touchBack = touchBack;
  }

  /// 2023Q2, Presenter generates OTP.
  /// 2023Q3, it's possible to be generated OTP from this Send App. And this should be removed.
  Future<bool> checkDisplayOTP({required String? displayCode, required String? otp}) async {
    var api = Uri.parse('$_urlGateway/presentation/displays/?code=$displayCode&otp=$otp');
    http.Response response = await http.get(api);
    displayer = Displayer.fromJson(jsonDecode(response.body));
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<int> checkModeratorOTP({required String displayCode, required String otp}) async {
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
        break;
      case 204:
        // 沒開moderator 有往下跑
        this.displayCode = displayCode;
        this.otp = otp;
        break;
      case 403:
      // 403 -> Reach maximum presenters
        break;
      case 404:
      // 404 -> sendToV1
        this.displayCode = displayCode;
        break;
      case 406:
        // 有開Moderator otp錯誤 沒有往下跑
        // 406 -> Invalid one time password
        // break;
      // return false;
      default:
        //log
        break;
    }
    print('zz checkModeratorOTP ${response.statusCode}');
    return response.statusCode;
  }

  Future<void> presentTo(
      {required String? displayCode, required String? otp}) async {
    debugModePrint(
        '${presenter?.id} presentTo: displayCode: $displayCode, otp: $otp',
        type: runtimeType);
    _v1 = false;
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

    _socket?.onConnecting((data) {
      debugModePrint('${presenter?.id} onConnecting: $data', type: runtimeType);
    });

    _socket?.onConnect((_) {
      debugModePrint('${presenter?.id} connected to display',
          type: runtimeType);

      _socket?.on("display-ready", (msg) {
        debugModePrint('${presenter?.id} display-ready: $msg',
            type: runtimeType);
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
          "display": {"code": displayCode, "setId": _getRandomString()},
          "signal": {
            "url": "",
          }
        }
      });
    });

    _socket?.on("display-state-update", (msg) {
      debugModePrint('${presenter?.id} display-state-update: $msg',
          type: runtimeType);
      Message message = Message.fromJson(msg);
      String? messageFor = message.messageFor;
      if (messageFor != null && messageFor == presenter?.id) {
        Extra extra = Extra.fromJson(message.extra);
        if (extra.windowState != null) {
          displayer?.windowState = extra.windowState;
        }
        if (extra.presentationState == 'stopStreaming') {
          // moderator mode
          if (moderator != null) {
            presentStop();
            setViewState(ViewState.moderatorWait);
          } else {
            if (state == ViewState.selectScreen) {
              PresentSelectScreen.selectScreenDialog?.cancel();
            }
            presentEnd();
          }
        }
      }
    });

    _socket?.on('update-display-state', (msg) {
      debugModePrint('${presenter?.id} update-display-state: $msg',
          type: runtimeType);
    });

    _socket?.on('presenter-change-quality', (msg) {
      debugModePrint('${presenter?.id} presenter-change-quality: $msg',
          type: runtimeType);
      if (_webRTCHelper?.trackHeight != msg['extra']['constraints']['height']) {
        _webRTCHelper?.changeStreamFrameRate(msg['extra']['constraints']['frameRate'], msg['extra']['constraints']['height']);
      }
    });

    _socket?.on("presenter-peer-action", (msg) {
      debugModePrint('${presenter?.id} presenter-peer-action: $msg',
          type: runtimeType);
      Message message = Message.fromJson(msg);
      String? messageFor = message.messageFor;
      if (messageFor != null && messageFor == presenter?.id) {
        if (message.action == 'remove') { // moderator mode
          // stream end
          presentStop();
          presentEnd();
        }
        if (message.action == 'stopVideo') { // moderator mode
          // stream stop
          presentStop();
          setViewState(ViewState.moderatorWait);
        }
        if (message.action == 'pause' && message.status == 'pause') {
          //stream pause
          presentPause();
        }
        if (message.action == 'resume' && message.status == 'pause') {
          // stream resume
          presentResume();
        }
      }
    });

    _socket?.on('reject-present', (msg) {
      debugModePrint('${presenter?.id} reject-present: $msg',
          type: runtimeType);
      if (msg['action'] == 'reject-present') {
        if (msg['extra']['reason'] == 'blocked') {
          // split-screen: exceeded maximum presenters
          _exceedMaximumPresenters = true;
          //  back to idle
          setViewState(ViewState.idle);
        }
      }
    });

    _socket?.on('dismiss', (msg) {
      debugModePrint('${presenter?.id} dismiss: $msg', type: runtimeType);
    });

    _socket?.on('set-moderator', (msg) {
      debugModePrint('${presenter?.id} set-moderator: $msg', type: runtimeType);
      if (msg['action'] == 'set-moderator') {
        moderator = Moderator.fromJson(msg['extra']['moderator']);
        _socket?.emit('join-display', {
          "messageFor": displayCode,
          "action": "join",
          "status": "open",
          "extra": {
            "presenter": presenter?.toJson(),
            "moderator": moderator?.toJson(),
            "display": {"code": displayCode, "setId": _getRandomString()},
            "signal": {
              "url": '',
            }
          }
        });
      }
    });

    _socket?.on('unset-moderator', (msg) {
      debugModePrint('${presenter?.id} unset-moderator: $msg',
          type: runtimeType);
      if (msg['action'] == 'unset-moderator') {
        presentEnd();
      }
    });

    _socket?.on('$displayCode/disconnect', (data) {
      if (state == ViewState.selectScreen) {
        PresentSelectScreen.selectScreenDialog?.cancel();
      } else {
        presentEnd();
      }
    });

    setViewState(ViewState.waitReady);
  }

  Future<void> presentToV1(
      {required String displayCode, required String otp, required Function(String result) callback}) async {
    debugModePrint(
        '${presenter?.id} presentToV1: displayCode: $displayCode, otp: $otp',
        type: runtimeType);
    _v1 = true;
    _socket = io.io(
        'https://control-io.myviewboard.cloud/',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNew()
            .enableForceNewConnection()
            .setQuery({
          "userid": presenter?.id,
          "socketCustomEvent": displayCode,
          "role": "presenter",
        })
            .build());

    _socket?.onConnect((_) {
      debugModePrint('connected to display $_ ${_socket?.id} ${_socket?.json} ${_socket?.query}');

      _socket?.on(displayCode, (data) async {
        debugModePrint('displayCode1 $data');
        Message message = Message.fromJson(data);
        if(message.messageFor != presenter?.id) return;

        if (message.action == 'connect') {
          presentSelectScreen();
        } else {
          presentEnd(goIdleState: false);
        }
        callback(message.action!); //'denied', 'blocked', 'timeout'
      });

      _socket?.on('$displayCode/disconnect', (data) {
        if (state == ViewState.selectScreen) {
          PresentSelectScreen.selectScreenDialog?.cancel();
        } else {
          presentEnd();
        }
      });

      _socket?.emit(displayCode, {
        'messageFor': displayCode,
        'userid': presenter?.id,
        'otp': otp,
      });
    });


  }

  Future<void> presentSelectScreen() async {
    setViewState(ViewState.selectScreen);
  }

  Future<void> presentToTimeout() async {
    setViewState(ViewState.idle);
  }

  Future<void> presentStart({required dynamic selectedSource}) async {
    if (_v1) {
      _webRTCHelper = WebRTCHelperV1(_urlIce);
      await _webRTCHelper?.makeCall(
        'https://control-io.myviewboard.cloud/',
        presenter?.id ?? '',
        displayCode!,
        selectedSource,
      );
    } else {
      _webRTCHelper = WebRTCHelper(_urlIce, touchBack: touchBack);
      await _webRTCHelper?.makeCall(
        _msgDisplay['extra']['signal']['url'],
        _msgDisplay['extra']['setClientId'],
        _msgDisplay['extra']['setAllowedPeer'],
        selectedSource,
      );
    }
    if (moderator != null) {
      setViewState(ViewState.moderatorStart);
    } else {
      setViewState(ViewState.presentStart);
    }
  }

  Future<void> presentEnd({bool goIdleState = true}) async {
    try {
      if (_v1) {
        _socket?.emit(displayCode!, {
          'messageFor': displayCode!,
          'userid': presenter?.id,
          "action": "disconnect",
          'exact': {
            'triggerBy': 'presentStop'
          }
        });
      }
      if (_webRTCHelper != null) await _webRTCHelper?.hangUp();
      _webRTCHelper = null;

      if (_socket != null) {
        _socket?.disconnect();
        _socket?.dispose();
      }
      _socket = null;
    } catch (e) {
      debugModePrint(e, type: runtimeType);
    }

    if (goIdleState) {
      resetMessage();
      setViewState(ViewState.idle);
    }
  }

  Future<void> presentStop() async {
    // handle stream
    _webRTCHelper?.streamStop();
    _webRTCHelper?.hangUp();
    _socket?.emit('presenter-action', {
      "action": "stop",
      "extra": {
        "presenter": presenter?.toJson(),
        if (moderator != null)
          "moderator": moderator?.toJson(),
        "display": displayer?.toJson(),
      }
    });
    _socket?.emit(displayCode!, {
      'messageFor': displayCode,
      'userid': presenter?.id,
      'action': 'disconnect',
    });
  }

  Future<void> presentPause() async {
    if (_v1) {
      _socket?.emit(displayCode!, {
        'messageFor': displayCode!,
        'userid': presenter?.id,
        "action": "pauseVideo",
      });
    } else {
      _socket?.emit('presenter-action', {
        "action": "pause",
        "extra": {
          "presenter": presenter?.toJson(),
          "moderator": moderator?.toJson(),
          "display": displayer?.toJson(),
        }
      });
    }

    // handle stream
    _webRTCHelper?.streamPause();
  }

  Future<void> presentResume() async {
    if (_v1) {
      _socket?.emit(displayCode!, {
        'messageFor': displayCode!,
        'userid': presenter?.id,
        "action": "resumeVideo",
      });
    } else {
      _socket?.emit('presenter-action', {
        "action": "resume",
        "extra": {
          "presenter": presenter?.toJson(),
          "moderator": moderator?.toJson(),
          "display": displayer?.toJson(),
        }
      });
    }

    // handle stream
    _webRTCHelper?.streamResume();
  }

  Future<void> presentFullscreen() async {
    _socket?.emit('set-window-state', {
      'messageFor': displayCode!,
      'status': displayer?.windowState == 'normal'? 'fullscreen': 'normal',
      'action': "set-window-state",
      'exact': {},
      'messageId':'',
      'nextId':'',
    });
  }

  resetMessage() {
    presenter = Presenter(id: const Uuid().v4());
    moderator = null;
    _exceedMaximumPresenters = false;
  }

  String _getRandomString() {
    String a = BigInt.parse((Random().nextDouble()*DateTime.now().millisecond).toString().replaceAll(RegExp(r'\.'), '')).toRadixString(36);
    return a;
  }
}
