
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:display_flutter/widgets/sender_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
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
    return MenuDialog(
      backgroundColor: channelProvider.isPresenting()
          ? AppColors.primary_grey_tran
          : AppColors.primary_grey,
      child: ValueListenableBuilder(
          valueListenable: editMode,
        builder: (BuildContext context, bool value, Widget? child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Visibility(
                visible: !value,
                child: Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: <Widget>[
                        FittedBox(
                          fit: BoxFit.fitHeight,
                          child: FocusIconButton(
                            childNotFocus: const Icon(
                              Icons.arrow_back_ios_new,
                              color: AppColors.primary_white,
                            ),
                            splashRadius: 20,
                            focusColor: Colors.grey,
                            onClick: () {
                              navService.popUntil('/home');
                            },
                          ),
                        ),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                S.of(context).main_setting_share_to_sender,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary_white,
                                ),
                              ),
                            ),
                          ),
                        ),
                          FittedBox(
                          fit: BoxFit.fitHeight,
                          child: FocusIconButton(
                            childNotFocus: Image(
                              image: Svg(ChannelProvider.isSenderMode
                                  ? 'assets/images/ic_activate_on.svg'
                                  : 'assets/images/ic_activate_off.svg'),
                            ),
                            splashRadius: 20,
                            focusColor: Colors.grey,
                            onClick: () async {
                              ChannelProvider.isSenderMode = !ChannelProvider.isSenderMode;
                              if (!ChannelProvider.isSenderMode) {
                                channelProvider.removeSender();
                              } else {
                                // channelProvider.startRemoteScreen();
                              }
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    Expanded(
                      child: SenderListView(value),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: value,
                  child: Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {

                        },
                        child: Text(S.of(context).moderator_cancel),
                      ),
                      ElevatedButton(
                        onPressed: () {

                        },
                        child: Text(S.of(context).moderator_remove),
                      ),
                    ],
                  ),
                ),
              ))
            ],
          );
        }
      ),
    );
  }

}