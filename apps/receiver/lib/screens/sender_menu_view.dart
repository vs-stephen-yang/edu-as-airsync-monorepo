import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:display_flutter/widgets/sender_list_view.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class SenderMenuView extends StatefulWidget {
  const SenderMenuView({super.key});

  @override
  State<StatefulWidget> createState() => _SenderMenuViewState();
}

class _SenderMenuViewState extends State<SenderMenuView> {
  ValueNotifier<bool> editMode = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    return ValueListenableBuilder(
      valueListenable: editMode,
      builder: (BuildContext context, bool value, Widget? child) {
        return MenuDialog(
          backgroundColor: HybridConnectionList().isPresenting()
              ? AppColors.primaryGreyTran
              : AppColors.primaryGrey,
          topTitleText: S.of(context).main_settings_share_to_sender,
          topTitleAction: FocusIconButton(
            childNotFocus: Image(
              image: Svg(channelProvider.isSenderMode
                  ? 'assets/images/ic_activate_on.svg'
                  : 'assets/images/ic_activate_off.svg'),
            ),
            splashRadius: 20,
            focusColor: Colors.grey,
            onClick: () async {
              if (channelProvider.isSenderMode) {
                channelProvider.removeSender(fromSender: true);
              } else {
                await channelProvider.startRemoteScreen(fromSender: true);
              }
              if (!mounted) return;
              setState(() {});
            },
          ),
          content: SenderListView(value),
          bottomAction: value
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        editMode.value = false;
                      },
                      child:
                          V3AutoHyphenatingText(S.of(context).moderator_cancel),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child:
                          V3AutoHyphenatingText(S.of(context).moderator_remove),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
}
