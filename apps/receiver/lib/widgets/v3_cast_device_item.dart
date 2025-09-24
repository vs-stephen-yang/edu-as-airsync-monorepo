import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/model/text_scale_option.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3CastDeviceItem extends _TextSizeAwareStateful {
  const V3CastDeviceItem({super.key, required this.index});

  final int index;

  @override
  Widget buildWithTextSize(
      BuildContext context, void Function() refreshWidget) {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    RemoteScreenConnector remoteScreenConnector =
        channelProvider.remoteScreenConnectors[index];

    String status = S.of(context).v3_cast_to_device_Receiving;
    if (remoteScreenConnector.isTouchEnabled) {
      status += ' + ';
      status += S.of(context).v3_cast_to_device_touch_enabled;
    }
    return Container(
      alignment: Alignment.center,
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/ic_cast_device.svg',
            excludeFromSemantics: true,
            width: 32,
            height: 32,
          ),
          const Gap(5),
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      remoteScreenConnector.senderName ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.tokens.color.vsdslColorOnSurface,
                      ),
                    ),
                    SizedBox(width: context.tokens.spacing.vsdslSpacingXs.top),
                    Container(
                      padding: context.tokens.spacing.vsdslSpacingXs,
                      child: AutoSizeText(
                        status,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: context.tokens.color.vsdslColorSuccessVariant,
                        ),
                        minFontSize: 8,
                      ),
                    ),
                  ],
                ),
                if (channelProvider.remoteScreenServe.supportTouchEvent) ...[
                  const Gap(16),
                  V3Focus(
                    label: remoteScreenConnector.isTouchEnabled
                        ? S.of(context).v3_lbl_cast_device_touchback_disable
                        : S.of(context).v3_lbl_cast_device_touchback_enable,
                    identifier: remoteScreenConnector.isTouchEnabled
                        ? 'v3_qa_cast_device_touchback_disable_$index'
                        : 'v3_qa_cast_device_touchback_enable_$index',
                    child: SizedBox(
                      height: 27 * AppPreferences().textScale,
                      child: showIcon
                          ? InkWell(
                              onTap: () {
                                if (remoteScreenConnector.isTouchEnabled) {
                                  remoteScreenConnector.isTouchEnabled = false;
                                } else {
                                  remoteScreenConnector.isTouchEnabled = true;
                                }
                                channelProvider.remoteScreenServe
                                    .enableRemoteControlBySessionId(
                                        remoteScreenConnector.sessionId!,
                                        remoteScreenConnector.isTouchEnabled);
                                refreshWidget();
                              },
                              child: SvgPicture.asset(
                                remoteScreenConnector.isTouchEnabled
                                    ? 'assets/images/ic_moderator_untouchback.svg'
                                    : 'assets/images/ic_moderator_touchback.svg',
                                width: 26,
                                height: 26,
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () {
                                if (remoteScreenConnector.isTouchEnabled) {
                                  remoteScreenConnector.isTouchEnabled = false;
                                } else {
                                  remoteScreenConnector.isTouchEnabled = true;
                                }
                                channelProvider.remoteScreenServe
                                    .enableRemoteControlBySessionId(
                                        remoteScreenConnector.sessionId!,
                                        remoteScreenConnector.isTouchEnabled);
                                refreshWidget();
                              },
                              icon: SvgPicture.asset(
                                remoteScreenConnector.isTouchEnabled
                                    ? 'assets/images/ic_finger_disable.svg'
                                    : 'assets/images/ic_finger_touch.svg',
                                excludeFromSemantics: true,
                                width: 16,
                                height: 16,
                              ),
                              label: V3AutoHyphenatingText(
                                remoteScreenConnector.isTouchEnabled
                                    ? S
                                        .of(context)
                                        .v3_cast_to_device_touch_back_disable
                                    : S
                                        .of(context)
                                        .v3_cast_to_device_touch_back,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: remoteScreenConnector.isTouchEnabled
                                      ? context.tokens.color.vsdslColorError
                                      : context
                                          .tokens.color.vsdslColorOnSurface,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 5,
                                backgroundColor: context
                                    .tokens.color.vsdslColorOnSurfaceInverse,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      context.tokens.radii.vsdslRadiusFull,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: context
                                        .tokens.spacing.vsdslSpacingSm.left),
                                shadowColor:
                                    context.tokens.color.vsdslColorNeutral,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: context.tokens.spacing.vsdslSpacingSm.top),
          V3Focus(
            label: S.of(context).v3_lbl_cast_device_close,
            identifier: 'v3_qa_cast_device_close',
            child: SizedBox(
              width: 27,
              height: 27,
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/images/ic_participant_close.svg',
                  excludeFromSemantics: true,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  if (remoteScreenConnector.remotePresentationState ==
                      RemotePresentationState.streaming) {
                    channelProvider.removeSender(
                      fromSender: true,
                      remoteScreenConnector: remoteScreenConnector,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

abstract class _TextSizeAwareStateful extends StatefulWidget {
  const _TextSizeAwareStateful({super.key});

  ResizeTextSizeOption get textSize => AppPreferences().textSizeOption;

  bool get showIcon =>
      AppPreferences().textSizeOption != ResizeTextSizeOption.normal;

  @override
  State<_TextSizeAwareStateful> createState() => _TextSizeAwareStatefulState();

  /// 子類需要實作這個方法
  Widget buildWithTextSize(BuildContext context, void Function() refreshWidget);
}

class _TextSizeAwareStatefulState extends State<_TextSizeAwareStateful> {
  late VoidCallback listener;

  @override
  void initState() {
    super.initState();
    listener = () {
      if (!mounted) return;
      setState(() {}); // 只要 textSizeOptionNotifier 改變就重新 build
    };
    AppPreferences().textSizeOptionNotifier.addListener(listener);
  }

  @override
  void dispose() {
    AppPreferences().textSizeOptionNotifier.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.buildWithTextSize(context, () {
      if (!mounted) return;
      setState(() {});
    });
  }
}
