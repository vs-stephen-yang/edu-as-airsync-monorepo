import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelProvider>(builder: (_, channelProvider, __) {
      var authRequestIdles = channelProvider.authorizeRequestList;

      if (authRequestIdles.isNotEmpty && dialogContextList.isEmpty) {
        Future.delayed(Duration.zero, () {
          _showAuthDialog(context);
        });
      } else if (dialogContextList.isNotEmpty && authRequestIdles.isEmpty) {
        if (dialogContextList.isNotEmpty) {
          for (var context in dialogContextList) {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          }
        }
        dialogContextList.clear();
      }
      return const SizedBox.shrink();
    });
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
            child: Consumer<ChannelProvider>(
              builder: (_, channelProvider, __) {
                var authRequestIdles = channelProvider.authorizeRequestList;

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
                if (authRequestIdles.isNotEmpty) {
                  requestTotalHeight +=
                      (requestPaddingHeight + requestDividerHeight) *
                          authRequestIdles.length;
                  requestTotalHeight +=
                      authRequestIdles.length * requestContainerHeight;
                }
                totalHeight = containerPaddingHeight +
                    titleBarHeight +
                    requestTotalHeight;
                return Container(
                  width: 548,
                  height: totalHeight,
                  padding: EdgeInsets.symmetric(
                    vertical: containerPaddingHeight / 2,
                    horizontal: context.tokens.spacing.vsdslSpacing3xl.left,
                  ),
                  child: Column(
                    children: [
                      Image(
                        height: titleBarHeight,
                        image:
                            const Svg('assets/images/ic_prompt_in_mirror.svg'),
                      ),
                      if (authRequestIdles.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: requestPaddingHeight / 2,
                          ),
                          child: Container(
                            color:
                                context.tokens.color.vsdslColorOnSurfaceVariant,
                            height: requestDividerHeight,
                          ),
                        ),
                      Expanded(
                        child: ListView.separated(
                          reverse: HybridConnectionList().isMirroring(),
                          itemCount: authRequestIdles.length,
                          itemBuilder: (BuildContext buildContext, int index) {
                            return SizedBox(
                              width: 508,
                              height: requestContainerHeight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Image(
                                    image: Svg(
                                        'assets/images/ic_prompt_in_webrtc.svg'),
                                  ),
                                  SizedBox(
                                      width: context
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
                                  SizedBox(
                                      width: context
                                          .tokens.spacing.vsdslSpacingSm.left),
                                  V3Focus(
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
                      ),
                    ],
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
