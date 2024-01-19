import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/model/rtc_connector_list.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/custom_icons_icons.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

const String keySplitScreenEnable = 'enable';
const String keySplitScreenCount = 'count';
const String keySplitScreenLastId = 'lastId';

class SplitScreen extends StatefulWidget {
  const SplitScreen({super.key, this.onUpdateParentUI});

  static ValueNotifier<Map<String, dynamic>> mapSplitScreen =
      ValueNotifier({keySplitScreenEnable: true, keySplitScreenCount: 0});
  final VoidCallback? onUpdateParentUI;

  @override
  State createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late ChannelProvider channelProvider;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: false);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    channelProvider = Provider.of<ChannelProvider>(context);
    return MenuDialog(
      backgroundColor: RtcConnectorList.getInstance().isPresenting()
          ? AppColors.primary_grey_tran
          : AppColors.primary_grey,
      topTitleText: S.of(context).main_split_screen_title,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Visibility(
            visible: SplitScreen.mapSplitScreen.value[keySplitScreenEnable],
            child: Wrap(
              direction: Axis.vertical,
              children: [
                RotationTransition(
                  turns: _animation,
                  child: const Icon(
                    CustomIcons.loading,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          Text(
            SplitScreen.mapSplitScreen.value[keySplitScreenEnable]
                ? S.of(context).main_split_screen_waiting
                : S.of(context).main_split_screen_question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  _switchSplitScreenOnOff() async {
    if (!SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      AppAnalytics().setEventProperties(meetingId: const Uuid().v4());
      AppAnalytics().trackEventSplitScreenOn();
      ConnectionTimer.getInstance().startRemainingTimeTimer(() async {
        AppAnalytics().setEventProperties(meetingId: '');

        await RtcConnectorList.getInstance().removeAllPresenters();
        // Need remove all presenters first, due to enable/disable will dispose
        // view and will disconnectedP2pClient before send stopVideo
        // cause web presenter did not update status
        SplitScreen.mapSplitScreen.value[keySplitScreenEnable] = false;
        // Using below method to trigger value changed.
        // https://github.com/flutter/flutter/issues/29958
        SplitScreen.mapSplitScreen.value =
            Map.from(SplitScreen.mapSplitScreen.value);
        widget.onUpdateParentUI?.call();
        setState(() {});
      });
    } else {
      AppAnalytics().trackEventSplitScreenOff();
      ConnectionTimer.getInstance().stopRemainingTimeTimer();
      AppAnalytics().setEventProperties(meetingId: '');
      await RtcConnectorList.getInstance().removeAllPresenters();
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
}
