import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/model/displays.dart';
import 'package:display_flutter/model/moderator_helper.dart';
import 'package:display_flutter/model/moderator_socket.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/widgets/custom_alert_dialog.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:display_flutter/widgets/presenter_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

class ModeratorView extends StatefulWidget {
  ModeratorView({Key? key}) : super(key: key);

  static ValueNotifier<bool> showModeratorMessage = ValueNotifier(false);

  final GlobalKey<PresenterListState> presenterListKey = GlobalKey();

  @override
  State createState() => _ModeratorViewState();

  void logout() {
    SplitScreen.mapSplitScreen.value[keySplitScreenEnable] = false;
    SplitScreen.mapSplitScreen.value[keySplitScreenCount] = 0;
    // Using below method to trigger value changed. https://github.com/flutter/flutter/issues/29958
    SplitScreen.mapSplitScreen.value =
        Map.from(SplitScreen.mapSplitScreen.value);
    presenterListKey.currentState?.removeAllPresenter();
    Displays().getDisplays().forEach((element) {
      moderatorSocket.unBindFromDisplay(
          element.displayId, ControlSocket().token);
    });
    moderatorSocket.disconnect();
    Displays().removeAllDisplayInfo();
    AppPreferences().set(moderatorId: '');
    navService.popUntil('/home');
  }
}

class _ModeratorViewState extends State<ModeratorView> {
  bool _isLogInClicked = false;

  @override
  Widget build(BuildContext context) {
    return MenuDialog(
      backgroundColor: ControlSocket().isPresenting()
          ? AppColors.primary_grey_tran
          : AppColors.primary_grey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.fitHeight,
                    child: FocusIconButton(
                      childNotFocus: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.primary_white,
                      ),
                      splashRadius: 20,
                      focusColor: Colors.grey,
                      onClick: () {
                        AppAnalytics().trackEventModeratorPanelClose();
                        navService.popUntil('/home');
                      },
                    ),
                  ),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          S.of(context).moderator_presentersList,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary_white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.fitHeight,
                    child: FocusIconButton(
                      childNotFocus: Image(
                        image: Svg(Displays().getDisplays().isEmpty
                            ? 'assets/images/ic_moderator_split_screen_off.svg'
                            : SplitScreen
                                    .mapSplitScreen.value[keySplitScreenEnable]
                                ? 'assets/images/ic_moderator_split_screen_activate.svg'
                                : 'assets/images/ic_moderator_split_screen_on.svg'),
                      ),
                      splashRadius: 20,
                      focusColor: Colors.grey,
                      onClick: Displays().getDisplays().isNotEmpty
                          ? () {
                              if (Displays().getDisplays().isNotEmpty) {
                                _callSplitScreenDialog();
                              }
                            }
                          : null,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.fitHeight,
                    child: FocusIconButton(
                      childNotFocus: Image(
                        image: Svg((Displays().getDisplays().isNotEmpty)
                            ? 'assets/images/ic_activate_on.svg'
                            : 'assets/images/ic_activate_off.svg'),
                      ),
                      splashRadius: 20,
                      focusColor: Colors.grey,
                      onClick: () {
                        if (!_isLogInClicked) {
                          _isLogInClicked = true;
                          if (Displays().getDisplays().isEmpty) {
                            verifyCode().then((value) {
                              _isLogInClicked = false;
                              WidgetsBinding.instance
                                  ?.addPostFrameCallback((timeStamp) {
                                setState(() {});
                              });
                            });
                          } else {
                            _callLogOutDialog();
                            _isLogInClicked = false;
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Column(
              children: [
                ChangeNotifierProvider.value(
                  value: ModeratorHelper.getInstance(),
                  child: Consumer<ModeratorHelper>(
                      builder: (context, model, child) {
                    return StreamBuilder(
                      stream: moderatorSocket.setModeratorResponse.getResponse,
                      builder: (BuildContext context,
                          AsyncSnapshot<Map> peerlistSnapshot) {
                        if (peerlistSnapshot.hasData &&
                            moderatorSocket.peerListHasNewData) {
                          moderatorSocket.peerListHasNewData = false;
                          var messageFor = peerlistSnapshot.data!['messageFor'];
                          var action = peerlistSnapshot.data!['action'];
                          if (action == 'update-peerlist') {
                            var displays = Displays().getDisplays();
                            if (displays
                                .contains(DisplayInfo(displayId: messageFor))) {
                              DisplayInfo display = displays.firstWhere(
                                  (element) => element.displayId == messageFor,
                                  orElse: null);
                              int tempPresenterTime = display.presenterTime;
                              var temp = display.peerList;
                              display.clearStatus();

                              List value =
                                  peerlistSnapshot.data!['extra']['peerlist'];
                              value.sort((a, b) => a['presenter']['name']
                                  .compareTo(b['presenter']['name']));
                              AppAnalytics()
                                  .trackEventModeratorPresentersListUpdated(
                                      value.length.toString());
                              for (int i = 0; i < value.length; i++) {
                                DisplayPeer peer = DisplayPeer();
                                peer.id = value[i]['presenter']['id'];
                                peer.presenter = value[i]['presenter']['name'];
                                peer.status = value[i]['status'];
                                peer.peer = value[i];
                                peer.key = GlobalKey();
                                String action = value[i]['action'];
                                for (var element in temp) {
                                  if (element.id == peer.id) {
                                    peer.waitReply = element.waitReply;
                                  }
                                }
                                if (action == peer.status) {
                                  peer.waitReply = false;
                                }

                                if (peer.status != 'remove') {
                                  display.peerList.add(peer);
                                } else {
                                  if (SplitScreen.mapSplitScreen
                                      .value[keySplitScreenEnable]) {
                                    if (display.splitIndexMap
                                        .containsValue(peer.id)) {
                                      display.splitIndexMap
                                          .forEach((key, value) {
                                        if (value == (peer.id)) {
                                          display.splitIndexMap[key] = '';
                                        }
                                      });
                                    }
                                  }
                                }

                                if (peer.status == 'stop') {
                                  if (SplitScreen.mapSplitScreen
                                      .value[keySplitScreenEnable]) {
                                    if (display.splitIndexMap
                                        .containsValue(peer.id)) {
                                      display.splitIndexMap
                                          .forEach((key, value) {
                                        if (value == (peer.id)) {
                                          display.splitIndexMap[key] = '';
                                        }
                                      });
                                    }
                                  }
                                }

                                if (peer.status == 'play' ||
                                    peer.status == 'pause') {
                                  if (SplitScreen.mapSplitScreen
                                      .value[keySplitScreenEnable]) {
                                    // check
                                    display.splitIndexMap.forEach((key, value) {
                                      if (!display.splitIndexMap
                                          .containsValue(peer.id)) {
                                        print('zz map $key $value');
                                        if (value == '') {
                                          display.splitIndexMap[key] = peer.id;
                                        }
                                      }
                                    });
                                  } else {
                                    if (display.peerList[i].id !=
                                        display.presenterId) {
                                      moderatorSocket.peerAction(
                                          'stop',
                                          display.peerList[i].peer,
                                          display.displayResponse);
                                    } else {
                                      display.presenterIndex = i;
                                      display.presenterName = peer.presenter;
                                      display.presenterStatus = peer.status;
                                      display.presenterSignalStrength = 0.5;
                                      display.presenterTime = tempPresenterTime;
                                    }
                                  }
                                }
                              }
                            }
                          }
                        } else if (peerlistSnapshot.hasData &&
                            moderatorSocket.setModeratorHasNewData) {
                          moderatorSocket.setModeratorHasNewData = false;
                          var property = peerlistSnapshot.data!['property'];
                          if (property != null && property.length > 0) {
                            // bindToDisplay will have property
                            var display = DisplayInfo(
                              displayId: peerlistSnapshot.data!['code'],
                              displayResponse: peerlistSnapshot.data,
                            );
                            Displays().addDisplayInfo(display);
                          }
                        } else if (peerlistSnapshot.hasData &&
                            moderatorSocket.unsetModeratorHasNewData) {
                          moderatorSocket.unsetModeratorHasNewData = false;
                          var displays = Displays().getDisplays();
                          var messageFor = peerlistSnapshot.data!['messageFor'];
                          if (displays
                              .contains(DisplayInfo(displayId: messageFor))) {
                            widget.logout();
                          }
                        }
                        return StreamBuilder(
                          stream: moderatorSocket.streamSocket.getResponse,
                          builder: (BuildContext context,
                              AsyncSnapshot<Map> socketSnapshot) {
                            if (socketSnapshot.hasData &&
                                moderatorSocket.socketHasNewData) {
                              moderatorSocket.socketHasNewData = false;
                              var displays = Displays().getDisplays();
                              var messageFor =
                                  socketSnapshot.data!['messageFor'];
                              var action = socketSnapshot.data!['action'];
                              switch (action) {
                                case ModeratorSocket.DISPLAY_STATE_UPDATE:
                                  if (displays.contains(
                                      DisplayInfo(displayId: messageFor))) {
                                    DisplayInfo display = displays.firstWhere(
                                        (element) =>
                                            element.displayId == messageFor,
                                        orElse: null);
                                    display.uiStateCode = socketSnapshot
                                        .data!['extra']['uiState']['code'];
                                    display.uiStateDelegate = socketSnapshot
                                        .data!['extra']['uiState']['delegate'];
                                    displays
                                        .map((e) => e == display ? display : e)
                                        .toList();
                                  }
                                  break;
                                case ModeratorSocket.UPDATE_DISPLAY_LIST:
                                  if (messageFor ==
                                      AppPreferences().moderatorId) {
                                    _queryDisplay(
                                        displays,
                                        socketSnapshot.data!['extra']
                                            ['displays']);
                                  }
                                  break;
                              }
                            }
                            return Expanded(
                              flex: 1,
                              child: PresenterList(
                                  widget.presenterListKey,
                                  SplitScreen.mapSplitScreen
                                      .value[keySplitScreenEnable]),
                            );
                          },
                        );
                      },
                    );
                  }),
                ),
                ValueListenableBuilder(
                  valueListenable: ModeratorView.showModeratorMessage,
                  builder: (BuildContext context, bool value, Widget? child) {
                    return Visibility(
                      visible: value,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15)),
                          color: AppColors.semantic2,
                        ),
                        child: Row(
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child:
                                  Icon(Icons.info_outline, color: Colors.white),
                            ),
                            Text(S.of(context).moderator_verifyCode_fail),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _queryDisplay(
      List<DisplayInfo> displays, dynamic displayIds) async {
    if (displayIds is List) {
      for (final element in displayIds) {
        if (!displays.contains(DisplayInfo(displayId: element['code']))) {
          moderatorSocket.queryDisplay(element['code']);
        }
      }
    }
  }

  void _callSplitScreenDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: '',
          description: SplitScreen.mapSplitScreen.value[keySplitScreenEnable]
              ? S.of(context).moderator_deactivate_split_screen
              : S.of(context).moderator_activate_split_screen,
          positiveButton: S.of(context).moderator_confirm,
          onPositive: () {
            setState(() {
              SplitScreen.mapSplitScreen.value[keySplitScreenEnable] =
                  !SplitScreen.mapSplitScreen.value[keySplitScreenEnable];
              // Using below method to trigger value changed. https://github.com/flutter/flutter/issues/29958
              SplitScreen.mapSplitScreen.value =
                  Map.from(SplitScreen.mapSplitScreen.value);

              if (!SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
                AppAnalytics().trackEventModeratorSplitScreenOff();
                var display = Displays().getSelectedDisplay();
                // check whether the presenters are playing
                display.splitIndexMap.forEach((key, value) {
                  if (value != '') {
                    for (var element in display.peerList) {
                      if (element.id == value) {
                        moderatorSocket.peerAction(
                            'stop', element.peer, display.displayResponse);
                      }
                    }
                  }
                });
              } else {
                AppAnalytics().trackEventModeratorSplitScreenOn();
              }
            });
          },
          onNegative: () {},
        );
      },
    );
  }

  void _callLogOutDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: '',
          description: S.of(context).moderator_exit_dialog,
          positiveButton: S.of(context).moderator_exit,
          onPositive: () {
            setState(() {
              AppAnalytics().trackEventModeratorOff();
              widget.logout();
              streamFunctionKey.currentState?.setState(() {
                ControlSocket().moderator = null;
              });
            });
          },
          onNegative: () {},
        );
      },
    );
  }

  Future<bool> verifyCode() async {
    var moderator = moderatorSocket.createModerator('Guest', '');
    AppPreferences().set(moderatorId: moderator.id);
    moderatorSocket.connectAndListen(context);
    try {
      await moderatorSocket
          .bindToDisplay(ControlSocket().displayCode, ControlSocket().otpCode,
              ControlSocket().token)
          .then((value) {
        AppAnalytics().trackEventModeratorOn();
        streamFunctionKey.currentState?.setState(() {});
      }).catchError((dynamic e) {
        Future.delayed(const Duration(seconds: 5), () {
          ModeratorView.showModeratorMessage.value = false;
        });
        ModeratorView.showModeratorMessage.value = true;
      });
    } catch (e) {
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
