import 'dart:async';

import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'custom_text_form_field.dart';

class ModeratorIdle extends StatefulWidget {
  const ModeratorIdle({super.key});

  @override
  State<ModeratorIdle> createState() => _ModeratorIdleState();
}

class _ModeratorIdleState extends State<ModeratorIdle> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final nameKey = GlobalKey();
  bool presentBtnEnable = false;

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
      children: [
        Positioned(
          left: 30,
          top: 100,
          child: InkWell(
              onTap: () {
                channelProvider.resetMessage();
                presentStateProvider.presentMainPage();
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: Colors.white,
                    size: 14,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      S.of(context).moderator_back,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppConstants.fontSizeNormal),
                    ),
                  ),
                ],
              )),
        ),
        Center(
          child: SizedBox(
            width: AppConstants.viewStateMenuWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.groups,
                      color: Colors.white,
                      size: 26,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        S.of(context).moderator,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: AppConstants.fontSizeTitle,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(16)),
                CustomTextFormField(
                  key: nameKey,
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  labelText: S.of(context).moderator_name,
                  labelBackgroundColor: Colors.transparent,
                  labelTextColor: Colors.white,
                  inputFormatter: const [],
                  onChanged: (text) {
                    if (text.isNotEmpty) {
                      presentBtnEnable = true;
                    } else {
                      presentBtnEnable = false;
                    }
                    setState(() {});
                  },
                  onFieldSubmitted: (String value) async {
                    if (presentBtnEnable) {
                      await clickPresent();
                    }
                  },
                ),
                const Padding(padding: EdgeInsets.all(16)),
                ElevatedButton(
                  onPressed: () async {
                    await clickPresent();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: presentBtnEnable
                        ? const Color.fromARGB(255, 41, 121, 255)
                        : const Color.fromARGB(128, 242, 242, 242),
                    fixedSize: const Size(300, 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text(
                    S.of(context).main_present,
                    style: TextStyle(
                      color: presentBtnEnable
                          ? Colors.white
                          : const Color.fromARGB(255, 153, 153, 153),
                      fontSize: AppConstants.fontSizeNormal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  void _showOverlayMessage(BuildContext context, GlobalKey widgetKey) {
    const overlayWidth = 200.0;
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
