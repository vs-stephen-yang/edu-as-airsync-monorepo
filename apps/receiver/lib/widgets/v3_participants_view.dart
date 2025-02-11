import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/widgets/focus_aware_builder.dart';
import 'package:display_flutter/widgets/v3_custom_dialog.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_participant_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _containerKey,
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 13,
          top: 27,
          right: 13,
          bottom: 13,
          child: Container(
            padding: widget.isLandscape
                ? EdgeInsets.zero
                : const EdgeInsets.only(left: 20, right: 20),
            child: const V3ParticipantList(),
          ),
        ),
        Positioned(
          bottom: widget.isLandscape ? 20 : 40,
          child: V3Focus(
            child: Container(
              width: 270,
              height: 53,
              padding: const EdgeInsets.all(16),
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(9999)),
                  side: BorderSide(
                    width: 1,
                    color: Color(0xFFE9EAF0),
                  ),
                ),
              ),
              child: Row(
                children: [
                  AutoSizeText(
                    S.of(context).v3_moderator_mode,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Consumer<ChannelProvider>(builder: (_, channelProvider, __) {
                    return SizedBox(
                      width: 37,
                      height: 21,
                      child: IconButton(
                        icon: Image(
                          image: Svg(ChannelProvider.isModeratorMode
                              ? 'assets/images/ic_switch_on.svg'
                              : 'assets/images/ic_switch_off.svg'),
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
        IgnorePointer(
          child: LayoutBuilder(builder: (context, constraints) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: widget.isLandscape
                      ? const Radius.circular(30)
                      : Radius.zero,
                  bottomRight: const Radius.circular(30),
                  bottomLeft: !widget.isLandscape
                      ? const Radius.circular(30)
                      : Radius.zero,
                ),
                color: isShowDialogMenu
                    ? context.tokens.color.vsdslColorSurface1000
                        .withOpacity(0.16)
                    : Colors.transparent,
              ),
            );
          }),
        ),
      ],
    );
  }

  void _callLogOutDialog(BuildContext context) async {
    final RenderBox renderBox =
        _containerKey.currentContext!.findRenderObject() as RenderBox;
    final Size renderBoxSize = Size(renderBox.size.width - V3CustomDialog.width,
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
            title: S.of(context).v3_exit_moderator_mode_title,
            content: S.of(context).v3_exit_moderator_mode_desc,
            item1: S.of(context).v3_exit_moderator_mode_cancel,
            onItem1: () {
              if (navService.canPop()) {
                navService.goBack();
              }
            },
            item2: S.of(context).v3_exit_moderator_mode_exit,
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
