import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/model/bean/display_message.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/model/moderator_helper.dart';
import 'package:display_flutter/native_view/webrtc.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/screens/moderator.dart';
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

  Socket? _controlSocketIO;
  final int _maxReconnectAttempts = 5;
  int _displayReconnectAttempts = 0;

  final List<WebRTCNativeViewController> _webRtcController =
      <WebRTCNativeViewController>[];

  String entityId = '';
  String token = '';
  String displayCode = '';
  String otpCode = '';
  List<String> featureList = [];

  Moderator? moderator;

  String meetingId = '';

  bool isShowDelegate = false;
  bool isShowCode = false;

  void connect(String apiGateway) {
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

    _controlSocketIO?.onConnect((data) {
      AppAnalytics().trackEventControlConnected();
      _printControlSocketLog('connect', data);
      Home.showCloudOff.value = false;
    });
    _controlSocketIO
        ?.onConnecting((data) => _printControlSocketLog('connecting', data));
    _controlSocketIO?.onConnectError((data) {
      _printControlSocketLog('connect_error', data);
      if (_displayReconnectAttempts >= _maxReconnectAttempts) {
        Home.showCloudOff.value = true;
        _displayReconnectAttempts = 0;

        Future.delayed(const Duration(seconds: 5), () {
          connect(apiGateway);
        });
      }
    });
    _controlSocketIO?.on(displayCode, (data) {
      _printControlSocketLog(displayCode, data);
      _handleDisplayResponse(data);
    });
    _controlSocketIO?.on(
        'message', (data) => _printControlSocketLog('message', data));
    _controlSocketIO?.onConnectTimeout(
        (data) => _printControlSocketLog('onConnectTimeout', data));
    _controlSocketIO?.onDisconnect((data) {
      AppAnalytics().trackEventControlDisconnected();
      _printControlSocketLog('disconnect', data);
    });
    _controlSocketIO?.onError((data) => _printControlSocketLog('error', data));
    _controlSocketIO?.onReconnecting((data) {
      _printControlSocketLog('reconnecting', data);
      _displayReconnectAttempts++;
    });

    _controlSocketIO?.connect();
  }

  void disconnectControlSocket() {
    // https://github.com/rikulo/socket.io-client-dart/issues/108
    _controlSocketIO?.dispose();
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

          // must after _handleDisplayStateUpdate!
          _handleQualityUpdate(controller);

          Home.showTitleBottomBar.value = false;
          StreamFunction.showWaitFunction.value = false;
          if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
            if (SplitScreen.showSplitScreen.value) {
              StreamFunction.showStreamMenu.value = false;
            } else if (ModeratorView.showModerator.value) {
              StreamFunction.showStreamMenu.value = false;
              ModeratorHelper.getInstance().refresh();
            } else if (StreamFunction.showPresentFunction.value) {
              StreamFunction.showStreamMenu.value = false;
            } else {
              StreamFunction.showStreamMenu.value = true;
            }
          } else {
            if (moderator != null && ModeratorView.showModerator.value) {
              StreamFunction.showStreamMenu.value = false;
              ModeratorHelper.getInstance().refresh();
            } else {
              SplitScreen.showSplitScreen.value = false;
              ModeratorView.showModerator.value = false;
            }
          }

          AppAnalytics().trackEventPresentStarted();
          break;
        case 'disconnectedP2pClient':
          controller.presentationState = PresentationState.stopStreaming;
          controller.nativeViewState.switchConnectionState(false);
          _handleDisplayStateUpdate(controller);

          // must after _handleDisplayStateUpdate!
          _handleQualityUpdate(controller);

          // Clear all presenter settings.
          controller.presenterId = '';
          controller.presenterName = '';
          controller.peerToken = '';
          controller.peerId = '';

          if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
            bool presenting = false;
            for (WebRTCNativeViewController controller in _webRtcController) {
              if (controller.presentationState !=
                  PresentationState.stopStreaming) {
                presenting |= true;
              }
            }
            if (!presenting) {
              if (moderator != null && ModeratorView.showModerator.value) {
                ModeratorHelper.getInstance().refresh();
              }
              Home.showTitleBottomBar.value = true;
              StreamFunction.showWaitFunction.value = true;
              StreamFunction.showStreamMenu.value = false;
              StreamFunction.showPresentFunction.value = false;
              MainInfo.showMainInfo.value = true;
            } else {
              Home.isSelectedList.value
                  .fillRange(0, Home.isSelectedList.value.length, false);
              // Using below method to trigger value changed. https://github.com/flutter/flutter/issues/29958
              Home.isSelectedList.value = List.from(Home.isSelectedList.value);
            }
          } else {
            if (moderator != null && ModeratorView.showModerator.value) {
              ModeratorHelper.getInstance().refresh();
            }
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
          meetingId = extra.meetingId ?? '';

          AppAnalytics().setEventProperties(meetingId: meetingId);

          if (ConnectionTimer.getInstance().mRemainingTimeTimer == null) {
            ConnectionTimer.getInstance().startRemainingTimeTimer(() {
              ModeratorView().logout();
              streamFunctionKey.currentState?.setState(() {
                ControlSocket().moderator = null;
              });
            });
          }
          break;
        case "unset-moderator":
          moderator = null;
          meetingId = '';

          AppAnalytics().setEventProperties(meetingId: meetingId);

          ConnectionTimer.getInstance().stopRemainingTimeTimer();
          break;
        // endregion Moderator
        // region Present
        case "start-present":
          AppAnalytics().trackEventPresentStartReceived();

          WebRTCNativeViewController? selectedController;
          if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
            for (WebRTCNativeViewController controller in _webRtcController) {
              if (controller.presentationState ==
                  PresentationState.stopStreaming) {
                selectedController = controller;
                break;
              }
            }
          } else {
            if (_webRtcController.isNotEmpty) {
              if (moderator != null) {
                if (_webRtcController[0].presentationState ==
                    PresentationState.stopStreaming) {
                  selectedController = _webRtcController[0];
                } else if (_webRtcController[0].peerId.isNotEmpty) {
                  selectedController = _webRtcController[0];
                }
              } else if (_webRtcController[0].presentationState ==
                  PresentationState.stopStreaming) {
                selectedController = _webRtcController[0];
              }
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
              StreamFunction.showWaitFunction.value = false;

              selectedController.nativeViewState.switchConnectionState(true);
              var arg = {
                'token': signal.token,
                'peerId': signal.peerId,
              };
              AppAnalytics().trackEventPresentStarting();
              final String result = await selectedController.channel
                  .invokeMethod('connectP2pClient', arg);

              selectedController.peerToken = signal.token ?? '';
              selectedController.peerId = signal.peerId ?? '';

              _handleP2PClientSuccess(
                  selectedController, resp.nextId ?? '', result);

              if (moderator == null &&
                  !SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
                ConnectionTimer.getInstance().startRemainingTimeTimer(() {
                  selectedController!.channel.invokeMethod("stopVideo");
                });
              }
            } on PlatformException catch (e) {
              log(e.toString());

              selectedController.presentationState =
                  PresentationState.stopStreaming;
              selectedController.nativeViewState.switchConnectionState(false);
              _handleDisplayStateUpdate(selectedController);

              MainInfo.showMainInfo.value = true;
              StreamFunction.showWaitFunction.value = true;

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
          AppAnalytics().trackEventPresentStopReceived();

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
              if (moderator == null &&
                  !SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
                ConnectionTimer.getInstance().stopRemainingTimeTimer();
              }
            } on PlatformException catch (e) {
              log(e.toString());
            }
          }
          break;
        case "pause-present":
          AppAnalytics().trackEventPresentPauseReceived();

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
            } on PlatformException catch (e) {
              log(e.toString());
            }
          }
          break;
        case "resume-present":
          AppAnalytics().trackEventPresentResumeReceived();

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
            } on PlatformException catch (e) {
              log(e.toString());
            }
          }
          break;
        // endregion  Present
        // region Communication
        case "mode-update":
          // Set updateDisplayStatus true, and wait disconnectedP2pClient set
          // MainInfo.showMainInfo.value to update privilege status.
          MainInfo.updateDisplayStatus = true;
          if (!isPresenting()) {
            MainInfo.showMainInfo.value = false;
            MainInfo.showMainInfo.value = true;
          }
          break;
        // endregion
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
    _controlSocketIO?.emit(displayCode, json.decode(content));

    int connecting = 0, lastID = 0;
    for (int i = 0; i < _webRtcController.length; i++) {
      if (_webRtcController[i].presentationState !=
          PresentationState.stopStreaming) {
        connecting++;
        lastID = i;
      }
    }
    SplitScreen.mapSplitScreen.value[keySplitScreenCount] = connecting;
    SplitScreen.mapSplitScreen.value[keySplitScreenLastId] = lastID;
    // Using below method to trigger value changed. https://github.com/flutter/flutter/issues/29958
    SplitScreen.mapSplitScreen.value =
        Map.from(SplitScreen.mapSplitScreen.value);
  }

  void _handleQualityUpdate(WebRTCNativeViewController controller) {
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      if (SplitScreen.mapSplitScreen.value[keySplitScreenCount] < 2) {
        for (WebRTCNativeViewController viewController in _webRtcController) {
          if (viewController.presentationState == PresentationState.streaming) {
            _handleChangeQuality(viewController, true, true);
          }
        }
      } else {
        for (WebRTCNativeViewController viewController in _webRtcController) {
          if (viewController.presenterId.isNotEmpty) {
            _handleChangeQuality(viewController, false, true);
          }
        }
      }
    } else {
      _handleChangeQuality(controller, true, true);
    }
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
    _controlSocketIO?.emit(displayCode, json.decode(content));
    AppAnalytics().trackEventPresentReadySent();
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
    _controlSocketIO?.emit(displayCode, json.decode(content));
    if (reason == 'timeout') {
      AppAnalytics().trackEventPresentRejectTimeOutSent();
    } else if (reason == 'blocked') {
      AppAnalytics().trackEventPresentRejectBlockedSent();
    }
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
    _controlSocketIO?.emit(displayCode, json.decode(content));
  }

  void _handleChangeQuality(WebRTCNativeViewController controller,
      bool isFullHeight, bool isFullFrameRate) async {
    var content = json.encode({
      'messageFor': controller.presenterId,
      'action': 'change-quality',
      'extra': {
        'constraints': {
          'frameRate': isFullFrameRate ? 30 : 0,
          'height': isFullHeight ? 1080 : 540,
        },
      },
    });
    print('mControlSocketIO: _handleChangeQuality: $content');
    _controlSocketIO?.emit(displayCode, json.decode(content));
  }

  bool isPresenting({index}) {
    bool presenting = false;
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      if (index != null && _webRtcController.length > index) {
        if (_webRtcController[index].presentationState ==
            PresentationState.streaming) presenting = true;
      } else {
        for (WebRTCNativeViewController controller in _webRtcController) {
          if (controller.presentationState == PresentationState.streaming) {
            presenting |= true;
          }
        }
      }
    } else {
      if (_webRtcController.isNotEmpty &&
          _webRtcController[0].presentationState ==
              PresentationState.streaming) {
        presenting = true;
      }
    }
    return presenting;
  }

  int presenterQty() {
    int qty = 0;
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      for (WebRTCNativeViewController controller in _webRtcController) {
        if (controller.presentationState == PresentationState.streaming) {
          qty++;
        }
      }
    }
    print('zz presenterQty ${qty}');
    return qty;
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

  removeAllPresenters() async {
    WebRTCNativeViewController? selectedController;
    List<WebRTCNativeViewController> temp = List.from(_webRtcController);
    for (int i = temp.length - 1; i >= 0; i--) {
      selectedController = temp[i];
      if (selectedController.presenterId.isNotEmpty) {
        try {
          await selectedController.channel.invokeMethod("stopVideo");
          ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
        } on PlatformException catch (e) {
          log(e.toString());
        }
      }
    }
  }

  removePresenterBy(int index) async {
    WebRTCNativeViewController? selectedController = _webRtcController[index];
    if (selectedController.presenterId.isNotEmpty) {
      try {
        await selectedController.channel.invokeMethod("stopVideo");
        ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
      } on PlatformException catch (e) {
        log(e.toString());
      }
    }
  }

  updateAllQuality(int selection, bool hasSelected) {
    if (selection == -1) {
      _handleChangeQuality(_webRtcController[0], true, true);
    } else {
      for (int i = 0; i < _webRtcController.length; i++) {
        if (_webRtcController[i].presenterId.isNotEmpty) {
          _handleChangeQuality(
              _webRtcController[i],
              (i == selection && hasSelected),
              (i == selection || !hasSelected));
        }
      }
    }
  }
}

enum PresentationState {
  stopStreaming,
  waitForStream,
  streaming,
}
