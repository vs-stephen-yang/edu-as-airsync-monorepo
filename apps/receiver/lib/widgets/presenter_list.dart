import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/displays.dart';
import 'package:display_flutter/model/moderator_socket.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/widgets/check_box_switch.dart';
import 'package:flutter/material.dart';

class PresenterList extends StatefulWidget {
  bool isSplit = false;
  Key? listKey;

  PresenterList(this.listKey, this.isSplit)
      : super(key: listKey);

  @override
  PresenterListState createState() => PresenterListState();
}

class PresenterListState extends State<PresenterList> {
  bool isOpen = false;
  bool bEditNotifier = false;

  @override
  Widget build(BuildContext context) {
    var display = Displays().getSelectedDisplay();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        children: [
          Displays().getSelectedDisplay().peerList.isEmpty
              ? Expanded(
                  child: Container(
                  alignment: Alignment.topCenter,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                  child: Text(
                    S.of(context).moderator_presentersLimit,
                    style: const TextStyle(color: Colors.white),
                  ),
                ))
              : Expanded(
                  flex: 7,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: ListView.separated(
                          itemCount: display.peerList.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (index > 5) return const SizedBox();
                            var name = display.peerList[index].presenter;
                            var status = display.peerList[index].status;
                            var peer = display.peerList[index].peer;
                            var id = display.peerList[index].id;
                            var bWait = display.peerList[index].waitReply;
                            int splitIndex = 0;
                            if (display.splitIndexMap.containsValue(id)) {
                              display.splitIndexMap.forEach((key, value) {
                                if (value == id) {
                                  splitIndex = key;
                                }
                              });
                            }

                            CheckBoxSwitch toggleSwitch = CheckBoxSwitch(
                              itemKey: display.peerList[index].key,
                              height: MediaQuery.of(context).size.height * 0.07,
                              width: MediaQuery.of(context).size.width * 0.2,
                              name: name,
                              bEdit: bEditNotifier,
                              bOpen: (status == 'play' || status == 'pause'),
                              bWait: bWait,
                              bSplit: widget.isSplit,
                              splitIndex: splitIndex,
                              onOpen: (value) {
                                if (value) {
                                  // Should check all element to prevent quickly switch presenter.
                                  var result = display.peerList
                                      .where((element) => element.waitReply)
                                      .toList();
                                  if (result.isNotEmpty) return;
                                  display.peerList[index].waitReply = true;

                                  if (widget.isSplit) {
                                    bool bAdd = false;
                                    display.splitIndexMap.forEach((key, value) {
                                      if (value == '') {
                                        bAdd = true;
                                      }
                                    });
                                    if (!bAdd) {
                                      display.peerList[index].waitReply = false;
                                      return;
                                    }
                                  } else {
                                    // check other presenters' status and close the presenter
                                    for (int i = 0;
                                        i < display.peerList.length;
                                        i++) {
                                      if (display.peerList[i].status ==
                                          'play') {
                                        if (i != index) {
                                          _sendPresenterStop(display,
                                              display.peerList[i].peer);
                                          Future.delayed(
                                                  const Duration(seconds: 2))
                                              .then((value) {
                                            _sendPresenterPlay(
                                                display, peer, id, status);
                                          });
                                          return;
                                        }
                                      }
                                    }
                                  }
                                  _sendPresenterPlay(display, peer, id, status);
                                } else {
                                  if (display.peerList[index].waitReply) return;
                                  if (display.presenterId == id) {
                                    display.presenterId = '';
                                  }
                                  _sendPresenterStop(display, peer);
                                }
                              },
                              onRemove: (value) {},
                            );
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                toggleSwitch,
                              ],
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider(height: 10);
                          }))),
          Visibility(
              visible: bEditNotifier,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          bEditNotifier = false;
                        });
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.white,
                        ),
                        child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Text(
                              S.of(context).moderator_cancel,
                              style: const TextStyle(
                                  color: AppColors.primary_grey),
                            )),
                      ),
                    ),
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () {
                        AppAnalytics().trackEventModeratorPresentersRemove();
                        for (int i = 0;
                            i < Displays().getSelectedDisplay().peerList.length;
                            i++) {
                          if (display.peerList[i].key.currentState!
                              .getChecked()) {
                            var id = display.peerList[i].id;
                            if (SplitScreen
                                .mapSplitScreen.value[keySplitScreenEnable]) {
                              if (display.splitIndexMap.containsValue(id)) {
                                display.splitIndexMap.forEach((key, value) {
                                  if (value == id) {
                                    display.splitIndexMap[key] = '';
                                  }
                                });
                              }
                            }
                            _removePresenter(
                                context,
                                Displays().getSelectedDisplay(),
                                Displays()
                                    .getSelectedDisplay()
                                    .peerList[i]
                                    .peer);
                          }
                        }
                        bEditNotifier = false;
                      },
                      child: Container(
                          height: MediaQuery.of(context).size.height * 0.05,
                          width: MediaQuery.of(context).size.width * 0.4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: AppColors.primary_red,
                          ),
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Text(S.of(context).moderator_remove,
                                style: const TextStyle(color: Colors.white)),
                          )),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  _removePresenter(BuildContext context, DisplayInfo display, dynamic peer) {
    moderatorSocket.peerAction('remove', peer, display.displayResponse);
  }

  void removeAllPresenter() {
    for (int i = 0; i < Displays().getSelectedDisplay().peerList.length; i++) {
      moderatorSocket.peerAction(
          'remove',
          Displays().getSelectedDisplay().peerList[i].peer,
          Displays().getSelectedDisplay().displayResponse);
    }
  }

  _sendPresenterPlay(
      DisplayInfo display, dynamic peer, String id, String status) {
    display.presenterId = id;

    AppAnalytics().trackEventModeratorPresenterPresent();
    moderatorSocket.peerAction('play', peer, display.displayResponse);

    String action = (status == 'play' || status == 'pause') ? 'stop' : 'play';
    display.setPresenterTimeTimer(action == 'play');
  }

  _sendPresenterStop(DisplayInfo display, dynamic peer) {
    AppAnalytics().trackEventModeratorPresenterStop();
    moderatorSocket.peerAction('stop', peer, display.displayResponse);
  }

  void updateEditStatus(bool status) {
    setState(() {
      bEditNotifier = status;
    });
  }
}
