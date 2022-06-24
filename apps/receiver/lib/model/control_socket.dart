import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/model/bean/display_message.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/native_view/webrtc.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/utility/get_string.dart';
import 'package:display_flutter/widgets/main_info.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
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

  String token = '';
  String displayCode = '';
  String otpCode = '';
  String licenseName = '';
  List<String> featureList = [];

  Moderator? moderator;

  String meetingId = '';
  int remainingTime = 0;
  List<double> remainingTimeCheckPoints = [];

  bool isShowDelegate = false;
  bool isShowCode = false;

  void connect(String apiGateway) {
    AppAnalytics().setEventProperties({
      'displayID': ControlSocket().displayCode,
      'licenseName': ControlSocket().licenseName
    });

    _controlSocketIO = io(
        apiGateway,
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()
            .enableForceNew()
            .enableReconnection()
            .setReconnectionAttempts(_maxReconnectAttempts)
            .setQuery({
              'socketCustomEvent': displayCode,
              'role': 'display',
              'deviceId': AppInstanceCreate().displayInstanceID,
              'token': token
            })
            .build());

    _controlSocketIO.onConnect((data) {
      _printControlSocketLog('connect', data);
      Home.showCloudOff.value = false;
    });
    _controlSocketIO
        .onConnecting((data) => _printControlSocketLog('connecting', data));
    _controlSocketIO.onConnectError((data) {
      _printControlSocketLog('connect_error', data);
      if (_displayReconnectAttempts >= _maxReconnectAttempts) {
        Home.showCloudOff.value = true;
        _displayReconnectAttempts = 0;

        Future.delayed(const Duration(seconds: 5), () {
          connect(apiGateway);
        });
      }
    });
    _controlSocketIO.on(displayCode, (data) {
      _printControlSocketLog(displayCode, data);
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
          controller.presentationState = PresentationState.streaming;
          controller.nativeViewState.switchConnectionState(false);
          _handleDisplayStateUpdate(controller);

          Home.showTitleBottomBar.value = false;
          StreamFunction.showWaitFunction.value = false;
          if (SplitScreen.splitScreenEnabled.value) {
            if (StreamFunction.showModerator.value || StreamFunction.showSplitScreen.value) {
              StreamFunction.showStreamMenu.value = false;
            } else if (StreamFunction.showPresentFunction.value){
              StreamFunction.showStreamMenu.value = false;
            } else {
              StreamFunction.showStreamMenu.value = true;
            }
          } else {
            if (moderator != null && StreamFunction.showModerator.value) {
              StreamFunction.showStreamMenu.value = false;
            }
          }
          AppAnalytics().trackEventPresentStart();
          break;
        case 'disconnectedP2pClient':
          controller.presentationState = PresentationState.stopStreaming;
          controller.nativeViewState.switchConnectionState(false);
          _handleDisplayStateUpdate(controller);

          if (SplitScreen.splitScreenEnabled.value) {
            bool presenting = false;
            for (WebRTCNativeViewController controller in _webRtcController) {
              if (controller.presentationState !=
                  PresentationState.stopStreaming) {
                presenting |= true;
              }
            }
            if (!presenting) {
              Home.showTitleBottomBar.value = true;
              StreamFunction.showWaitFunction.value = true;
              StreamFunction.showStreamMenu.value = false;
              StreamFunction.showPresentFunction.value = false;
              MainInfo.showMainInfo.value = true;
            }
          } else {
            Home.showTitleBottomBar.value = true;
            StreamFunction.showWaitFunction.value = true;
            StreamFunction.showStreamMenu.value = false;
            StreamFunction.showPresentFunction.value = false;
            MainInfo.showMainInfo.value = true;
          }

          AppAnalytics().trackEventPresentStopped();
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
    if (messageFor != null && messageFor == displayCode) {
      var resp = DisplayMessage.fromJson(arg);
      switch (resp.action) {
        // region Moderator
        case "set-moderator":
          Extra extra = Extra.fromJson(resp.extra);
          moderator = Moderator.fromJson(extra.moderator);
          meetingId = extra.moderatedSessionId ?? '';
          remainingTime =
              extra.endTime! - DateTime.now().millisecondsSinceEpoch;
          List<dynamic>? checkPoints = extra.checkPoints;
          int? duration = extra.durationRemaining;
          for (int i = 0; i < checkPoints!.length; i++) {
            if ((duration! - checkPoints[i]) > 1000) {
              double point = ((duration - checkPoints[i]) / 1000);
              remainingTimeCheckPoints.add(point);
              log('checkpoint: $point');
            }
          }

          AppAnalytics().setEventProperties(
              {'displayID': displayCode, 'meetingId': meetingId});

          ConnectionTimer.getInstance().startRemainingTimeTimer(remainingTime,
              () {
            moderator = null;
            meetingId = '';
            remainingTime = 0;
            remainingTimeCheckPoints.clear();

            AppAnalytics().setEventProperties(
                {'displayID': displayCode, 'meetingId': meetingId});

            for (WebRTCNativeViewController controller in _webRtcController) {
              controller.channel.invokeMethod('remainingTimeTimeOut');
            }
          });
          break;
        case "unset-moderator":
          moderator = null;
          meetingId = '';
          remainingTime = 0;
          remainingTimeCheckPoints.clear();

          AppAnalytics().setEventProperties(
              {'displayID': displayCode, 'meetingId': meetingId});
          ConnectionTimer.getInstance().stopRemainingTimeTimer();
          break;
        // endregion Moderator
        // region Present
        case "start-present":
          WebRTCNativeViewController? selectedController;
          if (SplitScreen.splitScreenEnabled.value) {
            for (WebRTCNativeViewController controller in _webRtcController) {
              if (controller.presentationState ==
                  PresentationState.stopStreaming) {
                selectedController = controller;
                break;
              }
            }
          } else {
            if (_webRtcController[0].presentationState ==
                PresentationState.stopStreaming) {
              selectedController = _webRtcController[0];
            }
          }

          Extra extra = Extra.fromJson(resp.extra);
          Signal signal = Signal.fromJson(extra.signal);
          Presenter presenter = Presenter.fromJson(extra.presenter);

          if (selectedController != null) {
            log('selectedController: ${selectedController.channel.name}');
            try {
              selectedController.presenterId = presenter.id ?? '';
              selectedController.presenterName = presenter.name ?? '';
              // Send wait for stream
              selectedController.presentationState =
                  PresentationState.waitForStream;
              _handleDisplayStateUpdate(selectedController);
              // Send wait for stream

              if (moderator == null) {
                ConnectionTimer.getInstance().startConnectionTimeoutTimer(
                    selectedController, resp.nextId ?? '',
                    (controller, nextId) {
                  _handleP2PClientReject(
                      controller.presenterId, nextId, 'timeout');

                  controller.channel.invokeMethod('connectionTimeTimeOut');
                  // NativeView will invokeMethod disconnectedP2pClient to switch UI.
                });
              }

              MainInfo.showMainInfo.value = false;

              selectedController.nativeViewState.switchConnectionState(true);
              var arg = {
                'token': signal.token,
                'peerId': signal.peerId,
              };
              final String result = await selectedController.channel
                  .invokeMethod('connectP2pClient', arg);

              selectedController.peerToken = signal.token ?? '';
              selectedController.peerId = signal.peerId ?? '';

              _handleP2PClientSuccess(
                  selectedController, resp.nextId ?? '', result);
            } on PlatformException catch (e) {
              log(e.toString());

              selectedController.presentationState =
                  PresentationState.stopStreaming;
              selectedController.nativeViewState.switchConnectionState(false);
              _handleDisplayStateUpdate(selectedController);

              MainInfo.showMainInfo.value = true;

              _handleP2PClientReject(
                  presenter.id ?? '', resp.nextId ?? '', 'blocked');
            }
          } else {
            log('selectedController is null!');

            _handleP2PClientReject(
                presenter.id ?? '', resp.nextId ?? '', 'blocked');
          }
          break;
        case "stop-present":
          Extra extra = Extra.fromJson(resp.extra);
          Presenter presenter = Presenter.fromJson(extra.presenter);

          WebRTCNativeViewController? selectedController;
          for (WebRTCNativeViewController controller in _webRtcController) {
            if (controller.presenterId == presenter.id) {
              selectedController = controller;
              break;
            }
          }

          if (selectedController != null) {
            try {
              await selectedController.channel.invokeMethod("stopVideo");
              ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
            } on PlatformException catch (e) {
              log(e.toString());
            }
          }
          break;
        case "pause-present":
          Extra extra = Extra.fromJson(resp.extra);
          Presenter presenter = Presenter.fromJson(extra.presenter);

          WebRTCNativeViewController? selectedController;
          for (WebRTCNativeViewController controller in _webRtcController) {
            if (controller.presenterId == presenter.id) {
              selectedController = controller;
              break;
            }
          }

          if (selectedController != null) {
            try {
              await selectedController.channel.invokeMethod("pauseVideo");
              _handleStreamPauseSuccess(selectedController, resp.nextId);
              AppAnalytics().trackEventPresentPaused();
            } on PlatformException catch (e) {
              log(e.toString());
            }
          }
          break;
        case "resume-present":
          Extra extra = Extra.fromJson(resp.extra);
          Presenter presenter = Presenter.fromJson(extra.presenter);

          WebRTCNativeViewController? selectedController;
          for (WebRTCNativeViewController controller in _webRtcController) {
            if (controller.presenterId == presenter.id) {
              selectedController = controller;
              break;
            }
          }

          if (selectedController != null) {
            try {
              await selectedController.channel.invokeMethod("resumeVideo");
              AppAnalytics().trackEventPresentResumed();
            } on PlatformException catch (e) {
              log(e.toString());
            }
          }
          break;
        // endregion  Present
      }
    }
  }

  void _handleDisplayStateUpdate(WebRTCNativeViewController controller) {
    var content = json.encode({
      'messageFor': controller.presenterId,
      'action': 'display-state-update',
      'status': 'display-state-update',
      'extra': {
        'uiState': {
          'code': isShowCode,
          'delegate': isShowDelegate,
        },
        'presentationState': controller.presentationState.name,
      },
      'messageId': GetString.getRandomString(21),
      'nextId': GetString.getRandomString(21),
    });
    print('mControlSocketIO: send _handleDisplayStateUpdate: $content');
    _controlSocketIO.emit(displayCode, json.decode(content));
  }

  void _handleP2PClientSuccess(
      WebRTCNativeViewController controller, String nextId, String result) {
    var content = json.encode({
      'messageFor': displayCode,
      'action': 'start-present',
      'status': 'ready',
      'extra': {
        'presenter': {
          'id': controller.presenterId,
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
    _controlSocketIO.emit(displayCode, json.decode(content));
  }

  void _handleP2PClientReject(
      String presenterId, String nextId, String reason) {
    var content = json.encode({
      'messageFor': displayCode,
      'action': 'reject-present',
      'extra': {
        'presenter': {
          'id': presenterId,
        },
        'reason': reason,
      },
      'messageId': nextId,
    });
    print('mControlSocketIO: _handleP2PClientReject: $content');
    _controlSocketIO.emit(displayCode, json.decode(content));
  }

  void _handleStreamPauseSuccess(
      WebRTCNativeViewController controller, String? nextId) {
    var content = json.encode({
      'messageFor': displayCode,
      'action': 'pause-present',
      'status': 'ok',
      'extra': {
        'presenter': {
          'id': controller.presenterId,
        },
      },
      'messageId': nextId,
      'nextId': GetString.getRandomString(21)
    });
    print('mControlSocketIO: _handleStreamPauseSuccess: $content');
    _controlSocketIO.emit(displayCode, json.decode(content));
  }

  bool isPresenting() {
    bool presenting = false;
    if (SplitScreen.splitScreenEnabled.value) {
      for (WebRTCNativeViewController controller in _webRtcController) {
        if (controller.presentationState == PresentationState.streaming) {
          presenting |= true;
        }
      }
    } else {
      if (_webRtcController[0].presentationState == PresentationState.streaming) {
        presenting = true;
      }
    }
    return presenting;
  }

  unbindModerator(String apiGateway, Moderator moderator) async {
    try {
      http.Response response = await http.patch(
        Uri.parse('$apiGateway/presentation/displays/moderator/unbind'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: json.encode({'code': displayCode, 'moderator': moderator}),
      );
      print('unbind status: ${response.statusCode}');
      // every thing else
    } catch (e) {
      print('unbind failure: $e');
      // http.post maybe no network connection.
    }
  }
}

enum PresentationState {
  stopStreaming,
  waitForStream,
  streaming,
}
