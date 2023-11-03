import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/model/display_info.dart';
import 'package:display_flutter/model/present_helper.dart';
import 'package:display_flutter/model/moderator_socket.dart';
import 'package:display_flutter/widgets/presenter_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PresenterList extends StatefulWidget {
  const PresenterList({super.key, this.onUnSetLogOut});

  final VoidCallback? onUnSetLogOut;

  @override
  State createState() => _PresenterListState();
}

class _PresenterListState extends State<PresenterList> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: PresentHelper.getInstance(),
      child: Consumer<PresentHelper>(builder: (context, model, child) {
        return StreamBuilder(
          stream: moderatorSocket.setModeratorResponse.getResponse,
          builder: (BuildContext context, AsyncSnapshot<Map> peerlistSnapshot) {
            if (peerlistSnapshot.hasData) {
              if (moderatorSocket.peerListHasNewData) {
                moderatorSocket.peerListHasNewData = false;

                var messageFor = peerlistSnapshot.data!['messageFor'];
                var action = peerlistSnapshot.data!['action'];

                if (ControlSocket().displayCode == messageFor &&
                    action == 'update-peerlist') {
                  DisplayInfo().clearPeerList();

                  List peerList = peerlistSnapshot.data!['extra']['peerlist'];
                  peerList.sort((a, b) =>
                      a['presenter']['name'].compareTo(b['presenter']['name']));

                  AppAnalytics().trackEventModeratorPresentersListUpdated(
                      peerList.length.toString());

                  for (int i = 0; i < peerList.length; i++) {
                    DisplayPeer peer = DisplayPeer();
                    peer.id = peerList[i]['presenter']['id'];
                    peer.presenter = peerList[i]['presenter']['name'];
                    peer.status = peerList[i]['status'];
                    peer.peer = peerList[i];

                    if (peer.status != 'remove') {
                      DisplayInfo().peerList.add(peer);
                    }
                  }
                }
              } else if (moderatorSocket.setModeratorHasNewData) {
                moderatorSocket.setModeratorHasNewData = false;

                var property = peerlistSnapshot.data!['property'];

                if (property != null && property.length > 0) {
                  // bindToDisplay will have property
                  DisplayInfo().setBindToDisplayInfo(peerlistSnapshot.data);
                }
              } else if (moderatorSocket.unsetModeratorHasNewData) {
                moderatorSocket.unsetModeratorHasNewData = false;

                var messageFor = peerlistSnapshot.data!['messageFor'];

                if (ControlSocket().displayCode == messageFor) {
                  widget.onUnSetLogOut?.call();
                }
              }
            }
            return StreamBuilder(
              stream: moderatorSocket.streamSocket.getResponse,
              builder:
                  (BuildContext context, AsyncSnapshot<Map> socketSnapshot) {
                if (socketSnapshot.hasData &&
                    moderatorSocket.socketHasNewData) {
                  moderatorSocket.socketHasNewData = false;
                  var messageFor = socketSnapshot.data!['messageFor'];
                  var action = socketSnapshot.data!['action'];
                  switch (action) {
                    case ModeratorSocket.cmdDisplayStateUpdate:
                      // Deprecated (show display code, delegate)
                      break;
                    case ModeratorSocket.cmdUpdateDisplayList:
                      if (messageFor == AppPreferences().moderatorId) {
                        dynamic displayIds =
                            socketSnapshot.data!['extra']['displays'];
                        if (displayIds is List) {
                          for (final element in displayIds) {
                            if (ControlSocket().displayCode !=
                                element['code']) {
                              moderatorSocket.queryDisplay(element['code']);
                            }
                          }
                        }
                      }
                      break;
                  }
                }
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: DisplayInfo().peerList.isEmpty
                      ? Container(
                          alignment: Alignment.center,
                          child: Text(
                            S.of(context).moderator_presentersLimit,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView.separated(
                          itemCount: DisplayInfo().peerList.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (index > 5) return const SizedBox();

                            return PresenterItem(index: index);
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider(height: 0, color: Colors.transparent);
                          },
                        ),
                );
              },
            );
          },
        );
      }),
    );
  }
}
