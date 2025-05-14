import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

class V3AuthorizePrompt extends StatefulWidget {
  const V3AuthorizePrompt({super.key});

  @override
  State<StatefulWidget> createState() => _V3AuthorizePromptState();
}

class _V3AuthorizePromptState extends State<V3AuthorizePrompt> {
  List<BuildContext> dialogContextList = [];

  Timer? _autoCloseTimer;
  final int _totalSeconds = 9;
  int _remainingSeconds = 9;
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(1.0);

  // 添加变量来跟踪上一次的请求数量
  int _lastAuthRequestCount = 0;
  int _lastMirrorRequestCount = 0;

  @override
  void dispose() {
    _cancelAutoCloseTimer();
    _progressNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChannelProvider, MirrorStateProvider>(
        builder: (_, channelProvider, mirrorStateProvider, __) {
      var authRequestIdles = channelProvider.authorizeRequestList;
      var mirrorRequestIdles = HybridConnectionList()
          .getMirrorMap()
          .values
          .where((request) => request.mirrorState == MirrorState.idle);

      if ((authRequestIdles.isNotEmpty || mirrorRequestIdles.isNotEmpty) &&
          dialogContextList.isEmpty) {
        if (authRequestIdles.isNotEmpty) {
          Future.delayed(Duration.zero, () {
            if (context.mounted) {
              _showAuthDialog(context);
            }
          });
        } else {
          for (MirrorRequest request
              in HybridConnectionList().getMirrorMap().values) {
            if (request.mirrorState == MirrorState.idle) {
              if ((!ChannelProvider.isModeratorMode &&
                      HybridConnectionList.hybridSplitScreenCount.value <
                          HybridConnectionList.maxHybridSplitScreen) ||
                  (ChannelProvider.isModeratorMode &&
                      HybridConnectionList().getConnectionCount() <
                          HybridConnectionList.maxHybridConnection)) {
                // 拒絕邏輯 一般模式:目前視窗大於等於最大視窗數。 ModeratorMode:連線數大於等於最大連線數
                Future.delayed(Duration.zero, () {
                  if (context.mounted) {
                    _showAuthDialog(context);
                  }
                });
              } else {
                mirrorStateProvider.stopAcceptedMirror(request.mirrorId);
                Future.delayed(Duration.zero, () {
                  _showMaxAmountToast();
                });
                request.trackSessionEvent('device_full');
              }
            }
          }
        }
      } else if (mirrorStateProvider.pinCode.isNotEmpty &&
          dialogContextList.isEmpty) {
        Future.delayed(Duration.zero, () {
          if (context.mounted) {
            _showAuthDialog(context);
          }
        });
      } else if (dialogContextList.isNotEmpty &&
          mirrorRequestIdles.isEmpty &&
          mirrorStateProvider.pinCode.isEmpty &&
          authRequestIdles.isEmpty) {
        if (dialogContextList.isNotEmpty) {
          for (var context in dialogContextList) {
            if (context.mounted) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }
          }
        }
        dialogContextList.clear();
        _cancelAutoCloseTimer(); // 當對話框關閉時，取消計時器
      }
      return const SizedBox.shrink();
    });
  }

  void _startAutoCloseTimer() {
    _cancelAutoCloseTimer();
    _remainingSeconds = _totalSeconds; // 重置倒計時
    _progressNotifier.value = 1.0; // 重置進度條

    _autoCloseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      _progressNotifier.value = _remainingSeconds / _totalSeconds;

      if (_remainingSeconds <= 0) {
        _handleAutoClose();
        _cancelAutoCloseTimer();
      }
    });
  }

  // 取消自動關閉計時器
  void _cancelAutoCloseTimer() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;
  }

  // 處理自動關閉
  void _handleAutoClose() {
    // 自動拒絕所有未處理的請求
    final channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    final mirrorStateProvider =
        Provider.of<MirrorStateProvider>(context, listen: false);

    // 處理 WebRTC 請求
    if (channelProvider.authorizeRequestList.isNotEmpty) {
      for (var request in channelProvider.authorizeRequestList) {
        request.entries.first.value.sendRejectPresent(
            PresentRejectedReasonCode.timeout.code,
            'auto reject due to timeout');
      }
      channelProvider.authorizeRequestList.clear();
    }

    // 處理鏡像請求
    for (MirrorRequest request
        in HybridConnectionList().getMirrorMap().values) {
      if (request.mirrorState == MirrorState.idle) {
        mirrorStateProvider.clearRequestMirrorId(request.mirrorId);
      }
    }

    // 關閉對話框
    if (dialogContextList.isNotEmpty) {
      for (var context in dialogContextList) {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
      dialogContextList.clear();
    }
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

    // 啟動自動關閉計時器
    _startAutoCloseTimer();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        var dialogWidth = 628.0;
        dialogContextList.add(dialogContext);
        return PopScope(
          // Using canPop=false to block back key return,
          // it will break "Show Prompt mechanism"
          canPop: false,
          child: Dialog(
            backgroundColor: context.tokens.color.vsdslColorOpacityNeutralXl,
            alignment: Alignment.bottomCenter,
            insetPadding: const EdgeInsets.only(bottom: 27),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Consumer2<MirrorStateProvider, ChannelProvider>(
                  builder: (_, mirrorStateProvider, channelProvider, __) {
                    final List<Widget> widgetList = [];
                    var authRequestIdles = channelProvider.authorizeRequestList;
                    var mirrorRequestIdles = HybridConnectionList()
                        .getMirrorMap()
                        .values
                        .where((request) =>
                            request.mirrorState == MirrorState.idle);

                    int currentAuthCount = authRequestIdles.length;
                    int currentMirrorCount = mirrorRequestIdles.length;

                    if ((currentAuthCount > _lastAuthRequestCount ||
                            currentMirrorCount > _lastMirrorRequestCount) &&
                        _autoCloseTimer != null) {
                      _startAutoCloseTimer();
                    }

                    _lastAuthRequestCount = currentAuthCount;
                    _lastMirrorRequestCount = currentMirrorCount;

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
                    totalHeight = containerPaddingHeight +
                        pinCodeHeight +
                        requestTotalHeight;
                    widgetList.addAll([
                      SvgPicture.asset(
                        'assets/images/ic_prompt_arrow.svg',
                        excludeFromSemantics: true,
                        height: 53,
                      ),
                      SizedBox(
                        width: dialogWidth,
                        height: requestDividerHeight,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal:
                                  context.tokens.spacing.vsdslSpacing3xl.left),
                          color:
                              context.tokens.color.vsdslColorOnSurfaceVariant,
                        ),
                      ),
                    ]);
                    if (mirrorStateProvider.pinCode.isNotEmpty) {
                      // PIN 碼模式 UI
                      widgetList.add(Container(
                        width: dialogWidth,
                        height: totalHeight,
                        padding: EdgeInsets.symmetric(
                          vertical: containerPaddingHeight / 2,
                          horizontal:
                              context.tokens.spacing.vsdslSpacing3xl.left,
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
                                    color: context.tokens.color
                                        .vsdslColorOnSurfaceVariant,
                                    height: requestDividerHeight,
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ));
                    } else if (mirrorRequestIdles.isNotEmpty) {
                      // 鏡像確認模式 UI
                      if (mirrorStateProvider.isMirrorConfirmation) {
                        if (!ChannelProvider.isModeratorMode &&
                                HybridConnectionList
                                        .hybridSplitScreenCount.value >=
                                    HybridConnectionList.maxHybridSplitScreen ||
                            (ChannelProvider.isModeratorMode &&
                                HybridConnectionList().getConnectionCount() >=
                                    HybridConnectionList.maxHybridConnection)) {
                          // 拒絕邏輯 一般模式:目前視窗大於等於最大視窗數。 ModeratorMode:連線數大於等於最大連線數
                          for (var idle in mirrorRequestIdles) {
                            mirrorStateProvider
                                .stopAcceptedMirror(idle.mirrorId);
                            idle.trackSessionEvent('device_full');
                          }
                          Future.delayed(Duration.zero, () {
                            _showMaxAmountToast();
                          });
                        } else {
                          widgetList.add(Container(
                            width: dialogWidth,
                            height: totalHeight,
                            padding: EdgeInsets.only(
                                left:
                                    context.tokens.spacing.vsdslSpacing3xl.left,
                                right:
                                    context.tokens.spacing.vsdslSpacing3xl.left,
                                top: containerPaddingHeight / 2,
                                bottom: authRequestIdles.isEmpty
                                    ? containerPaddingHeight / 2
                                    : 0),
                            child: ListView.separated(
                              reverse: HybridConnectionList().isMirroring(),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
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
                                      SvgPicture.asset(
                                        'assets/images/ic_prompt_in_mirror.svg',
                                        excludeFromSemantics: true,
                                      ),
                                      Gap(context
                                          .tokens.spacing.vsdslSpacingSm.left),
                                      AutoSizeText(
                                        sprintf(
                                            S.current.main_mirror_from_client, [
                                          mirrorRequestIdles
                                              .toList()[index]
                                              .deviceName
                                        ]),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: context.tokens.color
                                              .vsdslColorOnSurfaceInverse,
                                        ),
                                      ),
                                      const Spacer(),
                                      V3Focus(
                                        label: S
                                            .of(context)
                                            .v3_lbl_authorize_prompt_decline,
                                        identifier:
                                            'v3_qa_authorize_prompt_decline',
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
                                              // 重置計時器
                                              _startAutoCloseTimer();

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
                                      Gap(context
                                          .tokens.spacing.vsdslSpacingSm.left),
                                      V3Focus(
                                        label: S
                                            .of(context)
                                            .v3_lbl_authorize_prompt_accept,
                                        identifier:
                                            'v3_qa_authorize_prompt_accept',
                                        child: SizedBox(
                                          width: 80,
                                          height: 27,
                                          child: ElevatedButton(
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
                                              // 重置計時器
                                              _startAutoCloseTimer();

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
                                              if (ChannelProvider
                                                  .isModeratorMode) {
                                                mirrorStateProvider
                                                    .setModeratorIdleMirrorId(
                                                        mirrorId);
                                              } else {
                                                mirrorStateProvider
                                                    .setAcceptMirrorId(
                                                        mirrorId);
                                              }
                                            },
                                            child: AutoSizeText(S
                                                .of(context)
                                                .v3_authorize_prompt_accept),
                                          ),
                                        ),
                                      ),
                                      Gap(context
                                          .tokens.spacing.vsdslSpacingSm.left),
                                      V3Focus(
                                        label: S
                                            .of(context)
                                            .v3_lbl_authorize_prompt_accept_all,
                                        identifier:
                                            'v3_qa_authorize_prompt_accept_all',
                                        child: SizedBox(
                                          width: 80,
                                          height: 27,
                                          child: ElevatedButton(
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
                                              // 重置計時器
                                              _startAutoCloseTimer();

                                              final String mirrorType =
                                                  mirrorRequestIdles
                                                      .toList()[index]
                                                      .mirrorType
                                                      .name
                                                      .replaceAll('googlecast',
                                                          'google_cast');
                                              trackEvent(
                                                  'click_accept_all_device',
                                                  EventCategory.session,
                                                  mode: mirrorType);

                                              for (int i = mirrorRequestIdles
                                                      .toList()
                                                      .length;
                                                  i > 0;
                                                  i--) {
                                                String? mirrorId =
                                                    mirrorRequestIdles
                                                        .toList()[i - 1]
                                                        .mirrorId;
                                                if (ChannelProvider
                                                    .isModeratorMode) {
                                                  mirrorStateProvider
                                                      .setModeratorIdleMirrorId(
                                                          mirrorId);
                                                } else {
                                                  mirrorStateProvider
                                                      .setAcceptMirrorId(
                                                          mirrorId);
                                                }
                                              }

                                              mirrorStateProvider
                                                  .isMirrorConfirmation = false;
                                            },
                                            child: AutoSizeText(S
                                                .of(context)
                                                .v3_authorize_prompt_accept_all),
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
                          ));
                        }
                      } else {
                        Future.delayed(Duration.zero, () {
                          for (MirrorRequest request
                              in HybridConnectionList().getMirrorMap().values) {
                            if (request.mirrorState == MirrorState.idle) {
                              if (ChannelProvider.isModeratorMode) {
                                mirrorStateProvider
                                    .setModeratorIdleMirrorId(request.mirrorId);
                              } else {
                                mirrorStateProvider
                                    .setAcceptMirrorId(request.mirrorId);
                              }
                            }
                          }
                        });
                      }
                    }

                    if (authRequestIdles.isNotEmpty) {
                      var totalHeight = 0.0;
                      var requestTotalHeight = 0.0;
                      if (mirrorRequestIdles.isNotEmpty) {
                        widgetList.add(
                          SizedBox(
                            width: dialogWidth,
                            height: requestDividerHeight,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: context
                                      .tokens.spacing.vsdslSpacing3xl.left),
                              color: context
                                  .tokens.color.vsdslColorOnSurfaceVariant,
                            ),
                          ),
                        );
                        widgetList.add(
                          Gap(requestPaddingHeight / 2),
                        );
                      }
                      if (authRequestIdles.isNotEmpty) {
                        requestTotalHeight +=
                            (requestPaddingHeight + requestDividerHeight) *
                                authRequestIdles.length;
                        requestTotalHeight +=
                            authRequestIdles.length * requestContainerHeight;
                      }
                      totalHeight = containerPaddingHeight + requestTotalHeight;
                      widgetList.add(Container(
                        width: dialogWidth,
                        height: totalHeight,
                        padding: EdgeInsets.only(
                            left: context.tokens.spacing.vsdslSpacing3xl.left,
                            right: context.tokens.spacing.vsdslSpacing3xl.left,
                            bottom: containerPaddingHeight / 2,
                            top: mirrorRequestIdles.isEmpty
                                ? containerPaddingHeight / 2
                                : 0),
                        child: ListView.separated(
                          reverse: HybridConnectionList().isMirroring(),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: authRequestIdles.length,
                          itemBuilder: (BuildContext buildContext, int index) {
                            return SizedBox(
                              width: 508,
                              height: requestContainerHeight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/ic_prompt_in_webrtc.svg',
                                    excludeFromSemantics: true,
                                  ),
                                  Gap(context
                                      .tokens.spacing.vsdslSpacingSm.left),
                                  AutoSizeText(
                                    sprintf(S.current.main_mirror_from_client, [
                                      authRequestIdles[index].entries.first.key
                                    ]),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.tokens.color
                                          .vsdslColorOnSurfaceInverse,
                                    ),
                                  ),
                                  const Spacer(),
                                  V3Focus(
                                    label: S
                                        .of(context)
                                        .v3_lbl_authorize_prompt_decline,
                                    identifier:
                                        'v3_qa_authorize_prompt_decline',
                                    child: SizedBox(
                                      width: 80,
                                      height: requestContainerHeight,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: context.tokens.color
                                              .vsdslColorOnSurfaceInverse,
                                          backgroundColor: context.tokens.color
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
                                          // 重置計時器
                                          _startAutoCloseTimer();

                                          if (authRequestIdles.isNotEmpty) {
                                            trackEvent('click_decline_device',
                                                EventCategory.session,
                                                mode: 'webrtc');

                                            authRequestIdles[index]
                                                .entries
                                                .first
                                                .value
                                                .sendRejectPresent(
                                                    PresentRejectedReasonCode
                                                        .authorizeDecline.code,
                                                    'authorize decline');
                                            channelProvider.authorizeRequestList
                                                .removeAt(index);
                                          }
                                        },
                                        child: AutoSizeText(S
                                            .of(context)
                                            .v3_authorize_prompt_decline),
                                      ),
                                    ),
                                  ),
                                  Gap(context
                                      .tokens.spacing.vsdslSpacingSm.left),
                                  V3Focus(
                                    label: S
                                        .of(context)
                                        .v3_lbl_authorize_prompt_accept,
                                    identifier: 'v3_qa_authorize_prompt_accept',
                                    child: SizedBox(
                                      width: 80,
                                      height: 27,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: context
                                              .tokens.color.vsdslColorNeutral,
                                          backgroundColor: context.tokens.color
                                              .vsdslColorOnSurfaceInverse,
                                          textStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                        onPressed: () {
                                          // 重置計時器
                                          _startAutoCloseTimer();

                                          if (authRequestIdles.isNotEmpty) {
                                            trackEvent('click_accept_device',
                                                EventCategory.session,
                                                mode: 'webrtc');

                                            authRequestIdles[index]
                                                .entries
                                                .first
                                                .value
                                                .sendAllowPresent();
                                            channelProvider.authorizeRequestList
                                                .removeAt(index);
                                          }
                                        },
                                        child: AutoSizeText(S
                                            .of(context)
                                            .v3_authorize_prompt_accept),
                                      ),
                                    ),
                                  ),
                                  Gap(context
                                      .tokens.spacing.vsdslSpacingSm.left),
                                  V3Focus(
                                    label: S
                                        .of(context)
                                        .v3_lbl_authorize_prompt_accept_all,
                                    identifier:
                                        'v3_qa_authorize_prompt_accept_all',
                                    child: SizedBox(
                                      width: 80,
                                      height: 27,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: context
                                              .tokens.color.vsdslColorNeutral,
                                          backgroundColor: context.tokens.color
                                              .vsdslColorOnSurfaceInverse,
                                          textStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                        onPressed: () {
                                          // 重置計時器
                                          _startAutoCloseTimer();

                                          if (authRequestIdles.isNotEmpty) {
                                            trackEvent(
                                                'click_accept_all_device',
                                                EventCategory.session,
                                                mode: 'webrtc');

                                            for (int i =
                                                    authRequestIdles.length;
                                                i > 0;
                                                i--) {
                                              authRequestIdles[i - 1]
                                                  .entries
                                                  .first
                                                  .value
                                                  .sendAllowPresent();
                                              channelProvider
                                                  .authorizeRequestList
                                                  .removeAt(i - 1);
                                            }
                                          }
                                          channelProvider.isAuthorizeMode =
                                              false;
                                        },
                                        child: AutoSizeText(S
                                            .of(context)
                                            .v3_authorize_prompt_accept_all),
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
                                color: context
                                    .tokens.color.vsdslColorOnSurfaceVariant,
                                height: requestDividerHeight,
                              ),
                            );
                          },
                        ),
                      ));
                    }

                    return ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 400,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: widgetList,
                        ),
                      ),
                    );
                  },
                ),
                ValueListenableBuilder<double>(
                  valueListenable: _progressNotifier,
                  builder: (context, progress, _) {
                    return ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(28)),
                      child: SizedBox(
                        width: dialogWidth,
                        height: 56,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: ValueListenableBuilder<double>(
                                valueListenable: _progressNotifier,
                                builder: (context, progress, _) {
                                  return LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.transparent,
                                    color: context
                                        .tokens.color.vsdslColorSurface100,
                                    minHeight: 5,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
