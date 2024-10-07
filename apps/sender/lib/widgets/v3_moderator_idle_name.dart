import 'dart:async';
import 'dart:io';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/widgets/toast.dart';
import 'package:display_cast_flutter/widgets/v3_custom_text_form_field.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class V3ModeratorIdleName extends StatefulWidget {
  const V3ModeratorIdleName({super.key});

  @override
  State<V3ModeratorIdleName> createState() => _V3ModeratorIdleNameState();
}

class _V3ModeratorIdleNameState extends State<V3ModeratorIdleName> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final GlobalKey<V3CustomTextFormFieldState> nameKey = GlobalKey();
  final GlobalKey<V3PresentIdleButtonState> buttonKey = GlobalKey();
  final bool isMobile = Platform.isAndroid || Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context, listen: false);

    Future<void> clickPresent() async {
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

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isMobile)
          Positioned(
            left: 8,
            top: 24,
            child: BackButton(
                channelProvider: channelProvider,
                presentStateProvider: presentStateProvider),
          ),
        Align(
          alignment: Alignment.center,
          child: Container(
              width: 359,
              height: 495,
              decoration: BoxDecoration(
                color: context.tokens.color.vsdswColorSurface100,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(24),
                boxShadow: context.tokens.shadow.vsdswShadowNeutralLg,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 138,
                      height: 120,
                      child: SvgPicture.asset(
                          'assets/images/v3_ic_select_share.svg')),
                  const Padding(padding: EdgeInsets.only(bottom: 24)),
                  Text(
                    'Share',
                    style: TextStyle(
                      color: context.tokens.color.vsdswColorOnSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 8)),
                  Text(
                    'Enter your name before share your screen',
                    style: TextStyle(
                      color: context.tokens.color.vsdswColorOnSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.16,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 40)),
                  _inputName(context, clickPresent),
                  Padding(
                      padding: EdgeInsets.only(
                          bottom:
                              context.tokens.spacing.vsdswSpacingSm.bottom)),
                  V3PresentIdleButton(
                      key: buttonKey,
                      fixedSize: const Size(300, 48),
                      buttonText: 'Share',
                      onPressed: () async {
                        await clickPresent();
                      })
                ],
              )),
        ),
        if (!isMobile)
          Transform.translate(
            offset: const Offset(-220, 0),
            // Move Button B 16 pixels to the right from Container A
            child: BackButton(
                channelProvider: channelProvider,
                presentStateProvider: presentStateProvider),
          ),
      ],
    );
  }

  SizedBox _inputName(
      BuildContext context, Future<void> Function() clickPresent) {
    return SizedBox(
      width: 300,
      height: 84,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 56,
            child: V3CustomTextFormField(
              key: nameKey,
              controller: _nameController,
              focusNode: _nameFocusNode,
              hintText: 'Type your name',
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
                  await clickPresent();
                }
              },
            ),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 10)),
          Row(
            children: [
              SizedBox(
                  width: 16,
                  height: 16,
                  child:
                      SvgPicture.asset('assets/images/v3_ic_error_black.svg')),
              Padding(
                  padding: EdgeInsets.only(
                      left: context.tokens.spacing.vsdswSpacing2xs.left)),
              Text(
                'Please limit the name to 20 characters.',
                style: TextStyle(
                  color: context.tokens.color.vsdswColorOnSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
                  Text(
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

class BackButton extends StatelessWidget {
  const BackButton({
    super.key,
    required this.channelProvider,
    required this.presentStateProvider,
  });

  final ChannelProvider channelProvider;
  final PresentStateProvider presentStateProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: ShapeDecoration(
        color: context.tokens.color.vsdswColorSurface100,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: context.tokens.color.vsdswColorSurface100,
          ),
          borderRadius: context.tokens.radii.vsdswRadiusFull,
        ),
        shadows: context.tokens.shadow.vsdswShadowNeutralLg,
      ),
      child: IconButton(
        icon: SvgPicture.asset('assets/images/v3_ic_arrow_back.svg'),
        onPressed: () {
          channelProvider.resetMessage();
          presentStateProvider.presentMainPage();
        },
      ),
    );
  }
}
