import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/main_common.dart';
import 'package:display_flutter/model/bean/display_message.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/model/moderator_helper.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/screens/moderator_view.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/utility/print_in_debug.dart';
import 'package:display_flutter/utility/get_string.dart';
import 'package:display_flutter/widgets/main_info.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:display_flutter/widgets/webrtc_view.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:uuid/uuid.dart';

class ControlSocket {
  static final ControlSocket _instance = ControlSocket._internal();

  //private "Named constructors"
  ControlSocket._internal();

  // passes the instantiation to the _instance object
  factory ControlSocket() => _instance;

  Socket? _controlSocketIO;
  final int _maxReconnectAttempts = 5;
  int _displayReconnectAttempts = 0;

  final List<WebRTCFlutterViewController> _webRtcController =
      <WebRTCFlutterViewController>[];

  String entityId = '';
  String token = '';
  String displayCode = '';
  String otpCode = '';

  Moderator? moderator;

  String meetingId = '';

  bool isShowDelegate = false;
  bool isShowCode = false;

  void connect(String apiGateway) {
    if (_controlSocketIO != null) {
      printInDebug('stop reconnecting the former url', type: runtimeType);
      _controlSocketIO?.dispose();
    }

    _controlSocketIO = io(
        apiGateway,
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()
            .enableForceNew()
            .enableForceNewConnection()
            .enableReconnection()
            .setReconnectionDelay(2000)
            .setReconnectionAttempts(_maxReconnectAttempts)
            .setQuery({
              'socketCustomEvent': displayCode,
              'role': 'display',
              'deviceId': AppInstanceCreate().displayInstanceID,
              'token': Uri.encodeComponent(token)
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

  bool isControlSocketNull() {
    return _controlSocketIO == null;
  }

  void disconnect() {
    // https://github.com/rikulo/socket.io-client-dart/issues/108
    _controlSocketIO?.dispose();
    _controlSocketIO = null;
  }

  void addWebRtcController(WebRTCFlutterViewController controller) {
    _webRtcController.add(controller);
  }

  void removeWebRtcController(WebRTCFlutterViewController controller) {
    _webRtcController.remove(controller);
  }

  void handleAddStreamState(WebRTCFlutterViewController controller) {
    // update state and quality
    _handleDisplayStateUpdate(controller);

    // must after _handleDisplayStateUpdate!
    _handleQualityUpdate(controller);

    // hideTitleBar
    Home.showTitleBottomBar.value = false;

    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      StreamFunction.streamFunctionState.value = stateMenuOff;
      if (moderator != null && navService.canPop()) {
        ModeratorHelper.getInstance().refresh();
      }
    } else {
      if (moderator != null && navService.canPop()) {
        StreamFunction.streamFunctionState.value = stateMenuOff;
        ModeratorHelper.getInstance().refresh();
      } else {
        navService.popUntil('/home');
      }
    }
  }

  void handleRtcControllerDisconnect(WebRTCFlutterViewController controller) {
    // update state and quality
    _handleDisplayStateUpdate(controller);

    // must after _handleDisplayStateUpdate!
    _handleQualityUpdate(controller);

    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      bool presenting = false;
      for (WebRTCFlutterViewController controller in _webRtcController) {
        if (controller.presentationState !=
            PresentationState.stopStreaming) {
          presenting |= true;
        }
      }
      if (!presenting) {
        if (moderator != null && navService.canPop()) {
          ModeratorHelper.getInstance().refresh();
        }
        Home.showTitleBottomBar.value = true;
        StreamFunction.streamFunctionState.value = stateStandby;
        MainInfo.showMainInfo.value = true;
      } else {
        Home.isSelectedList.value
            .fillRange(0, Home.isSelectedList.value.length, false);
        // Using below method to trigger value changed.
        // https://github.com/flutter/flutter/issues/29958
        Home.isSelectedList.value = List.from(Home.isSelectedList.value);
      }
    } else {
      if (moderator != null && navService.canPop()) {
        ModeratorHelper.getInstance().refresh();
      }
      Home.showTitleBottomBar.value = true;
      StreamFunction.streamFunctionState.value = stateStandby;
      MainInfo.showMainInfo.value = true;
    }
    if (MyApp.isInBackgroundMode) {
      MyApp.disconnectControlSocket();
    }
  }

  void _printControlSocketLog(String? event, dynamic args) {
    printInDebug(
        'mControlSocketIO{${_controlSocketIO?.id}}: $event ${args.toString()}',
        type: runtimeType);
  }

  void _handleDisplayResponse(dynamic arg) async {
    String? messageFor = arg['messageFor'];
    if (messageFor != null && messageFor == displayCode) {
      var resp = DisplayMessage.fromJson(arg);
      switch (resp.action) {
        // region Moderator
        case 'set-moderator':
          Extra extra = Extra.fromJson(resp.extra);
          moderator = Moderator.fromJson(extra.moderator);
          meetingId = extra.meetingId ?? '';

          AppAnalytics().setEventProperties(meetingId: meetingId);

          if (ConnectionTimer.getInstance().mRemainingTimeTimer == null) {
            ConnectionTimer.getInstance().startRemainingTimeTimer(() {
              const ModeratorView().logout();
            });
          }
          break;
        case 'unset-moderator':
          moderator = null;
          meetingId = '';

          AppAnalytics().setEventProperties(meetingId: meetingId);

          ConnectionTimer.getInstance().stopRemainingTimeTimer();
          break;
        // endregion Moderator
        // region Present
        case 'start-present':
          WebRTCFlutterViewController? selectedController;
          if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
            for (WebRTCFlutterViewController controller in _webRtcController) {
              if (controller.presentationState.index <=
                  PresentationState.occupied.index) {
                selectedController = controller;
                break;
              }
            }
          } else {
            if (_webRtcController.isNotEmpty) {
              if (_webRtcController[0].presentationState.index <=
                  PresentationState.occupied.index) {
                selectedController = _webRtcController[0];
              }
            }
          }

          Extra extra = Extra.fromJson(resp.extra);
          Signal signal = Signal.fromJson(extra.signal);
          Presenter presenter = Presenter.fromJson(extra.presenter);

          if (selectedController != null) {
            log('selectedController: ${selectedController.mUid}');
            try {
              selectedController.presentId = const Uuid().v4();
              selectedController.presenterId = presenter.id ?? '';
              selectedController.presenterName = presenter.name ?? '';
              AppAnalytics().trackEventPresentStartReceived(
                  selectedController.presentId, selectedController.presenterId);
              // Send wait for stream
              selectedController.presentationState =
                  PresentationState.waitForStream;
              _handleDisplayStateUpdate(selectedController);
              // Send wait for stream

              if (moderator == null) {
                ConnectionTimer.getInstance().startConnectionTimeoutTimer(
                    selectedController, resp.nextId ?? '',
                    (controller, nextId) {
                  _handleP2PClientReject(controller.presentId,
                      controller.presenterId, nextId, 'timeout');

                  selectedController?.disconnect(sendAnalytics: true);
                  // NativeView will invokeMethod disconnectedP2pClient to switch UI.
                });
              }

              MainInfo.showMainInfo.value = false;
              StreamFunction.streamFunctionState.value = stateEmpty;

              selectedController.showConnectionInfo(true);
              AppAnalytics().trackEventPresentStarting(
                  selectedController.presentId, selectedController.presenterId);
              await selectedController.connectClient(signal.token!, displayCode, signal.peerId!, signal.url!, (result) {
                if (result) {
                  selectedController?.peerToken = signal.token ?? '';
                  selectedController?.peerId = signal.peerId ?? '';
                  selectedController?.signalURL = signal.url;

                  _handleP2PClientSuccess(
                      selectedController!, resp.nextId ?? '');
                }
              });

              if (moderator == null &&
                  !SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
                ConnectionTimer.getInstance().startRemainingTimeTimer(() {
                  selectedController?.disconnect(sendAnalytics: true);
                });
              }
            } on PlatformException catch (e) {
              log(e.toString());

              selectedController.presentationState = PresentationState.stopStreaming;
              selectedController.showConnectionInfo(false);
              _handleDisplayStateUpdate(selectedController);

              MainInfo.showMainInfo.value = true;
              StreamFunction.streamFunctionState.value = stateStandby;
            }
          } else {
            log('selectedController is null!');

            if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
              _handleP2PClientReject(const Uuid().v4(), presenter.id ?? '',
                  resp.nextId ?? '', 'blocked');
            }
          }
          break;
        case 'stop-present':
          Extra extra = Extra.fromJson(resp.extra);
          Presenter presenter = Presenter.fromJson(extra.presenter);

          WebRTCFlutterViewController? selectedController;
          for (WebRTCFlutterViewController controller in _webRtcController) {
            if (controller.presenterId == presenter.id) {
              selectedController = controller;
              break;
            }
          }

          if (selectedController != null) {
            AppAnalytics().trackEventPresentStopReceived(
                selectedController.presentId, selectedController.presenterId);

            try {
              await selectedController.disconnect(sendAnalytics: true);
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
        case 'pause-present':
          Extra extra = Extra.fromJson(resp.extra);
          Presenter presenter = Presenter.fromJson(extra.presenter);

          WebRTCFlutterViewController? selectedController;
          for (WebRTCFlutterViewController controller in _webRtcController) {
            if (controller.presenterId == presenter.id) {
              selectedController = controller;
              break;
            }
          }

          if (selectedController != null) {
            AppAnalytics().trackEventPresentPauseReceived(
                selectedController.presentId, selectedController.presenterId);

            try {
              selectedController.pauseVideo();
              _handleStreamPauseSuccess(selectedController, resp.nextId);
            } on PlatformException catch (e) {
              log(e.toString());
            }
          }
          break;
        case 'resume-present':
          Extra extra = Extra.fromJson(resp.extra);
          Presenter presenter = Presenter.fromJson(extra.presenter);

          WebRTCFlutterViewController? selectedController;
          for (WebRTCFlutterViewController controller in _webRtcController) {
            if (controller.presenterId == presenter.id) {
              selectedController = controller;
              break;
            }
          }

          if (selectedController != null) {
            AppAnalytics().trackEventPresentResumeReceived(
                selectedController.presentId, selectedController.presenterId);

            try {
              selectedController.resumeVideo();
            } on PlatformException catch (e) {
              log(e.toString());
            }
          }
          break;
        // endregion  Present
      }
    }
  }

  void _handleDisplayStateUpdate(WebRTCFlutterViewController controller) {
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
    printInDebug('mControlSocketIO: send _handleDisplayStateUpdate: $content',
        type: runtimeType);
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
    // Using below method to trigger value changed.
    // https://github.com/flutter/flutter/issues/29958
    SplitScreen.mapSplitScreen.value =
        Map.from(SplitScreen.mapSplitScreen.value);
  }

  void _handleQualityUpdate(WebRTCFlutterViewController controller) {
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      if (SplitScreen.mapSplitScreen.value[keySplitScreenCount] < 2) {
        for (WebRTCFlutterViewController viewController in _webRtcController) {
          if (viewController.presentationState == PresentationState.streaming) {
            _handleChangeQuality(viewController, true, true);
          }
        }
      } else {
        for (WebRTCFlutterViewController viewController in _webRtcController) {
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
      WebRTCFlutterViewController controller, String nextId) {
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
        'signal': {
          'url': controller.signalURL,
        }
      },
      'messageId': nextId,
      'nextId': GetString.getRandomString(21)
    });
    printInDebug('mControlSocketIO: send_handleP2PClientSuccess: $content',
        type: runtimeType);
    _controlSocketIO?.emit(displayCode, json.decode(content));
    AppAnalytics().trackEventPresentReadySent(
        controller.presentId, controller.presenterId);
  }

  void _handleP2PClientReject(
      String presentId, String presenterId, String nextId, String reason) {
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
    printInDebug('mControlSocketIO: send _handleP2PClientReject: $content',
        type: runtimeType);
    _controlSocketIO?.emit(displayCode, json.decode(content));
    if (reason == 'timeout') {
      AppAnalytics().trackEventPresentRejectTimeOutSent(presentId, presenterId);
    } else if (reason == 'blocked') {
      AppAnalytics().trackEventPresentRejectBlockedSent(presentId, presenterId);
    }
  }

  void _handleStreamPauseSuccess(
      WebRTCFlutterViewController controller, String? nextId) {
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
    printInDebug('mControlSocketIO: send_handleStreamPauseSuccess: $content',
        type: runtimeType);
    _controlSocketIO?.emit(displayCode, json.decode(content));
  }

  void _handleChangeQuality(WebRTCFlutterViewController controller,
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
    printInDebug('mControlSocketIO: send _handleChangeQuality: $content',
        type: runtimeType);
    _controlSocketIO?.emit(displayCode, json.decode(content));
  }

  bool occupyAvailableWebRTCViewController() {
    for (int i = 0; i < _webRtcController.length; i++) {
      if (_webRtcController[i].presentationState.index <
          PresentationState.occupied.index) {
        _webRtcController[i].presentationState = PresentationState.occupied;
        return true;
      }
    }
    return false;
  }

  bool isPresenting({index}) {
    bool presenting = false;
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      if (index != null && _webRtcController.length > index) {
        if (_webRtcController[index].presentationState ==
            PresentationState.streaming) {
          presenting = true;
        }
      } else {
        for (WebRTCFlutterViewController controller in _webRtcController) {
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

  bool hasPresenterOccupied({index}) {
    bool presenting = false;
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      if (index != null && _webRtcController.length > index) {
        if (_webRtcController[index].presentationState !=
            PresentationState.stopStreaming) {
          presenting = true;
        }
      } else {
        for (WebRTCFlutterViewController controller in _webRtcController) {
          if (controller.presentationState != PresentationState.stopStreaming) {
            presenting |= true;
          }
        }
      }
    } else {
      if (_webRtcController.isNotEmpty &&
          _webRtcController[0].presentationState !=
              PresentationState.stopStreaming) {
        presenting = true;
      }
    }
    return presenting;
  }

  int getPresentingQuantity() {
    int quantity = 0;
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      for (WebRTCFlutterViewController controller in _webRtcController) {
        if (controller.presentationState == PresentationState.streaming) {
          quantity++;
        }
      }
    }
    return quantity;
  }

  bool isPresenterWaitForStream(String presenterId) {
    for (WebRTCFlutterViewController controller in _webRtcController) {
      if (controller.presenterId == presenterId &&
          controller.presentationState == PresentationState.waitForStream) {
        return true;
      }
    }
    return false;
  }

  bool isPresenterStreaming(String presenterId) {
    for (WebRTCFlutterViewController controller in _webRtcController) {
      if (controller.presenterId == presenterId &&
          controller.presentationState == PresentationState.streaming) {
        return true;
      }
    }
    return false;
  }

  bool isPresenterNotStopStreaming(String presenterId) {
    for (WebRTCFlutterViewController controller in _webRtcController) {
      if (controller.presenterId == presenterId &&
          controller.presentationState.index >=
              PresentationState.waitForStream.index) {
        // waitForStream and streaming
        return true;
      }
    }
    return false;
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
      printInDebug('unbind status: ${response.statusCode}', type: runtimeType);
      // every thing else
    } catch (e) {
      printInDebug('unbind failure: $e', type: runtimeType);
      // http.post maybe no network connection.
    }
  }

  removeAllPresenters() async {
    WebRTCFlutterViewController? selectedController;
    List<WebRTCFlutterViewController> temp = List.from(_webRtcController);
    for (int i = temp.length - 1; i >= 0; i--) {
      selectedController = temp[i];
      if (selectedController.presenterId.isNotEmpty) {
        try {
          await selectedController.disconnect(sendAnalytics: true);
          // need some delay to prevent exception:
          // 'package:flutter/src/rendering/object.dart': Failed assertion: line 2250 pos 12: '!_debugDisposed': is not true.
          await Future.delayed(const Duration(milliseconds: 300));
        } on PlatformException catch (e) {
          log(e.toString());
        }
      }
    }
  }

  removePresenterBy(int index) async {
    WebRTCFlutterViewController? selectedController = _webRtcController[index];
    if (selectedController.presenterId.isNotEmpty) {
      try {
        await selectedController.disconnect(sendAnalytics: true);
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

  updateAllAudioEnableState(bool enable) {
    for (WebRTCFlutterViewController controller in _webRtcController) {
      controller.controlAudio(enable);
    }
  }
}

enum PresentationState {
  stopStreaming,
  occupied,
  waitForStream,
  streaming,
}
