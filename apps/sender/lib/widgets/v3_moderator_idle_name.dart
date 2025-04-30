import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/widgets/toast.dart';
import 'package:display_cast_flutter/widgets/v3_back_button.dart';
import 'package:display_cast_flutter/widgets/v3_custom_text_form_field.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle_button.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class V3ModeratorIdleName extends StatelessWidget {
  const V3ModeratorIdleName({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    Widget backButton;
    if (!kIsWeb && !isMobile) {
      backButton = Transform.translate(
        offset: const Offset(-278, 0), // (475+48)/2+16~=278
        // Move Button B 16 pixels to the right from Container A
        child: _backButton(context),
      );
    } else {
      backButton = Positioned(
        left: kIsWeb ? 24 : 8,
        top: kIsWeb ? 193 : 24,
        child: _backButton(context),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            width: kIsWeb
                ? 400
                : isMobile
                    ? 359
                    : 475,
            height: kIsWeb
                ? 320
                : isMobile
                    ? 495
                    : 504,
            margin: const EdgeInsets.all(8),
            decoration: (kIsWeb)
                ? null
                : BoxDecoration(
                    color: context.tokens.color.vsdswColorSurface100,
                    border: Border.all(
                        color: context.tokens.color.vsdswColorSurface100),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: context.tokens.shadow.vsdswShadowNeutralLg,
                  ),
            child: const V3ModeratorInputName(),
          ),
        ),
        backButton,
      ],
    );
  }

  V3BackButton _backButton(BuildContext context) {
    return V3BackButton(
      label: S.of(context).v3_lbl_moderator_back,
      identifier: 'v3_qa_moderator_back',
      onPressed: () {
        ChannelProvider channelProvider =
            Provider.of<ChannelProvider>(context, listen: false);
        PresentStateProvider presentStateProvider =
            Provider.of<PresentStateProvider>(context, listen: false);
        channelProvider.presentEnd();
        channelProvider.resetMessage();
        presentStateProvider.presentMainPage();
      },
    );
  }
}

class V3ModeratorInputName extends StatefulWidget {
  const V3ModeratorInputName({super.key});

  @override
  State<StatefulWidget> createState() => _V3ModeratorInputNameState();
}

class _V3ModeratorInputNameState extends State<V3ModeratorInputName> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final GlobalKey<V3CustomTextFormFieldState> nameKey = GlobalKey();
  final GlobalKey<V3PresentIdleButtonState> buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    return Padding(
      padding:
          kIsWeb ? EdgeInsets.zero : const EdgeInsets.only(left: 24, right: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            kIsWeb ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (kIsWeb) ...[
            AutoSizeText(
              S.of(context).v3_main_moderator_title,
              style: TextStyle(
                fontSize: 32,
                color: context.tokens.color.vsdswColorOnSurface,
                fontWeight: FontWeight.w700,
                // height: 0.04,
                letterSpacing: -0.32,
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 8)),
            AutoSizeText(
              S.of(context).v3_main_moderator_subtitle,
              style: TextStyle(
                fontSize: 18,
                color: context.tokens.color.vsdswColorOnSurfaceVariant,
                fontWeight: FontWeight.w400,
                // height: 0.10,
                letterSpacing: -0.18,
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 40)),
          ],
          if (!kIsWeb) ...[
            SizedBox(
              width: 138,
              height: 120,
              child: SvgPicture.asset(
                channelProvider.currentRole == JoinIntentType.remoteScreen
                    ? 'assets/images/v3_ic_select_receive.svg'
                    : 'assets/images/v3_ic_select_share.svg',
                excludeFromSemantics: true,
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 24)),
            AutoSizeText(
              channelProvider.currentRole == JoinIntentType.remoteScreen
                  ? S.of(context).v3_main_receive_app_title
                  : S.of(context).v3_main_moderator_app_title,
              style: TextStyle(
                color: context.tokens.color.vsdswColorOnSurface,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 8)),
            AutoSizeText(
              channelProvider.currentRole == JoinIntentType.remoteScreen
                  ? S.of(context).v3_main_receive_app_subtitle
                  : S.of(context).v3_main_moderator_app_subtitle,
              textAlign: kIsWeb ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                color: context.tokens.color.vsdswColorOnSurface,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.16,
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 40)),
          ],
          SizedBox(
            width: kIsWeb ? 400 : 300,
            height: 84,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 56,
                  child: V3CustomTextFormField(
                    label: S.of(context).v3_lbl_main_moderator_input_hint,
                    identifier: 'v3_qa_main_moderator_input_hint',
                    key: nameKey,
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    hintText: S.of(context).v3_main_moderator_input_hint,
                    maxTextLength: 20,
                    inputFormatter: const [],
                    onFieldChanged: (text) {
                      if (text.isNotEmpty) {
                        buttonKey.currentState!.setEnable(true);
                      } else {
                        buttonKey.currentState!.setEnable(false);
                      }
                      setState(() {});
                    },
                    onFieldSubmitted: (String value) async {
                      if (buttonKey.currentState!.isButtonEnabled) {
                        await _clickPresent();
                      }
                    },
                  ),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 10)),
                MergeSemantics(
                  child: Row(
                    children: [
                      SizedBox(
                          width: 16,
                          height: 16,
                          child: SvgPicture.asset(
                            'assets/images/v3_ic_error_black.svg',
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left:
                                  context.tokens.spacing.vsdswSpacing2xs.left)),
                      AutoSizeText(
                        S.of(context).v3_main_moderator_input_limit,
                        style: TextStyle(
                          color: context.tokens.color.vsdswColorOnSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
              padding: EdgeInsets.only(
                  bottom: kIsWeb
                      ? context.tokens.spacing.vsdswSpacing5xl.bottom
                      : context.tokens.spacing.vsdswSpacingSm.bottom)),
          V3PresentIdleButton(
            buttonIdentifier:
                channelProvider.currentRole == JoinIntentType.remoteScreen
                    ? 'v3_qa_main_receive_app_action'
                    : 'v3_qa_main_moderator_action',
            buttonLabel:
                channelProvider.currentRole == JoinIntentType.remoteScreen
                    ? S.of(context).v3_lbl_main_receive_app_action
                    : S.of(context).v3_lbl_main_moderator_action,
            key: buttonKey,
            fixedSize: const Size(kIsWeb ? 240 : 300, 48),
            buttonText:
                channelProvider.currentRole == JoinIntentType.remoteScreen
                    ? S.of(context).v3_main_receive_app_action
                    : S.of(context).v3_main_moderator_action,
            onPressed: () async {
              await _clickPresent();
            },
          )
        ],
      ),
    );
  }

  Future<void> _clickPresent() async {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context, listen: false);
    if (presentStateProvider.currentState == ViewState.moderatorName) {
      if (_nameController.text.isEmpty) {
        _showOverlayMessage(context, nameKey);
      } else if (channelProvider.displayCode != null) {
        if (channelProvider.isConnectAvailable()) {
          channelProvider.setSenderName(_nameController.text);
        } else {
          Toast.makeFeatureReconnectToast(
              channelProvider.reconnectState,
              channelProvider.reconnectState ==
                      ChannelReconnectState.reconnecting
                  ? S.of(context).main_feature_reconnecting_toast
                  : S.of(context).main_feature_reconnect_fail_toast);
        }
      }
    }
  }

  void _showOverlayMessage(BuildContext context, GlobalKey widgetKey) {
    const overlayWidth = 300.0;
    const overlayHeight = 30.0;
    RenderBox renderBox =
        widgetKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);

    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        left: position.dx + (renderBox.size.width - overlayWidth) / 2,
        top: position.dy + (renderBox.size.height - overlayHeight) / 2,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Material(
            child: Container(
              alignment: Alignment.center,
              color: Colors.white,
              width: overlayWidth,
              height: overlayHeight,
              child: Row(
                children: [
                  const Icon(
                    Icons.info,
                    color: Colors.amber,
                  ),
                  AutoSizeText(
                    S.of(context).moderator_fill_out,
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });

    Overlay.of(context).insert(overlayEntry);

    Timer(const Duration(seconds: 5), () {
      overlayEntry.remove();
    });
  }
}
