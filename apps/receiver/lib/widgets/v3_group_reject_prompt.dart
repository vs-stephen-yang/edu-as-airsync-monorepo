import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/group_provider.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class V3GroupRejectPrompt extends ConsumerWidget {
  const V3GroupRejectPrompt({super.key});

  // Initialize dialogContextList and timers as class members
  static final List<BuildContext> dialogContextList = [];
  static bool _isDialogShowing = false;
  static final Map<String, Timer> timers = {};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rejectList =
        ref.watch(groupProvider.select((state) => state.rejectedList));

    // 檢查是否有新的拒絕項目需要啟動計時器
    for (var item in rejectList) {
      if (!timers.containsKey(item.id())) {
        _startTimer(item.id(), ref);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (rejectList.isNotEmpty && !_isDialogShowing) {
        _showRejectDialog(context, ref);
        _isDialogShowing = true;
      } else if (rejectList.isEmpty) {
        _closeRejectDialogs();
        _isDialogShowing = false;
      }
    });

    return const SizedBox.shrink();
  }

  _showRejectDialog(BuildContext context, WidgetRef ref) {
    FocusScope.of(context).unfocus();
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (BuildContext dialogContext) {
          dialogContextList.add(dialogContext);
          final primaryFocusNode = FocusNode();
          final bool openedWithLogicalKey =
              HardwareKeyboard.instance.logicalKeysPressed.isNotEmpty;
          if (openedWithLogicalKey) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              primaryFocusNode.requestFocus();
            });
          }

          return Consumer(builder: (context, ref, child) {
            final currentRejectList =
                ref.watch(groupProvider.select((state) => state.rejectedList));

            // Calculate Dialog height.
            var totalHeight = 0.0;
            // container padding height
            var containerPaddingHeight =
                context.tokens.spacing.vsdslSpacing4xl.vertical;
            // title bar height
            var titleBarHeight = 53.0;
            // Divider height
            var requestDividerHeight = 2.0;
            // mirror request height and spacing height
            var requestTotalHeight = 0.0;
            var requestContainerHeight = 27.0;
            var requestPaddingHeight =
                context.tokens.spacing.vsdslSpacingLg.vertical;
            if (currentRejectList.isNotEmpty) {
              requestTotalHeight +=
                  (requestPaddingHeight + requestDividerHeight) *
                      currentRejectList.length;
              requestTotalHeight +=
                  currentRejectList.length * requestContainerHeight;
            }
            totalHeight =
                containerPaddingHeight + titleBarHeight + requestTotalHeight;

            return PopScope(
              canPop: false,
              child: Dialog(
                backgroundColor:
                    context.tokens.color.vsdslColorOpacityNeutralXl,
                alignment: Alignment.bottomCenter,
                insetPadding: const EdgeInsets.only(bottom: 27),
                child: Stack(
                  children: [
                    Container(
                      width: 548,
                      height: totalHeight,
                      padding: EdgeInsets.symmetric(
                        vertical: containerPaddingHeight / 2,
                        horizontal: context.tokens.spacing.vsdslSpacing3xl.left,
                      ),
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            'assets/images/ic_group_reject_alert.svg',
                            excludeFromSemantics: true,
                            height: titleBarHeight,
                          ),
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
                          Expanded(
                            child: ListView.separated(
                              itemCount: currentRejectList.length,
                              itemBuilder:
                                  (BuildContext buildContext, int index) {
                                return SizedBox(
                                  width: 508,
                                  height: requestContainerHeight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/ic_group_reject_screen.svg',
                                        width: 21,
                                        height: 21,
                                      ),
                                      SizedBox(
                                          width: context.tokens.spacing
                                              .vsdslSpacingSm.left),
                                      AutoSizeText(
                                        '${currentRejectList[index].deviceName()} ${S.of(context).v3_group_reject_invited}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: context.tokens.color
                                              .vsdslColorOnSurfaceInverse,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const Spacer(),
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
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: V3Focus(
                        label: S.of(context).v3_lbl_group_reject_close,
                        identifier: 'v3_qa_group_reject_close',
                        child: IconButton(
                          focusNode: primaryFocusNode,
                          onPressed: () => closeAllRejectPrompts(ref),
                          icon: SvgPicture.asset(
                            'assets/images/ic_group_reject_close.svg',
                            excludeFromSemantics: true,
                            width: 26,
                            height: 26,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  void _startTimer(String itemId, WidgetRef ref) {
    if (timers.containsKey(itemId)) return;

    timers[itemId] = Timer(Duration(seconds: 5), () {
      _removeItemFromRejectList(itemId, ref);
    });
  }

  void _removeItemFromRejectList(String itemId, WidgetRef ref) {
    final provider = ref.read(groupProvider.notifier);
    try {
      final item =
          provider.rejectedList.firstWhere((item) => item.id() == itemId);
      provider.removeFormRejectedList(item);
    } catch (e) {
      // Item not found
    }
    timers.remove(itemId);
  }

  void _closeRejectDialogs() {
    for (var context in dialogContextList) {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
    dialogContextList.clear();
  }

  void closeAllRejectPrompts(WidgetRef ref) {
    // cancel all timers
    for (var timer in timers.values) {
      timer.cancel();
    }
    timers.clear();

    // clear rejected list
    final provider = ref.read(groupProvider.notifier);
    final rejectList = [...provider.rejectedList];
    for (var item in rejectList) {
      provider.removeFormRejectedList(item);
    }

    // close all dialogs
    _closeRejectDialogs();
  }
}
