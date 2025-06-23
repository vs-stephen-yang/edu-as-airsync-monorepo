import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3ParticipantMirrorItem extends StatefulWidget {
  const V3ParticipantMirrorItem(
      {super.key, required this.index, required this.isForMenuUse});

  final int index;
  final bool isForMenuUse;

  @override
  State createState() => _V3ParticipantMirrorItemState();
}

class _V3ParticipantMirrorItemState extends State<V3ParticipantMirrorItem> {
  @override
  Widget build(BuildContext context) {
    final MirrorRequest mirrorRequest =
        HybridConnectionList().getConnection<MirrorRequest>(widget.index);
    String mirrorId = mirrorRequest.mirrorId;
    Widget? itemParticipant;
    bool isCasting = mirrorRequest.mirrorState == MirrorState.mirroring;
    String status = '';
    if (isCasting) {
      status = S.of(context).v3_participant_item_casting;
      itemParticipant = ParticipantStreamingFeature(
        mirrorId: mirrorId,
      );
    } else {
      itemParticipant = ParticipantStandbyFeature(
        mirrorId: mirrorId,
        isForMenuUse: widget.isForMenuUse,
      );
    }

    if (mirrorRequest.mirrorState == MirrorState.idle) {
      return const SizedBox.shrink();
    } else {
      return Container(
        alignment: Alignment.center,
        width: widget.isForMenuUse ? 358 : 283,
        child: Row(
          children: [
            SvgPicture.asset(
              isCasting
                  ? 'assets/images/ic_participant_avatar_cast.svg'
                  : 'assets/images/ic_participant_avatar_wait.svg',
              width: 32,
              height: 32,
            ),
            Gap(context.tokens.spacing.vsdslSpacingSm.left),
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Container(
                    constraints: BoxConstraints(minHeight: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          mirrorRequest.deviceName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.tokens.color.vsdslColorOnSurface,
                          ),
                        ),
                        if (widget.isForMenuUse && status.isNotEmpty) ...[
                          Gap(context.tokens.spacing.vsdslSpacingXs.top),
                          AutoSizeText(
                            status,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: (isCasting)
                                  ? context
                                      .tokens.color.vsdslColorSecondaryVariant
                                  : context
                                      .tokens.color.vsdslColorSuccessVariant,
                            ),
                            textAlign: TextAlign.center,
                            minFontSize: 8,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Gap(context.tokens.spacing.vsdslSpacing2xl.left),
                  itemParticipant,
                ],
              ),
            ),
            if (!isCasting)
              V3Focus(
                label: S.of(context).v3_lbl_participant_mirror_close,
                identifier: 'v3_qa_participant_mirror_close',
                child: SizedBox(
                  width: 27,
                  height: 27,
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/images/ic_participant_close.svg',
                    ),
                    style: IconButton.styleFrom(
                      elevation: 10.0,
                      shadowColor:
                          context.tokens.color.vsdslColorOpacityNeutralXs,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      EasyThrottle.throttle(
                          'sendPresenterRemove', const Duration(seconds: 1),
                          () {
                        _sendPresenterRemove(context, mirrorId);
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }

  _sendPresenterRemove(BuildContext context, String mirrorId) async {
    final mirrorStateProvider =
        Provider.of<MirrorStateProvider>(context, listen: false);
    mirrorStateProvider.stopAcceptedMirror(mirrorId, removeUserEvent: true);
  }
}

class ParticipantStandbyFeature extends StatelessWidget {
  const ParticipantStandbyFeature({
    super.key,
    required this.mirrorId,
    required this.isForMenuUse,
  });

  final String mirrorId;
  final bool isForMenuUse;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        V3Focus(
          label: S.of(context).v3_lbl_participant_mirror_share,
          identifier: 'v3_qa_participant_mirror_share',
          child: SizedBox(
            height: 27,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 5.0,
                shadowColor: context.tokens.color.vsdslColorOpacitySecondaryLg,
                backgroundColor: context.tokens.color.vsdslColorPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: context.tokens.radii.vsdslRadiusFull,
                ),
                padding: EdgeInsets.symmetric(horizontal: 10),
              ),
              onPressed: () {
                EasyThrottle.throttle('presenterOn', const Duration(seconds: 1),
                    () {
                  _presenterOn(context, mirrorId);
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isForMenuUse) ...[
                    SizedBox(
                      child: SvgPicture.asset(
                        'assets/images/ic_arrow_to_screen.svg',
                        excludeFromSemantics: true,
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          context.tokens.color.vsdslColorOnSurfaceInverse,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Gap(context.tokens.spacing.vsdslSpacingXs.left),
                  ],
                  Text(
                    S.of(context).v3_participant_item_share,
                    textAlign: isForMenuUse ? TextAlign.left : TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.tokens.color.vsdslColorOnSurfaceInverse,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _presenterOn(BuildContext context, String mirrorId) {
    final mirrorStateProvider =
        Provider.of<MirrorStateProvider>(context, listen: false);
    mirrorStateProvider.setAcceptMirrorId(mirrorId);
  }
}

class ParticipantStreamingFeature extends StatelessWidget {
  const ParticipantStreamingFeature({
    super.key,
    required this.mirrorId,
  });

  final String mirrorId;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        V3Focus(
          label: S.of(context).v3_lbl_participant_mirror_stop,
          identifier: 'v3_qa_participant_mirror_stop',
          child: SizedBox(
            width: 27,
            height: 27,
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/images/ic_participant_stop.svg',
              ),
              style: IconButton.styleFrom(
                elevation: 10.0,
                shadowColor: context.tokens.color.vsdslColorOpacityNeutralXs,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                EasyThrottle.throttle(
                    'presenterOff', const Duration(seconds: 1), () {
                  _presenterOff(context, mirrorId);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  _presenterOff(BuildContext context, String mirrorId) {
    final mirrorStateProvider =
        Provider.of<MirrorStateProvider>(context, listen: false);
    mirrorStateProvider.setModeratorIdleMirrorId(mirrorId, stopCastEvent: true);
  }
}
