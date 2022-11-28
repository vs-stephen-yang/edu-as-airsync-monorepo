import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/model/display_info.dart';
import 'package:display_flutter/model/moderator_socket.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/widgets/custom_alert_dialog.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:display_flutter/widgets/presenter_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class ModeratorView extends StatefulWidget {
  const ModeratorView({Key? key, this.onUpdateParentUI}) : super(key: key);
  static ValueNotifier<bool> showModeratorMessage = ValueNotifier(false);
  final VoidCallback? onUpdateParentUI;

  @override
  State createState() => _ModeratorViewState();

  void logout() async {
    // remove all presenter
    await ControlSocket().removeAllPresenters();
    // Need remove all presenters first, due to enable/disable will dispose
    // view and will disconnectedP2pClient before send stopVideo
    // cause web presenter did not update status
    SplitScreen.mapSplitScreen.value[keySplitScreenEnable] = false;
    SplitScreen.mapSplitScreen.value[keySplitScreenCount] = 0;
    // Using below method to trigger value changed.
    // https://github.com/flutter/flutter/issues/29958
    SplitScreen.mapSplitScreen.value =
        Map.from(SplitScreen.mapSplitScreen.value);

    ControlSocket().moderator = null;
    onUpdateParentUI?.call();
    moderatorSocket.unBindFromDisplay(
        ControlSocket().displayCode, ControlSocket().token);
    moderatorSocket.disconnect();
    DisplayInfo().removeBindToDisplayInfo();
    AppPreferences().set(moderatorId: '');
    navService.popUntil('/home');
  }
}

class _ModeratorViewState extends State<ModeratorView> {
  bool _isLogInClicked = false;

  @override
  Widget build(BuildContext context) {
    return MenuDialog(
      backgroundColor: ControlSocket().isPresenting()
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
                        image: Svg(DisplayInfo().isBound == false
                            ? 'assets/images/ic_moderator_split_screen_off.svg'
                            : SplitScreen
                                    .mapSplitScreen.value[keySplitScreenEnable]
                                ? 'assets/images/ic_moderator_split_screen_activate.svg'
                                : 'assets/images/ic_moderator_split_screen_on.svg'),
                      ),
                      splashRadius: 20,
                      focusColor: Colors.grey,
                      onClick: DisplayInfo().isBound == true
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
                        image: Svg(DisplayInfo().isBound == true
                            ? 'assets/images/ic_activate_on.svg'
                            : 'assets/images/ic_activate_off.svg'),
                      ),
                      splashRadius: 20,
                      focusColor: Colors.grey,
                      onClick: () {
                        if (!_isLogInClicked) {
                          _isLogInClicked = true;
                          if (DisplayInfo().isBound == false) {
                            verifyCode().then((value) {
                              _isLogInClicked = false;
                              WidgetsBinding.instance
                                  ?.addPostFrameCallback((timeStamp) {
                                setState(() {});
                              });
                            });
                          } else {
                            _callLogOutDialog();
                            _isLogInClicked = false;
                          }
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
                  child: PresenterList(onUnSetLogOut: () {
                    widget.logout();
                    setState(() {});
                  }),
                ),
                ValueListenableBuilder(
                  valueListenable: ModeratorView.showModeratorMessage,
                  builder: (BuildContext context, bool value, Widget? child) {
                    return Visibility(
                      visible: value,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15)),
                          color: AppColors.semantic2,
                        ),
                        child: Row(
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child:
                                  Icon(Icons.info_outline, color: Colors.white),
                            ),
                            Text(S.of(context).moderator_verifyCode_fail),
                          ],
                        ),
                      ),
                    );
                  },
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
        return CustomAlertDialog(
          title: '',
          description: S.of(context).moderator_exit_dialog,
          positiveButton: S.of(context).moderator_exit,
          onPositive: () {
            AppAnalytics().trackEventModeratorOff();
            widget.logout();
            setState(() {});
          },
          onNegative: () {},
        );
      },
    );
  }

  Future<bool> verifyCode() async {
    var moderator = moderatorSocket.createModerator('Guest', '');
    AppPreferences().set(moderatorId: moderator.id);
    moderatorSocket.connectAndListen(context);
    try {
      await moderatorSocket
          .bindToDisplay(ControlSocket().displayCode, ControlSocket().otpCode,
              ControlSocket().token)
          .then((value) {
        AppAnalytics().trackEventModeratorOn();
        widget.onUpdateParentUI?.call();
      }).catchError((dynamic e) {
        Future.delayed(const Duration(seconds: 5), () {
          ModeratorView.showModeratorMessage.value = false;
        });
        ModeratorView.showModeratorMessage.value = true;
      });
    } catch (e) {
      return Future.value(false);
    }
    return Future.value(true);
  }

  _switchSplitScreenOnOff() async {
    if (!SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      AppAnalytics().trackEventModeratorSplitScreenOn();
    } else {
      AppAnalytics().trackEventModeratorSplitScreenOff();
      // check whether the presenters are playing
      await ControlSocket().removeAllPresenters();
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
