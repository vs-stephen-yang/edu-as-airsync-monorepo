import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/widgets/focus_aware_builder.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_custom_dialog.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_participant_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

class V3ParticipantsView extends StatefulWidget {
  const V3ParticipantsView({super.key, this.isLandscape = true});

  final bool isLandscape;

  @override
  State<StatefulWidget> createState() => _V3ParticipantsView();
}

class _V3ParticipantsView extends State<V3ParticipantsView> {
  final GlobalKey _containerKey = GlobalKey();
  bool isShowDialogMenu = false;
  final ScrollController _scrollController =
      ScrollController(); // 添加 ScrollController

  @override
  void dispose() {
    _scrollController.dispose(); // 釋放資源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _containerKey,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight:
              widget.isLandscape ? const Radius.circular(30) : Radius.zero,
          bottomRight: const Radius.circular(30),
          bottomLeft:
              !widget.isLandscape ? const Radius.circular(30) : Radius.zero,
        ),
        color: isShowDialogMenu
            ? context.tokens.color.vsdslColorSurface1000.withValues(alpha: 0.16)
            : Colors.transparent,
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: 13,
                top: 27,
                right: 13,
                bottom: 13,
              ),
              child: Container(
                padding: widget.isLandscape
                    ? EdgeInsets.zero
                    : const EdgeInsets.only(left: 20, right: 20),
                child: const V3ParticipantList(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                bottom: widget.isLandscape ? 20 : 40, left: 15, right: 15),
            child: V3Focus(
              label: S.of(context).v3_lbl_moderator_toggle,
              identifier: 'v3_qa_moderator_toggle',
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 53, // 保持最小高度
                ),
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(9999)),
                    side: BorderSide(
                      width: 1,
                      color: context.tokens.color.vsdslColorOutline,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: V3AutoHyphenatingText(
                        S.of(context).v3_moderator_mode,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.tokens.color.vsdslColorOnSurface,
                        ),
                      ),
                    ),
                    Consumer<ChannelProvider>(
                        builder: (_, channelProvider, __) {
                      return SizedBox(
                        width: 37,
                        height: 21,
                        child: IconButton(
                          icon: SvgPicture.asset(
                            ChannelProvider.isModeratorMode
                                ? 'assets/images/ic_switch_on.svg'
                                : 'assets/images/ic_switch_off.svg',
                            excludeFromSemantics: true,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            if (ChannelProvider.isModeratorMode) {
                              _callLogOutDialog(context);
                            } else {
                              trackEvent(
                                'click_moderator',
                                EventCategory.menu,
                                target: 'on',
                              );

                              channelProvider.setModeratorMode(true);
                            }
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _callLogOutDialog(BuildContext context) async {
    final RenderBox renderBox =
        _containerKey.currentContext!.findRenderObject() as RenderBox;
    final Size renderBoxSize = Size(
        renderBox.size.width - renderBox.size.width * 0.8,
        renderBox.size.height - V3CustomDialog.height);
    final Offset containerOffset = renderBox
        .localToGlobal(Offset.zero)
        .translate(renderBoxSize.width / 2, renderBoxSize.height / 2);

    setState(() {
      isShowDialogMenu = true;
    });
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return FocusAwareBuilder(builder: (primaryFocusNode) {
          return V3CustomDialog(
            primaryFocusNode: primaryFocusNode,
            offset: containerOffset,
            alignmentGeometry: Alignment.centerRight,
            // 由於parent寬度是會變動的，這邊dialog不寫死寬度，改成parent寬度的80%
            width: renderBox.size.width * 0.8,
            title: S.of(context).v3_exit_moderator_mode_title,
            content: S.of(context).v3_exit_moderator_mode_desc,
            item1: S.of(context).v3_exit_moderator_mode_cancel,
            item1Label: S.of(context).v3_lbl_exit_moderator_cancel,
            item1Identifier: 'v3_qa_exit_moderator_cancel',
            onItem1: () {
              if (navService.canPop()) {
                navService.goBack();
              }
            },
            item2: S.of(context).v3_exit_moderator_mode_exit,
            item2Label: S.of(context).v3_lbl_exit_moderator_exit,
            item2Identifier: 'v3_qa_exit_moderator_exit',
            onItem2: () async {
              trackEvent('click_moderator', EventCategory.menu, target: 'off');

              Provider.of<ChannelProvider>(context, listen: false)
                  .setModeratorMode(false);
              MirrorStateProvider mirrorStateProvider =
                  Provider.of<MirrorStateProvider>(context, listen: false);
              await mirrorStateProvider.stopAllMirror();
              await HybridConnectionList().removeAllPresenters();
              if (context.mounted) {
                await mirrorStateProvider.restartMirror();
              }
              if (navService.canPop()) {
                navService.goBack();
              }
            },
          );
        });
      },
    ).then((_) {
      setState(() {
        isShowDialogMenu = false;
      });
    });
  }
}
