import 'dart:math' as math;

import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/displays.dart';
import 'package:display_flutter/model/moderator_socket.dart';
import 'package:display_flutter/model/webrtc_info.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/screens/presenter_list.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/widgets/custom_dialog.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class ModeratorView extends StatefulWidget {
  const ModeratorView({Key? key}) : super(key: key);

  @override
  State createState() => _ModeratorViewState();
}

class _ModeratorViewState extends State<ModeratorView> {
  bool bEditClick = false;
  WebRTCInfo mWebRTCInfo = WebRTCInfo.getInstance();

  final GlobalKey<PresenterListState> _attendeesListKey = GlobalKey();
  final GlobalKey<SpiltIconState> _splitIconKey = GlobalKey();
  final GlobalKey<EditIconState> _editIconKey = GlobalKey();
  final GlobalKey<LogoutIconState> _logoutIconKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: AppColors.primary_grey,
        //TODO: the color is AppColors.primary_grey_tran during presenting
      ),
      child: StreamBuilder(
          stream: moderatorSocket.streamPeerlist.getResponse,
          builder: (BuildContext context, AsyncSnapshot<Map> peerlistSnapshot) {
            if (peerlistSnapshot.hasData &&
                moderatorSocket.peerListHasNewData) {
              moderatorSocket.peerListHasNewData = false;
              var messageFor = peerlistSnapshot.data!['messageFor'];
              var action = peerlistSnapshot.data!['action'];
              if (action == 'update-peerlist') {
                var displays = Displays().getDisplays();
                if (displays.contains(DisplayInfo(displayId: messageFor))) {
                  DisplayInfo display = displays.firstWhere(
                      (element) => element.displayId == messageFor,
                      orElse: null);
                  int tempPresenterTime = display.presenterTime;
                  var temp = display.peerList;
                  display.clearStatus();

                  List value = peerlistSnapshot.data!['extra']['peerlist'];
                  value.sort((a, b) =>
                      a['presenter']['name'].compareTo(b['presenter']['name']));
                  for (int i = 0; i < value.length; i++) {
                    DisplayPeer peer = DisplayPeer();
                    peer.id = value[i]['presenter']['id'];
                    peer.presenter = value[i]['presenter']['name'];
                    peer.status = value[i]['status'];
                    peer.peer = value[i];
                    peer.key = GlobalKey();
                    String action = value[i]['action'];
                    temp.forEach((element) {
                      if (element.id == peer.id) {
                        peer.waitReply = element.waitReply;
                      }
                    });
                    if(action == peer.status) {
                      peer.waitReply = false;
                    }

                    if (peer.status != 'remove') {
                      display.peerList.add(peer);
                    } else {
                      if (SplitScreen.splitScreenEnabled.value) {
                        if (display.splitIndexMap.containsValue(peer.id)) {
                          display.splitIndexMap.forEach((key, value) {
                            if (value == (peer.id)) {
                              display.splitIndexMap[key] = '';
                            }
                          });
                        }
                      }
                    }

                    if (peer.status == 'play' || peer.status == 'pause') {
                      if (SplitScreen.splitScreenEnabled.value) {
                        // check
                        display.splitIndexMap.forEach((key, value) {
                          if (!display.splitIndexMap.containsValue(peer.id)) {
                            print("zz map $key $value");
                            if (value == '') {
                              display.splitIndexMap[key] = peer.id;
                            }
                          }
                        });
                      } else {
                        if (display.peerList[i].id != display.presenterId) {
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
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: AppColors.primary_white),
                            onPressed: () {
                              StreamFunction.showModerator.value = false;
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Text(
                          S.of(context).moderator_presentersList,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary_white),
                        ),
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                      Expanded(
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
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: IconButton(
                            icon: EditIcon(_editIconKey),
                            onPressed: () {
                              if (Displays()
                                  .getSelectedDisplay()
                                  .peerList
                                  .isNotEmpty) {
                                bEditClick = !bEditClick;
                                _attendeesListKey.currentState!
                                    .updateEditStatus(bEditClick);
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Transform.rotate(
                              angle: 90 * math.pi / 180,
                              child: const Icon(Icons.horizontal_rule,
                                  color: AppColors.primary_white)),
                        ),
                      ),
                      getLogOutIcon(),
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
                        var messageFor = socketSnapshot.data!['messageFor'];
                        var action = socketSnapshot.data!['action'];
                        switch (action) {
                          case ModeratorSocket.DISPLAY_STATE_UPDATE:
                            if (displays
                                .contains(DisplayInfo(displayId: messageFor))) {
                              DisplayInfo display = displays.firstWhere(
                                  (element) => element.displayId == messageFor,
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
                            if (messageFor == AppPreferences().moderatorId) {
                              _queryDisplay(displays,
                                  socketSnapshot.data!['extra']['displays']);
                            }
                            break;
                        }
                      }
                      return Expanded(
                          flex: 1,
                          child: PresenterList(
                              _attendeesListKey,
                              updateEditIconState,
                              SplitScreen.splitScreenEnabled.value));
                    }),
                StreamBuilder(
                  stream: moderatorSocket.setModeratorResponse.getResponse,
                  builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
                    if (snapshot.hasData &&
                        moderatorSocket.setModeratorHasNewData) {
                      moderatorSocket.setModeratorHasNewData = false;
                      var property = snapshot.data!['property'];
                      if (property != null && property.length > 0) {
                        // bindToDisplay will have property
                        var display = DisplayInfo(
                          displayId: snapshot.data!['code'],
                          displayResponse: snapshot.data,
                        );
                        Displays().addDisplayInfo(display);
                        updateLogoutIconState();
                      }
                    } else if (snapshot.hasData &&
                        moderatorSocket.unsetModeratorHasNewData) {
                      moderatorSocket.unsetModeratorHasNewData = false;
                      var displays = Displays().getDisplays();
                      var messageFor = snapshot.data!['messageFor'];
                      if (displays
                          .contains(DisplayInfo(displayId: messageFor))) {
                        _logout();
                        updateLogoutIconState();
                      }
                    }
                    return getActivateButton();
                  },
                ),
              ],
            );
          }),
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
    return Expanded(
      child: FittedBox(
        fit: BoxFit.fitHeight,
        child: IconButton(
          icon: LogoutIcon(_logoutIconKey),
          onPressed: () {
            if (Displays().getDisplays().isNotEmpty) _callLogOutDialog();
          },
        ),
      ),
    );
  }

  Widget getActivateButton() {
    return Visibility(
        visible: Displays().getDisplays().isEmpty,
        child: Container(
            color: Colors.transparent,
            child: Row(
              children: [
                const Spacer(
                  flex: 1,
                ),
                Expanded(
                  flex: 8,
                  child: GestureDetector(
                    onTap: () {
                      verifyCode();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColors.primary_white,
                      ),
                      child: Text(S.of(context).moderator_activate,
                          style: const TextStyle(color: AppColors.neutral1)),
                    ),
                  ),
                ),
                const Spacer(
                  flex: 1,
                ),
              ],
            )));
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
          description: SplitScreen.splitScreenEnabled.value
              ? S.of(context).moderator_deactivate_split_screen
              : S.of(context).moderator_activate_split_screen,
          positiveButton: S.of(context).moderator_confirm,
          onPositive: () {
            setState(() {
              SplitScreen.splitScreenEnabled.value =
                  !SplitScreen.splitScreenEnabled.value;

              if (!SplitScreen.splitScreenEnabled.value) {
                var display = Displays().getSelectedDisplay();
                // check whether the presenters are playing
                display.splitIndexMap.forEach((key, value) {
                  if (value != '') {
                    display.peerList.forEach((element) {
                      if (element.id == value) {
                        moderatorSocket.peerAction(
                            'stop', element.peer, display.displayResponse);
                      }
                    });
                  }
                });
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
            // AppAnalytics().trackEventLogoutYes();
            setState(() {
              _logout();
              streamFunctionKey.currentState?.setState(() {
                WebRTCInfo.getInstance().moderatorMode = false;
              });
            });
          },
          onNegative: () {
            // AppAnalytics().trackEventLogoutNo();
          },
        );
      },
    );
  }

  void _logout() {
    SplitScreen.splitScreenEnabled.value = false;
    _attendeesListKey.currentState?.removeAllPresenter();
    Displays().getDisplays().forEach((element) {
      // AppAnalytics()
      //     .trackEventMeetingEnded(element.displayId, element.meetingId);
      moderatorSocket.unBindFromDisplay(element.displayId, mWebRTCInfo.token);
    });
    moderatorSocket.disconnect();
    Displays().removeAllDisplayInfo();
    AppPreferences().set(moderatorId: '');
    StreamFunction.showModerator.value = false;
  }

  bool verifyCode() {
    var moderator = moderatorSocket.createModerator('Guest', '');
    AppPreferences().set(moderatorId: moderator.id);
    moderatorSocket.connectAndListen(context);
    try {
      moderatorSocket
          .bindToDisplay(
              mWebRTCInfo.displayCode, mWebRTCInfo.otpCode, mWebRTCInfo.token)
          .then((value) {
        // AppAnalytics().trackEventMeetingStarted(
        //     value['code'] ?? '', value['property']['meetingId'] ?? '');
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            streamFunctionKey.currentState?.setState(() {});
          });
        });
      }).catchError((dynamic e) {});
    } catch (e) {
      return false;
    }
    return true;
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
      image: Displays().getDisplays().isEmpty
          ? const Svg('assets/images/ic_moderator_split_screen_off.svg')
          : SplitScreen.splitScreenEnabled.value
              ? const Svg(
                  'assets/images/ic_moderator_split_screen_activate.svg')
              : const Svg('assets/images/ic_moderator_split_screen_on.svg'),
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
    return Icon(Icons.edit,
        color: Displays().getSelectedDisplay().peerList.isEmpty
            ? AppColors.neutral4
            : AppColors.primary_white);
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
    return Icon(Icons.logout,
        color: Displays().getDisplays().isEmpty
            ? AppColors.neutral4
            : AppColors.primary_white);
  }
}
