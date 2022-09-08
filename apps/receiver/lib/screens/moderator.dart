import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/model/displays.dart';
import 'package:display_flutter/model/moderator_helper.dart';
import 'package:display_flutter/model/moderator_socket.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/screens/presenter_list.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/widgets/custom_dialog.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class ModeratorView extends StatefulWidget {
  ModeratorView({Key? key}) : super(key: key);
  static ValueNotifier<bool> showModerator = ValueNotifier(false);
  static ValueNotifier<bool> showModeratorMessage = ValueNotifier(false);

  final GlobalKey<PresenterListState> attendeesListKey = GlobalKey();

  @override
  State createState() => _ModeratorViewState();

  void logout() {
    SplitScreen.mapSplitScreen.value[keySplitScreenEnable] = false;
    SplitScreen.mapSplitScreen.value[keySplitScreenCount] = 0;
    // Using below method to trigger value changed. https://github.com/flutter/flutter/issues/29958
    SplitScreen.mapSplitScreen.value =
        Map.from(SplitScreen.mapSplitScreen.value);
    attendeesListKey.currentState?.removeAllPresenter();
    Displays().getDisplays().forEach((element) {
      moderatorSocket.unBindFromDisplay(
          element.displayId, ControlSocket().token);
    });
    moderatorSocket.disconnect();
    Displays().removeAllDisplayInfo();
    AppPreferences().set(moderatorId: '');
    AppAnalytics().trackEventModeratorOff();
    showModerator.value = false;
  }
}

class _ModeratorViewState extends State<ModeratorView> {
  bool bEditClick = false;
  bool bLogInClick = false;

  final GlobalKey<SpiltIconState> _splitIconKey = GlobalKey();
  final GlobalKey<EditIconState> _editIconKey = GlobalKey();
  final GlobalKey<LogoutIconState> _logoutIconKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ModeratorView.showModerator,
      builder: (BuildContext context, bool value, Widget? child) {
        return Visibility(
          visible: value,
          child: ChangeNotifierProvider.value(
            value: ModeratorHelper.getInstance(),
            child: Consumer<ModeratorHelper>(builder: (context, model, child) {
              return Container(
                margin: const EdgeInsets.only(bottom: 140),
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width * 0.25,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  color: ControlSocket().isPresenting()
                      ? AppColors.primary_grey_tran
                      : AppColors.primary_grey,
                ),
                child: StreamBuilder(
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
                                  value.toString());
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
                              if (SplitScreen
                                  .mapSplitScreen.value[keySplitScreenEnable]) {
                                if (display.splitIndexMap
                                    .containsValue(peer.id)) {
                                  display.splitIndexMap.forEach((key, value) {
                                    if (value == (peer.id)) {
                                      display.splitIndexMap[key] = '';
                                    }
                                  });
                                }
                              }
                            }

                            if (peer.status == 'stop') {
                              if (SplitScreen
                                  .mapSplitScreen.value[keySplitScreenEnable]) {
                                if (display.splitIndexMap
                                    .containsValue(peer.id)) {
                                  display.splitIndexMap.forEach((key, value) {
                                    if (value == (peer.id)) {
                                      display.splitIndexMap[key] = '';
                                    }
                                  });
                                }
                              }
                            }

                            if (peer.status == 'play' ||
                                peer.status == 'pause') {
                              if (SplitScreen
                                  .mapSplitScreen.value[keySplitScreenEnable]) {
                                // check
                                display.splitIndexMap.forEach((key, value) {
                                  if (!display.splitIndexMap
                                      .containsValue(peer.id)) {
                                    print("zz map $key $value");
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
                    return Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.08,
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                          color: Colors.transparent,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 15,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back_ios,
                                        color: AppColors.primary_white),
                                    onPressed: () {
                                      AppAnalytics()
                                          .trackEventModeratorPanelClose();
                                      if (_isPresenting()) {
                                        StreamFunction.showStreamMenu.value =
                                            true;
                                      }
                                      ModeratorView.showModerator.value = false;
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 55,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: Text(
                                    S.of(context).moderator_presentersList,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary_white,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(flex: 10),
                              Expanded(
                                flex: 15,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: IconButton(
                                    icon: SpiltIcon(_splitIconKey),
                                    onPressed: () {
                                      if (Displays().getDisplays().isNotEmpty) {
                                        _callSplitScreenDialog();
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 15,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: IconButton(
                                    icon: EditIcon(_editIconKey),
                                    onPressed: () {
                                      AppAnalytics().trackEventModeratorEdit();
                                      if (Displays()
                                          .getSelectedDisplay()
                                          .peerList
                                          .isNotEmpty) {
                                        bEditClick = !bEditClick;
                                        widget.attendeesListKey.currentState!
                                            .updateEditStatus(bEditClick);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 15,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: getLogOutIcon(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        StreamBuilder(
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
                                  widget.attendeesListKey,
                                  updateEditIconState,
                                  SplitScreen.mapSplitScreen
                                      .value[keySplitScreenEnable]),
                            );
                          },
                        ),
                        ValueListenableBuilder(
                            valueListenable: ModeratorView.showModeratorMessage,
                            builder: (BuildContext context, bool value,
                                Widget? child) {
                              return Visibility(
                                  visible: value,
                                  child: Container(
                                    alignment: Alignment.bottomLeft,
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(15)),
                                      color: AppColors.semantic2,
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                8.0, 0.0, 8.0, 0.0),
                                            child: (const Icon(
                                                Icons.info_outline,
                                                color: Colors.white))),
                                        Expanded(
                                          child: Text(S
                                              .of(context)
                                              .moderator_verifyCode_fail),
                                        ),
                                      ],
                                    ),
                                  ));
                            }),
                      ],
                    );
                  },
                ),
              );
            }),
          ),
        );
      },
    );
  }

  void updateLogoutIconState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _logoutIconKey.currentState?.setState(() {});
    });
  }

  void updateEditIconState(bool isEditMode) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _editIconKey.currentState?.setState(() {
        bEditClick = isEditMode;
      });
    });
  }

  Widget getLogOutIcon() {
    return IconButton(
      icon: LogoutIcon(_logoutIconKey),
      onPressed: () {
        if (!bLogInClick) {
          bLogInClick = true;
          if (Displays().getDisplays().isEmpty) {
            verifyCode().then((value) {
              updateLogoutIconState();
              bLogInClick = false;
            });
          } else {
            _callLogOutDialog();
            bLogInClick = false;
          }
        }
      },
    );
  }

  bool _isPresenting() {
    bool presenting = false;
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      var display = Displays().getSelectedDisplay();
      display.splitIndexMap.forEach((key, value) {
        if (value.isNotEmpty) {
          presenting = true;
        }
      });
    } else {
      if (Displays().getSelectedDisplay().presenterIndex != -1) {
        presenting = true;
      }
    }
    return presenting;
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

class SpiltIcon extends StatefulWidget {
  const SpiltIcon(Key key) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SpiltIconState();
  }
}

class SpiltIconState extends State<SpiltIcon> {
  @override
  Widget build(BuildContext context) {
    return Image(
      image: Svg(Displays().getDisplays().isEmpty
          ? 'assets/images/ic_moderator_split_screen_off.svg'
          : SplitScreen.mapSplitScreen.value[keySplitScreenEnable]
              ? 'assets/images/ic_moderator_split_screen_activate.svg'
              : 'assets/images/ic_moderator_split_screen_on.svg'),
    );
  }
}

class EditIcon extends StatefulWidget {
  const EditIcon(Key key) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EditIconState();
  }
}

class EditIconState extends State<EditIcon> {
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.edit,
      color: Displays().getSelectedDisplay().peerList.isEmpty
          ? AppColors.neutral4
          : AppColors.primary_white,
    );
  }
}

class LogoutIcon extends StatefulWidget {
  const LogoutIcon(Key key) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LogoutIconState();
  }
}

class LogoutIconState extends State<LogoutIcon> {
  @override
  Widget build(BuildContext context) {
    return Image(
      image: Svg((Displays().getDisplays().isNotEmpty)
          ? 'assets/images/ic_activate_on.svg'
          : 'assets/images/ic_activate_off.svg'),
    );
  }
}
