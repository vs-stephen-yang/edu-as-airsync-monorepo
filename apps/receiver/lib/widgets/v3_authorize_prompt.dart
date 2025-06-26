import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/utility/user_timer_manager.dart';
import 'package:display_flutter/widgets/authorize_prompt_components.dart';
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

  final UserTimerManager _timerManager = UserTimerManager();
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(1.0);
  final ValueNotifier<int> _remainingSecondsNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    // 設置計時器管理器的回調
    _timerManager.onProgressUpdate = (progress, remainingSeconds) {
      _progressNotifier.value = progress;
      _remainingSecondsNotifier.value = remainingSeconds;
    };

    _timerManager.onUserTimeout = (userId) {
      _handleUserTimeout(userId);
    };
  }

  @override
  void dispose() {
    _timerManager.clearAll();
    _progressNotifier.dispose();
    _remainingSecondsNotifier.dispose();
    super.dispose();
  }

  // 移除舊的計時器方法，替換為新的重置方法
  void _resetTimerForUser(String userId) {
    // 當用戶進行操作時，重置該用戶的計時器
    _timerManager.resetUser(userId);
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

      // 使用 WidgetsBinding.instance.addPostFrameCallback 來延遲更新
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateTimerUsers(
            authRequestIdles, mirrorRequestIdles, mirrorStateProvider.pinCode);
      });

      if ((authRequestIdles.isNotEmpty ||
              mirrorRequestIdles.isNotEmpty ||
              mirrorStateProvider.pinCode.isNotEmpty) &&
          dialogContextList.isEmpty) {
        Future.delayed(Duration.zero, () {
          if (context.mounted) {
            print('------mounted--showing auth dialog');
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
        // 延遲清空計時器，避免在 build 中執行
        Future.delayed(Duration.zero, () {
          _timerManager.clearAll();
        });
      }
      return const SizedBox.shrink();
    });
  }

  // 新增方法：更新計時器管理器中的用戶
  void _updateTimerUsers(
    List<Map<String, dynamic>> authRequestIdles,
    Iterable<MirrorRequest> mirrorRequestIdles,
    String pinCode,
  ) {
    Set<String> currentUserIds = {};

    // 添加 WebRTC 用戶
    for (var request in authRequestIdles) {
      final deviceName = request.entries.first.key;
      final userId = 'webrtc_$deviceName';
      currentUserIds.add(userId);

      _timerManager.addUser(
        id: userId,
        deviceName: deviceName,
        connectionType: UserTimerManager.getWebRTCConnectionType(),
      );
    }

    // 添加 Mirror 用戶
    for (var request in mirrorRequestIdles) {
      final userId = 'mirror_${request.mirrorId}';
      currentUserIds.add(userId);

      final connectionType = UserTimerManager.getConnectionTypeFromString(
        request.mirrorType.toString().split('.').last,
        hasPin: pinCode.isNotEmpty &&
            request.mirrorType.toString().contains('airplay'),
      );

      _timerManager.addUser(
        id: userId,
        deviceName: request.deviceName,
        connectionType: connectionType,
      );
    }

    // 添加 PIN 碼用戶（如果存在）
    if (pinCode.isNotEmpty) {
      const userId = 'pin_code';
      currentUserIds.add(userId);

      _timerManager.addUser(
        id: userId,
        deviceName: 'PIN Code',
        connectionType: ConnectionType.airplayWithPin,
      );
    }

    // 移除不再存在的用戶
    final existingUserIds = _timerManager.allTimers.keys.toSet();
    for (final userId in existingUserIds) {
      if (!currentUserIds.contains(userId)) {
        _timerManager.removeUser(userId);
      }
    }
  }

  // 新增方法：處理用戶超時
  void _handleUserTimeout(String userId) {
    final channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    final mirrorStateProvider =
        Provider.of<MirrorStateProvider>(context, listen: false);

    if (userId.startsWith('webrtc_')) {
      // 處理 WebRTC 超時
      final deviceName = userId.substring(7); // 移除 'webrtc_' 前綴
      final requestIndex = channelProvider.authorizeRequestList.indexWhere(
        (request) => request.entries.first.key == deviceName,
      );

      if (requestIndex != -1) {
        channelProvider.authorizeRequestList[requestIndex].entries.first.value
            .sendRejectPresent(PresentRejectedReasonCode.timeout.code,
                'auto reject due to timeout');
        channelProvider.authorizeRequestList.removeAt(requestIndex);
      }
    } else if (userId.startsWith('mirror_')) {
      // 處理 Mirror 超時
      final mirrorId = userId.substring(7); // 移除 'mirror_' 前綴
      mirrorStateProvider.clearRequestMirrorId(mirrorId);
    } else if (userId == 'pin_code') {
      // 處理 PIN 碼超時
      mirrorStateProvider.clearPinCode();
    }

    // 如果沒有更多用戶，關閉對話框
    if (!_timerManager.hasUsers && dialogContextList.isNotEmpty) {
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

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        var dialogWidth =
            MediaQuery.of(context).textScaler.scale(1.0) > 1.0 ? 628.0 : 700.0;
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

                    // Calculate Dialog height.
                    var totalHeight = 0.0;
                    // container padding height
                    var containerPaddingHeight =
                        context.tokens.spacing.vsdslSpacing4xl.vertical;
                    // pin code height
                    var pinCodeHeight = 0.0;
                    if (mirrorStateProvider.pinCode.isNotEmpty) {
                      var textScale =
                          MediaQuery.of(context).textScaler.scale(1.0);
                      pinCodeHeight += 70 * textScale; // 按比例縮放基本高度
                    }
                    // Divider height
                    var requestDividerHeight = 2.0;
                    // mirror request height and spacing height
                    var requestTotalHeight = 0.0;
                    var textScale =
                        MediaQuery.of(context).textScaler.scale(1.0);
                    var requestContainerHeight = 30.0 * textScale; // 按比例縮放容器高度
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
                                final request =
                                    mirrorRequestIdles.toList()[index];
                                final deviceDisplayName = sprintf(
                                    S.of(context).main_mirror_from_client,
                                    [request.deviceName]);

                                return RequestRow(
                                  data: RequestRowData(
                                    deviceName: deviceDisplayName,
                                    iconAsset:
                                        'assets/images/ic_prompt_in_mirror.svg',
                                    declineText: S
                                        .of(context)
                                        .v3_authorize_prompt_decline,
                                    acceptText: S
                                        .of(context)
                                        .v3_authorize_prompt_accept,
                                    acceptAllText: S
                                        .of(context)
                                        .v3_authorize_prompt_accept_all,
                                    onDecline: () {
                                      _resetTimerForUser(
                                          'mirror_${request.mirrorId}');

                                      final String mirrorType =
                                          request.mirrorType.name.replaceAll(
                                              'googlecast', 'google_cast');
                                      trackEvent('click_decline_device',
                                          EventCategory.session,
                                          mode: mirrorType);
                                      mirrorStateProvider.clearRequestMirrorId(
                                          request.mirrorId);
                                    },
                                    onAccept: () async {
                                      _resetTimerForUser(
                                          'mirror_${request.mirrorId}');

                                      final String mirrorType =
                                          request.mirrorType.name.replaceAll(
                                              'googlecast', 'google_cast');
                                      trackEvent('click_accept_device',
                                          EventCategory.session,
                                          mode: mirrorType);

                                      if (ChannelProvider.isModeratorMode) {
                                        mirrorStateProvider
                                            .setModeratorIdleMirrorId(
                                                request.mirrorId);
                                      } else {
                                        mirrorStateProvider.setAcceptMirrorId(
                                            request.mirrorId);
                                      }
                                    },
                                    onAcceptAll: () async {
                                      // 重置所有 mirror 計時器
                                      for (var req in mirrorRequestIdles) {
                                        _resetTimerForUser(
                                            'mirror_${req.mirrorId}');
                                      }

                                      final String mirrorType =
                                          request.mirrorType.name.replaceAll(
                                              'googlecast', 'google_cast');
                                      trackEvent('click_accept_all_device',
                                          EventCategory.session,
                                          mode: mirrorType);

                                      for (int i = mirrorRequestIdles
                                              .toList()
                                              .length;
                                          i > 0;
                                          i--) {
                                        String? mirrorId = mirrorRequestIdles
                                            .toList()[i - 1]
                                            .mirrorId;
                                        if (ChannelProvider.isModeratorMode) {
                                          mirrorStateProvider
                                              .setModeratorIdleMirrorId(
                                                  mirrorId);
                                        } else {
                                          mirrorStateProvider
                                              .setAcceptMirrorId(mirrorId);
                                        }
                                      }

                                      mirrorStateProvider.isMirrorConfirmation =
                                          false;
                                    },
                                  ),
                                  containerHeight: requestContainerHeight,
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
                            final request = authRequestIdles[index];
                            final deviceName = request.entries.first.key;
                            final deviceDisplayName = sprintf(
                                S.of(context).main_mirror_from_client,
                                [deviceName]);

                            return RequestRow(
                              data: RequestRowData(
                                deviceName: deviceDisplayName,
                                iconAsset:
                                    'assets/images/ic_prompt_in_webrtc.svg',
                                declineText:
                                    S.of(context).v3_authorize_prompt_decline,
                                acceptText:
                                    S.of(context).v3_authorize_prompt_accept,
                                acceptAllText: S
                                    .of(context)
                                    .v3_authorize_prompt_accept_all,
                                onDecline: () {
                                  _resetTimerForUser('webrtc_$deviceName');

                                  trackEvent('click_decline_device',
                                      EventCategory.session,
                                      mode: 'webrtc');

                                  request.entries.first.value.sendRejectPresent(
                                      PresentRejectedReasonCode
                                          .authorizeDecline.code,
                                      'authorize decline');
                                  channelProvider.authorizeRequestList
                                      .removeAt(index);
                                },
                                onAccept: () {
                                  _resetTimerForUser('webrtc_$deviceName');

                                  trackEvent('click_accept_device',
                                      EventCategory.session,
                                      mode: 'webrtc');

                                  request.entries.first.value
                                      .sendAllowPresent();
                                  channelProvider.authorizeRequestList
                                      .removeAt(index);
                                },
                                onAcceptAll: () {
                                  // 重置所有 WebRTC 計時器
                                  for (var req in authRequestIdles) {
                                    final reqDeviceName = req.entries.first.key;
                                    _resetTimerForUser('webrtc_$reqDeviceName');
                                  }

                                  trackEvent('click_accept_all_device',
                                      EventCategory.session,
                                      mode: 'webrtc');

                                  for (int i = authRequestIdles.length;
                                      i > 0;
                                      i--) {
                                    authRequestIdles[i - 1]
                                        .entries
                                        .first
                                        .value
                                        .sendAllowPresent();
                                    channelProvider.authorizeRequestList
                                        .removeAt(i - 1);
                                  }
                                  channelProvider.isAuthorizeMode = false;
                                },
                              ),
                              containerHeight: requestContainerHeight,
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
