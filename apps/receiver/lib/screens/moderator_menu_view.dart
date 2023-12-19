import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/widgets/custom_alert_dialog.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:display_flutter/widgets/participant_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

class ModeratorMenuView extends StatefulWidget {
  const ModeratorMenuView({super.key, this.onUpdateParentUI});
  static ValueNotifier<bool> showModeratorMessage = ValueNotifier(false);
  final VoidCallback? onUpdateParentUI;

  @override
  State createState() => _ModeratorMenuViewState();
}

class _ModeratorMenuViewState extends State<ModeratorMenuView> {

  @override
  Widget build(BuildContext context) {
    print('zz _ModeratorMenuViewState build');
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    MirrorStateProvider mirrorStateProvider = Provider.of<MirrorStateProvider>(context);
    return MenuDialog(
      backgroundColor: channelProvider.isPresenting()
          ? AppColors.primary_grey_tran
          : AppColors.primary_grey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
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
                        AppAnalytics().trackEventModeratorPanelClose();
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
                          S.of(context).moderator_presentersList,
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
                        image: Svg(ChannelProvider.isModeratorMode == false
                            ? 'assets/images/ic_moderator_split_screen_off.svg'
                            : SplitScreen
                            .mapSplitScreen.value[keySplitScreenEnable]
                            ? 'assets/images/ic_moderator_split_screen_activate.svg'
                            : 'assets/images/ic_moderator_split_screen_on.svg'),
                      ),
                      splashRadius: 20,
                      focusColor: Colors.grey,
                      onClick: ChannelProvider.isModeratorMode == true
                          ? () {
                        _callSplitScreenDialog();
                      }
                          : null,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.fitHeight,
                    child: FocusIconButton(
                      childNotFocus: Image(
                        image: Svg(ChannelProvider.isModeratorMode == true
                            ? 'assets/images/ic_activate_on.svg'
                            : 'assets/images/ic_activate_off.svg'),
                      ),
                      splashRadius: 20,
                      focusColor: Colors.grey,
                      onClick: () {
                        ChannelProvider.isModeratorMode = !ChannelProvider.isModeratorMode;
                        if (!ChannelProvider.isModeratorMode) {
                          _callLogOutDialog();
                        } else {
                          mirrorStateProvider.pauseMirror();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Column(
              children: [
                Expanded(
                  child: ParticipantListView(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _callSplitScreenDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: '',
          description: SplitScreen.mapSplitScreen.value[keySplitScreenEnable]
              ? S.of(context).moderator_deactivate_split_screen
              : S.of(context).moderator_activate_split_screen,
          positiveButton: S.of(context).moderator_confirm,
          onPositive: () {
            _switchSplitScreenOnOff();
          },
          onNegative: () {},
        );
      },
    );
  }

  void _callLogOutDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        MirrorStateProvider mirrorStateProvider = Provider.of<MirrorStateProvider>(context);
        return CustomAlertDialog(
          title: '',
          description: S.of(context).moderator_exit_dialog,
          positiveButton: S.of(context).moderator_exit,
          onPositive: () {
            AppAnalytics().trackEventModeratorOff();
            _switchModeratorOff();
            widget.onUpdateParentUI?.call();
            setState(() {});
            mirrorStateProvider.resumeMirror();
          },
          onNegative: () {},
        );
      },
    );
  }

  _switchModeratorOff() {
    context.read<ChannelProvider>().removeAllPresenters();
    // Provider.of<ChannelProvider>(context).removeAllPresenters();
    SplitScreen.mapSplitScreen.value[keySplitScreenEnable] = false;
    SplitScreen.mapSplitScreen.value[keySplitScreenCount] = 0;
    SplitScreen.mapSplitScreen.value =
        Map.from(SplitScreen.mapSplitScreen.value);
  }

  _switchSplitScreenOnOff() async {
    if (!SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      AppAnalytics().trackEventModeratorSplitScreenOn();
    } else {
      AppAnalytics().trackEventModeratorSplitScreenOff();
      // check whether the presenters are playing
      context.read<ChannelProvider>().removeOtherPresenters(keepInList: ChannelProvider.isModeratorMode);
    }
    // Need remove all presenters first, due to enable/disable will dispose
    // view and will disconnectedP2pClient before send stopVideo
    // cause web presenter did not update status
    SplitScreen.mapSplitScreen.value[keySplitScreenEnable] =
    !SplitScreen.mapSplitScreen.value[keySplitScreenEnable];
    // Using below method to trigger value changed.
    // https://github.com/flutter/flutter/issues/29958
    SplitScreen.mapSplitScreen.value =
        Map.from(SplitScreen.mapSplitScreen.value);
    widget.onUpdateParentUI?.call();
    setState(() {});
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
