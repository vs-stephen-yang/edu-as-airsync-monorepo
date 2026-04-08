import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/widgets/v3_help_center.dart';
import 'package:display_flutter/widgets/v3_participant_item.dart';
import 'package:display_flutter/widgets/v3_participant_mirror_item.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';

class V3ParticipantList extends StatefulWidget {
  const V3ParticipantList({super.key, this.isForMenuUse = false});

  final bool isForMenuUse;

  @override
  State<V3ParticipantList> createState() => _V3ParticipantListState();
}

class _V3ParticipantListState extends State<V3ParticipantList> {
  @override
  void initState() {
    super.initState();
    HybridConnectionList.connectionFullNotifier.addListener(_onConnectionFull);
  }

  @override
  void dispose() {
    HybridConnectionList.connectionFullNotifier
        .removeListener(_onConnectionFull);
    super.dispose();
  }

  void _onConnectionFull() {
    final event = HybridConnectionList.connectionFullNotifier.value;
    if (event == null) return;
    HybridConnectionList.connectionFullNotifier.value = null;
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      final String message;
      if (event.type == ModeratorConnectionFullType.mirrorFull) {
        message = S.of(context).toast_moderator_mirror_full(event.deviceName);
      } else {
        message = S.of(context).toast_moderator_webrtc_full;
      }
      MotionToast(
        primaryColor: Colors.grey,
        description: AutoSizeText(message, maxLines: 2),
        displaySideBar: false,
      ).show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChannelProvider, MirrorStateProvider>(
      builder: (context, channelProvider, mirrorProvider, child) {
        if (!ChannelProvider.isModeratorMode) {
          final sc = ScrollController();
          return Center(
            child: V3Scrollbar(
              controller: sc,
              child: SingleChildScrollView(
                controller: sc,
                padding: EdgeInsets.only(
                    right: MediaQuery.of(context).textScaler.scale(1.0) > 1
                        ? 5.0
                        : 0),
                child: Column(
                  mainAxisAlignment: ChannelProvider.isModeratorMode
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    if (ChannelProvider.isModeratorMode) ...[
                      AutoSizeText.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: S.of(context).v3_participants_title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.tokens.color.vsdslColorOnSurface,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' (${HybridConnectionList().getConnectionCount()}/${HybridConnectionList.maxModeratorTotalConnection})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: context.tokens.color.vsdslColorOnSurface,
                            ),
                          )
                        ]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 133),
                    ],
                    SvgPicture.asset(
                      ChannelProvider.isModeratorMode
                          ? 'assets/images/ic_moderator_people.svg'
                          : 'assets/images/ic_moderator_screen.svg',
                      excludeFromSemantics: true,
                      width: 126,
                      height: 110,
                    ),
                    SizedBox(
                      height: ChannelProvider.isModeratorMode
                          ? context.tokens.spacing.vsdslSpacing2xl.top
                          : context.tokens.spacing.vsdslSpacingXl.top,
                    ),
                    AutoHyphenatingText(
                      HybridConnectionList.maxHybridSplitScreen == 9
                          ? S.of(context).v3_participants_desc_maximum_9
                          : S.of(context).v3_participants_desc,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: context.tokens.color.vsdslColorOnSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          final ScrollController scrollController = ScrollController();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AutoSizeText.rich(
                TextSpan(children: [
                  TextSpan(
                    text: S.of(context).v3_participants_title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.tokens.color.vsdslColorOnSurface,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' (${HybridConnectionList().getConnectionCount()}/${HybridConnectionList.maxModeratorTotalConnection})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: context.tokens.color.vsdslColorOnSurface,
                    ),
                  ),
                ]),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.tokens.spacing.vsdslSpacing3xl.top),
              Expanded(
                child: V3Scrollbar(
                  controller: scrollController,
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: HybridConnectionList().getConnectionCount(),
                    itemBuilder: (BuildContext context, int index) {
                      if (HybridConnectionList().isMirrorRequest(index)) {
                        return V3ParticipantMirrorItem(
                            index: index, isForMenuUse: widget.isForMenuUse);
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: V3ParticipantItem(
                            index: index,
                            isForMenuUse: widget.isForMenuUse,
                          ),
                        );
                      }
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return widget.isForMenuUse
                          ? Divider(
                              height: context
                                  .tokens.spacing.vsdslSpacingLg.vertical,
                              color: context
                                  .tokens.color.vsdslColorOnSurfaceVariant
                                  .withOpacity(0.32),
                            )
                          : Divider(
                              height:
                                  context.tokens.spacing.vsdslSpacingXl.top / 2,
                              color: Colors.transparent,
                            );
                    },
                  ),
                ),
              ),
              V3HelpCenterWidget(),
            ],
          );
        }
      },
    );
  }
}
