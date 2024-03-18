import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/widgets/custom_alert_dialog.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:display_flutter/widgets/participant_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class ModeratorMenuView extends StatefulWidget {
  const ModeratorMenuView({super.key});

  static ValueNotifier<bool> showModeratorMessage = ValueNotifier(false);

  @override
  State createState() => _ModeratorMenuViewState();
}

class _ModeratorMenuViewState extends State<ModeratorMenuView> {
  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    return MenuDialog(
      backgroundColor: HybridConnectionList().isPresenting()
          ? AppColors.primary_grey_tran
          : AppColors.primary_grey,
      topTitleText: S.of(context).moderator_presentersList,
      topTitleAction: FocusIconButton(
        childNotFocus: Image(
          image: Svg(channelProvider.isModeratorMode == true
              ? 'assets/images/ic_activate_on.svg'
              : 'assets/images/ic_activate_off.svg'),
        ),
        splashRadius: 20,
        focusColor: Colors.grey,
        onClick: () {
          if (channelProvider.isModeratorMode) {
            _callLogOutDialog();
          } else {
            channelProvider.isModeratorMode = true;

            //TODO Moderator button cannot be pressed while mirror is playing
            // mirrorStateProvider.pauseMirror();
          }
        },
      ),
      content: const ParticipantListView(),
    );
  }

  void _callLogOutDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: '',
          description: S.of(context).moderator_exit_dialog,
          positiveButton: S.of(context).moderator_exit,
          onPositive: () {
            Provider.of<ChannelProvider>(context, listen: false)
                .isModeratorMode = false;
            AppAnalytics().trackEventModeratorOff();
            _switchModeratorOff();
            setState(() {});

            //TODO Moderator button cannot be pressed while mirror is playing
            // mirrorStateProvider.resumeMirror();
          },
          onNegative: () {},
        );
      },
    );
  }

  _switchModeratorOff() {
    HybridConnectionList().removeAllPresenters();
    SplitScreen.mapSplitScreen.value[keySplitScreenCount] =
        HybridConnectionList().mirroringCount();
    SplitScreen.mapSplitScreen.value =
        Map.from(SplitScreen.mapSplitScreen.value);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
