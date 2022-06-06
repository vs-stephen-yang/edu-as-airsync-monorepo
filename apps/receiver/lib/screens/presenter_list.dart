import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/displays.dart';
import 'package:display_flutter/model/moderator_socket.dart';
import 'package:display_flutter/widgets/click_switch.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PresenterList extends StatefulWidget {
  bool isSplit = false;
  Key? bkey;
  final ValueChanged<bool> updateEditIcon;

  PresenterList(this.bkey, this.updateEditIcon, this.isSplit) : super(key: bkey);

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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        children: [
          Displays().getSelectedDisplay().peerList.isEmpty
              ? Expanded(
                  child: Container(
                  alignment: Alignment.topCenter,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
                  child: Text(
                    S.of(context).moderator_presentersLimit,
                    style: TextStyle(color: Colors.white),
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
                            int splitIndex = 0;
                            if (display.splitIndexMap
                                .containsValue(display.peerList[index].id)) {
                              display.splitIndexMap.forEach((key, value) {
                                if (value == display.peerList[index].id) {
                                  splitIndex = key;
                                }
                              });
                            }

                            CheckBoxSwitch toggleSwitch = CheckBoxSwitch(
                              itemKey: display.peerList[index].key,
                              height: MediaQuery.of(context).size.height * 0.08,
                              width: MediaQuery.of(context).size.width * 0.2,
                              name: name,
                              isEdit: bEditNotifier,
                              isOpen: (status == 'play' || status == 'pause'),
                              isSplit: widget.isSplit,
                              splitIndex: splitIndex,
                              onOpen: (value) {
                                setState(() {
                                  EasyDebounce.debounce(
                                      'stop_play', Duration(milliseconds: 1000),
                                      () {
                                    if (value) {
                                      if (widget.isSplit) {
                                        bool bAdd = false;
                                        display.splitIndexMap.forEach((key, value) {
                                          if (value == '') {
                                            bAdd = true;
                                          }
                                        });
                                        if (!bAdd) {
                                          return;
                                        }
                                      } else {
                                        // check other presenters' status
                                        int checkPlayStatus = 0;
                                        int repeatedStatusIndex = 0;
                                        for (int i = 0;
                                            i < display.peerList.length;
                                            i++) {
                                          if (display.peerList[i].status ==
                                              'play') {
                                            checkPlayStatus++;
                                            if (i != index) {
                                              repeatedStatusIndex = i;
                                            }
                                          }
                                        }
                                        if (checkPlayStatus > 0) {
                                          // close the presenter
                                          // AppAnalytics()
                                          //     .trackEventPresentClicked();
                                          moderatorSocket.peerAction(
                                              'stop',
                                              display
                                                  .peerList[repeatedStatusIndex]
                                                  .peer,
                                              display.displayResponse);
                                        }
                                      }

                                      // play
                                      String action = (status == 'play' ||
                                              status == 'pause')
                                          ? 'stop'
                                          : 'play';
                                      // AppAnalytics()
                                      //     .trackEventPresentClicked();
                                      moderatorSocket.peerAction('play', peer,
                                          display.displayResponse);

                                      display.setPresenterTimeTimer(
                                          action == 'play');
                                    } else {
                                      // AppAnalytics().trackEventPresentClicked();
                                      moderatorSocket.peerAction('stop', peer,
                                          display.displayResponse);
                                    }
                                  });
                                });
                              },
                              onRemove: (value) {
                                // AppAnalytics().trackEventKickoffClicked();
                              },
                            );
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                toggleSwitch,
                              ],
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider(height: 10);
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
                          widget.updateEditIcon(bEditNotifier);
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
                              style: TextStyle(color: AppColors.primary_grey),
                            )),
                      ),
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () {
                        for (int i = 0;
                            i < Displays().getSelectedDisplay().peerList.length;
                            i++) {
                          if (display.peerList[i].key.currentState!
                              .getChecked()) {
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
                        widget.updateEditIcon(bEditNotifier);
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
                                style: TextStyle(color: Colors.white)),
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
    // AppAnalytics().trackEventKickoffYes();
    moderatorSocket.peerAction('remove', peer, display.displayResponse);
  }

  void removeAllPresenter() {
    for (int i = 0; i < Displays().getSelectedDisplay().peerList.length; i++) {
      // AppAnalytics().trackEventKickoffYes();
      moderatorSocket.peerAction(
          'remove',
          Displays().getSelectedDisplay().peerList[i].peer,
          Displays().getSelectedDisplay().displayResponse);
    }
  }

  void updateEditStatus(bool status) {
    setState(() {
      bEditNotifier = status;
    });
  }
}
