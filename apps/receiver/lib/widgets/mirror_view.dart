import 'dart:math';

import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

class MirrorView extends StatelessWidget {
  const MirrorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<BuildContext> savedPinCodeBuildContext = [];
    List<BuildContext> savedPromptBuildContext = [];
    return Consumer<MirrorStateProvider>(
      builder: (context, mirror, child) {
        // region Show PinCode mechanism
        if (mirror.pinCode != '' && savedPinCodeBuildContext.isEmpty) {
          // Show dialog if pin code is not empty.
          Future.delayed(Duration.zero, () {
            _showPinCodeDialog(context, savedPinCodeBuildContext);
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
        print(
            '_LOREN_, _showPromptDialog savedPromptBuildContext: ${savedPromptBuildContext.length}');
        print(
            '_LOREN_, _showPromptDialog requestingMirror: ${mirror.requestingMirror.length}');
        if (mirror.requestingMirror.isNotEmpty &&
            savedPromptBuildContext.isEmpty) {
          Future.delayed(Duration.zero, () {
            if (mirror.requestingMirror.isNotEmpty) {
              _showPromptDialog(context, savedPromptBuildContext);
            }
          });
        } else if (savedPromptBuildContext.isNotEmpty &&
            mirror.requestingMirror.isEmpty) {
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
              if (mirror.isMirroring)
                Container(
                  color: Colors.black,
                  child: Center(
                    child: Listener(
                      onPointerDown: mirror.onTouchEvent,
                      onPointerMove: mirror.onTouchEvent,
                      onPointerUp: mirror.onTouchEvent,
                      child: AspectRatio(
                        key: mirror.mirrorViewKey,
                        aspectRatio: mirror.aspectRatio,
                        child: Texture(textureId: mirror.textureId!),
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
      BuildContext context, List<BuildContext> savedPinCodeBuildContext) {
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
            alignment: mirrorStateProvider.isMirroring
                ? Alignment.bottomRight
                : Alignment.center,
            child: Container(
              width: MediaQuery.of(context).size.width /
                  (mirrorStateProvider.isMirroring ? 5 : 3),
              height: MediaQuery.of(context).size.height /
                  (mirrorStateProvider.isMirroring ? 4 : 2),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.airplay,
                          color: Colors.white,
                        ),
                        Text(
                          S.of(context).main_airplay_pin_code,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      mirrorStateProvider.pinCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  _showPromptDialog(
      BuildContext context, List<BuildContext> savedPromptBuildContext) {
    FocusScope.of(context).unfocus();
    MirrorStateProvider mirrorStateProvider =
        Provider.of<MirrorStateProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext buildContext) {
        savedPromptBuildContext.add(buildContext);
        return WillPopScope(
          // Using onWillPop to block back key return,
          // it will break "Show Prompt mechanism"
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            alignment: mirrorStateProvider.isMirroring
                ? Alignment.bottomRight
                : Alignment.center,
            child: Consumer<MirrorStateProvider>(
              builder: (context, mirror, child) {
                var width = MediaQuery.of(context).size.width / 5;
                var height = MediaQuery.of(context).size.height / 4;
                double minHeight = min(
                    (mirror.requestingMirror.length * height).toDouble(),
                    500.0);
                return SizedBox(
                  width: width,
                  height: minHeight,
                  child: ListView.separated(
                    reverse: mirrorStateProvider.isMirroring,
                    itemCount: mirror.requestingMirror.length,
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
                                  [mirror.requestingMirror[index].mirrorId]),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
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
                                    mirror.clearRequestMirrorId(index);
                                  },
                                  child: Text(
                                    S.of(context).main_mirror_prompt_cancel,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.blue,
                                    ),
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
                                  onClick: () {
                                    mirror.setAcceptMirrorId(index);
                                  },
                                  child: Text(
                                    S.of(context).main_mirror_prompt_accept,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
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
