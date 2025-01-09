import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

class V3MirrorPrompt extends StatefulWidget {
  const V3MirrorPrompt({super.key});

  @override
  State<StatefulWidget> createState() => _V3MirrorPromptState();
}

class _V3MirrorPromptState extends State<V3MirrorPrompt> {
  List<BuildContext> dialogContextList = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<MirrorStateProvider>(builder: (_, mirrorStateProvider, __) {
      var mirrorRequestIdles = HybridConnectionList()
          .getMirrorMap()
          .values
          .where((request) => request.mirrorState == MirrorState.idle);

      if (mirrorRequestIdles.isNotEmpty && dialogContextList.isEmpty) {
        for (MirrorRequest request
            in HybridConnectionList().getMirrorMap().values) {
          if (request.mirrorState == MirrorState.idle) {
            if (HybridConnectionList.hybridSplitScreenCount.value <
                HybridConnectionList.maxHybridSplitScreen) {
              Future.delayed(Duration.zero, () {
                _showAuthDialog(context);
              });
            } else {
              mirrorStateProvider.stopAcceptedMirror(request.mirrorId);
              Future.delayed(Duration.zero, () {
                _showMaxAmountToast();
              });
            }
          }
        }
      } else if (mirrorStateProvider.pinCode.isNotEmpty &&
          dialogContextList.isEmpty) {
        Future.delayed(Duration.zero, () {
          _showAuthDialog(context);
        });
      } else if (dialogContextList.isNotEmpty &&
          mirrorRequestIdles.isEmpty &&
          mirrorStateProvider.pinCode.isEmpty) {
        if (dialogContextList.isNotEmpty) {
          for (var context in dialogContextList) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          }
        }
        dialogContextList.clear();
      }
      return const SizedBox.shrink();
    });
  }

  _showMaxAmountToast() {
    MotionToast(
      primaryColor: Colors.grey,
      description: Center(
        child: AutoSizeText(
          S.of(context).toast_maximum_split_screen,
          maxLines: 1,
        ),
      ),
      displaySideBar: false,
      position: MotionToastPosition.center,
    ).show(context);
  }

  _showAuthDialog(BuildContext context) {
    if (navService.canPop() &&
        HybridConnectionList.hybridSplitScreenCount.value == 0) {
      navService.goBack();
    }
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        dialogContextList.add(dialogContext);
        return PopScope(
          // Using onWillPop to block back key return,
          // it will break "Show Prompt mechanism"
          canPop: false,
          child: Dialog(
            backgroundColor: context.tokens.color.vsdslColorOpacityNeutralXl,
            alignment: Alignment.bottomCenter,
            insetPadding: const EdgeInsets.only(bottom: 27),
            child: Consumer<MirrorStateProvider>(
              builder: (_, mirrorStateProvider, __) {
                var mirrorRequestIdles = HybridConnectionList()
                    .getMirrorMap()
                    .values
                    .where(
                        (request) => request.mirrorState == MirrorState.idle);

                // Calculate Dialog height.
                var totalHeight = 0.0;
                // container padding height
                var containerPaddingHeight =
                    context.tokens.spacing.vsdslSpacing4xl.vertical;
                // pin code height
                var pinCodeHeight = 0.0;
                if (mirrorStateProvider.pinCode.isNotEmpty) {
                  pinCodeHeight += 70;
                }
                // Divider height
                var requestDividerHeight = 2.0;
                // mirror request height and spacing height
                var requestTotalHeight = 0.0;
                var requestContainerHeight = 27.0;
                var requestPaddingHeight =
                    context.tokens.spacing.vsdslSpacingLg.vertical;
                if (mirrorRequestIdles.isNotEmpty) {
                  if (mirrorStateProvider.pinCode.isNotEmpty) {
                    requestTotalHeight +=
                        (requestPaddingHeight + requestDividerHeight);
                  }
                  requestTotalHeight +=
                      (requestPaddingHeight + requestDividerHeight) *
                          (mirrorRequestIdles.length - 1);
                  requestTotalHeight +=
                      mirrorRequestIdles.length * requestContainerHeight;
                }
                totalHeight =
                    containerPaddingHeight + pinCodeHeight + requestTotalHeight;

                if (mirrorStateProvider.pinCode.isNotEmpty) {
                  // PIN 碼模式 UI
                  return Container(
                    width: 548,
                    height: totalHeight,
                    padding: EdgeInsets.symmetric(
                      vertical: containerPaddingHeight / 2,
                      horizontal: context.tokens.spacing.vsdslSpacing3xl.left,
                    ),
                    child: Column(
                      children: [
                        if (mirrorStateProvider.pinCode.isNotEmpty) ...[
                          SizedBox(
                            height: pinCodeHeight,
                            child: Column(
                              children: [
                                AutoSizeText(
                                  S.of(context).v3_mirror_request_passcode,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                AutoSizeText(
                                  mirrorStateProvider.pinCode,
                                  style: const TextStyle(
                                    fontSize: 41,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 19.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (mirrorRequestIdles.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: requestPaddingHeight / 2,
                              ),
                              child: Container(
                                color: context
                                    .tokens.color.vsdslColorOnSurfaceVariant,
                                height: requestDividerHeight,
                              ),
                            ),
                        ],
                      ],
                    ),
                  );
                } else if (mirrorRequestIdles.isNotEmpty) {
                  // 鏡像確認模式 UI
                  if (mirrorStateProvider.isMirrorConfirmation) {
                    final primaryFocusNode = FocusNode();
                    final bool openedWithLogicalKey =
                        HardwareKeyboard.instance.logicalKeysPressed.isNotEmpty;
                    if (openedWithLogicalKey) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        primaryFocusNode.requestFocus();
                      });
                    }
                    return Container(
                      width: 548,
                      height: totalHeight,
                      padding: EdgeInsets.symmetric(
                        vertical: containerPaddingHeight / 2,
                        horizontal: context.tokens.spacing.vsdslSpacing3xl.left,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              reverse: HybridConnectionList().isMirroring(),
                              itemCount: mirrorRequestIdles.length,
                              itemBuilder:
                                  (BuildContext buildContext, int index) {
                                return SizedBox(
                                  width: 508,
                                  height: requestContainerHeight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Image(
                                        image: Svg(
                                            'assets/images/ic_prompt_in_mirror.svg'),
                                      ),
                                      SizedBox(
                                          width: context.tokens.spacing
                                              .vsdslSpacingSm.left),
                                      AutoSizeText(
                                        sprintf(
                                            S.current.main_mirror_from_client, [
                                          mirrorRequestIdles
                                              .toList()[index]
                                              .mirrorId
                                        ]),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: context.tokens.color
                                              .vsdslColorOnSurfaceInverse,
                                        ),
                                      ),
                                      const Spacer(),
                                      V3Focus(
                                        child: SizedBox(
                                          width: 80,
                                          height: requestContainerHeight,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: context
                                                  .tokens
                                                  .color
                                                  .vsdslColorOnSurfaceInverse,
                                              backgroundColor: context
                                                  .tokens
                                                  .color
                                                  .vsdslColorOpacityNeutralSm,
                                              side: BorderSide(
                                                color: context.tokens.color
                                                    .vsdslColorOnSurfaceInverse,
                                                width: 1.5,
                                              ),
                                              textStyle: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                            onPressed: () {
                                              final String mirrorType =
                                                  mirrorRequestIdles
                                                      .toList()[index]
                                                      .mirrorType
                                                      .name
                                                      .replaceAll('googlecast',
                                                          'google_cast');
                                              trackEvent('click_decline_device',
                                                  EventCategory.session,
                                                  mode: mirrorType);
                                              var mirrorId = mirrorRequestIdles
                                                  .toList()[index]
                                                  .mirrorId;
                                              mirrorStateProvider
                                                  .clearRequestMirrorId(
                                                      mirrorId);
                                            },
                                            child: AutoSizeText(S
                                                .of(context)
                                                .v3_authorize_prompt_decline),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: context.tokens.spacing
                                              .vsdslSpacingSm.left),
                                      V3Focus(
                                        child: SizedBox(
                                          width: 80,
                                          height: 27,
                                          child: ElevatedButton(
                                            focusNode: primaryFocusNode,
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: context.tokens
                                                  .color.vsdslColorNeutral,
                                              backgroundColor: context
                                                  .tokens
                                                  .color
                                                  .vsdslColorOnSurfaceInverse,
                                              textStyle: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                            onPressed: () async {
                                              final String mirrorType =
                                                  mirrorRequestIdles
                                                      .toList()[index]
                                                      .mirrorType
                                                      .name
                                                      .replaceAll('googlecast',
                                                          'google_cast');
                                              trackEvent('click_accept_device',
                                                  EventCategory.session,
                                                  mode: mirrorType);
                                              String? mirrorId =
                                                  mirrorRequestIdles
                                                      .toList()[index]
                                                      .mirrorId;
                                              mirrorStateProvider
                                                  .setAcceptMirrorId(mirrorId);
                                            },
                                            child: AutoSizeText(S
                                                .of(context)
                                                .v3_authorize_prompt_accept),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext buildContext, int index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: requestPaddingHeight / 2,
                                  ),
                                  child: Container(
                                    color: context.tokens.color
                                        .vsdslColorOnSurfaceVariant,
                                    height: requestDividerHeight,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    Future.delayed(Duration.zero, () {
                      for (MirrorRequest request
                          in HybridConnectionList().getMirrorMap().values) {
                        if (request.mirrorState == MirrorState.idle) {
                          mirrorStateProvider
                              .setAcceptMirrorId(request.mirrorId);
                        }
                      }
                    });
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }
}
