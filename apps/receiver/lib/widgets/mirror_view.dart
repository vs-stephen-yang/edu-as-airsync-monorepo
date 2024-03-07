import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_ui_constant.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

class MirrorView extends StatefulWidget {
  const MirrorView({super.key, required this.index});

  final int index;

  @override
  State<StatefulWidget> createState() => MirrorViewState();
}

  class MirrorViewState extends State<MirrorView> {
  MirrorRequest? mirrorRequest;
  List<BuildContext> savedPinCodeBuildContext = [];
  List<BuildContext> savedPromptBuildContext = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<MirrorStateProvider>(
      builder: (context, mirror, child) {
        // region Show PinCode mechanism
        mirrorRequest = HybridConnectionList().hybridConnectionList[widget.index];
        if (mirror.pinCode != '' && savedPinCodeBuildContext.isEmpty) {
          // Show dialog if pin code is not empty.
          Future.delayed(Duration.zero, () {
            _showPinCodeDialog(context);
          });
        } else if (savedPinCodeBuildContext.isNotEmpty &&
            mirror.pinCode == '') {
          Future.delayed(Duration.zero, () {
            // If any pin code dialog has show on screen than
            // pin code has been cleared, will close dialog.
            for (var i = 0; i < savedPinCodeBuildContext.length; i++) {
              if (Navigator.canPop(savedPinCodeBuildContext[i])) {
                Navigator.pop(savedPinCodeBuildContext[i]);
              }
            }
            savedPinCodeBuildContext.clear();
          });
        }
        // endregion

        // region Show Prompt mechanism
        else if (mirrorRequest?.mirrorState == MirrorState.idle &&
            savedPromptBuildContext.isEmpty) {
          Future.delayed(Duration.zero, () {
            _showPromptDialog(context);
          });
        }
        else if (savedPromptBuildContext.isNotEmpty &&
            mirrorRequest?.mirrorState == MirrorState.mirroring) {
          Future.delayed(Duration.zero, () {
            for (var i = 0; i < savedPromptBuildContext.length; i++) {
              if (Navigator.canPop(savedPromptBuildContext[i])) {
                Navigator.pop(savedPromptBuildContext[i]);
              }
            }
            savedPromptBuildContext.clear();
          });
        }
        // endregion

        return ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Stack(
            children: [
              if (mirrorRequest?.mirrorState == MirrorState.mirroring)
                Container(
                  color: Colors.black,
                  child: Center(
                    child: NotificationListener<SizeChangedLayoutNotification>(
                      onNotification: (notification) {
                        mirror.onWidgetSizeChanged();
                        return true;
                      },
                      child: SizeChangedLayoutNotifier(
                        child: Listener(
                          onPointerDown: (PointerDownEvent event) {
                            mirror.onTouchEvent(event, mirrorRequest?.mirrorId);
                          },
                          onPointerMove: (PointerMoveEvent event) {
                            mirror.onTouchEvent(event, mirrorRequest?.mirrorId);
                          },
                          onPointerUp: (PointerUpEvent event) {
                            mirror.onTouchEvent(event, mirrorRequest?.mirrorId);
                          },
                          child: AspectRatio(
                            key: mirror.mirrorViewKey,
                            aspectRatio: mirrorRequest?.aspectRatio ?? 2 / 3,
                            child: Texture(textureId: mirrorRequest?.textureId ?? 0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  _showPinCodeDialog(
      BuildContext context) {
    FocusScope.of(context).unfocus();
    MirrorStateProvider mirrorStateProvider =
        Provider.of<MirrorStateProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext buildContext) {
        savedPinCodeBuildContext.add(buildContext);
        return WillPopScope(
          // Using onWillPop to block back key return,
          // it will break "Show PinCode mechanism"
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            alignment: Alignment.bottomRight,
            child: Container(
              width: MediaQuery.of(context).size.width / 3,
              height: MediaQuery.of(context).size.height / 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.airplay),
                            Text(
                              S.of(context).main_airplay_pin_code,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Consumer<MirrorStateProvider>(
                          builder: (context, mirror, child) {
                            return Text(
                              mirror.pinCode,
                              style: const TextStyle(fontSize: 28),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: FocusIconButton(
                      icons: Icons.cancel_outlined,
                      iconForegroundColor: Colors.white,
                      hasFocusSize: AppUIConstant.iconHasFocusSize,
                      notFocusSize: AppUIConstant.iconNotFocusSize,
                      onClick: () {
                        mirrorStateProvider.clearPinCode();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _showPromptDialog(
      BuildContext context) {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        savedPromptBuildContext.add(context);
        return WillPopScope(
          // Using onWillPop to block back key return,
          // it will break "Show Prompt mechanism"
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            alignment: Alignment.bottomRight,
            child: Consumer<MirrorStateProvider>(
              builder: (context, mirror, child) {
                var width = MediaQuery.of(context).size.width / 3;
                var height = MediaQuery.of(context).size.height / 4;
                double minHeight = min(
                    (HybridConnectionList().getMirrorMap().length * height).toDouble(),
                    500.0);
                return SizedBox(
                  width: width,
                  height: minHeight,
                  child: ListView.separated(
                    reverse: mirror.isMirroring,
                    itemCount: HybridConnectionList().getMirrorMap().length,
                    itemBuilder: (BuildContext buildContext, int index) {
                      return Container(
                        width: width,
                        height: height,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              sprintf(S.current.main_mirror_from_client,
                                  [HybridConnectionList().getMirrorMap().values.toList()[index].mirrorId]),
                              style: const TextStyle(fontSize: 24),
                            ),
                            const Spacer(),
                            Wrap(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10,
                              children: <Widget>[
                                FocusElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.white,
                                  ),
                                  hasFocusWidth: 110,
                                  notFocusWidth: 100,
                                  hasFocusHeight: 30,
                                  notFocusHeight: 25,
                                  onClick: () {
                                    //TODO: found that AirPlay icon on iMac keeps under working state even calling clearRequestMirrorId()
                                    mirror.clearRequestMirrorId(index);
                                    Navigator.pop(context);
                                  },
                                  child: AutoSizeText(
                                    S.of(context).main_mirror_prompt_cancel,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                                FocusElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                    backgroundColor: Colors.blue,
                                  ),
                                  hasFocusWidth: 110,
                                  notFocusWidth: 100,
                                  hasFocusHeight: 30,
                                  notFocusHeight: 25,
                                  onClick: () async {
                                    print('prompt dialog split screen');
                                    mirror.setAcceptMirrorId(index);
                                    Navigator.pop(context);
                                  },
                                  child: AutoSizeText(
                                    S.of(context).main_mirror_prompt_accept,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext buildContext, int index) {
                      return const SizedBox(
                        height: 5,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
