import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/custom_icons_icons.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const String keySplitScreenCount = 'count';
const String keySplitScreenLastId = 'lastId';

class SplitScreen extends StatefulWidget {
  const SplitScreen({super.key, this.onUpdateParentUI});

  static ValueNotifier<Map<String, dynamic>> mapSplitScreen =
      ValueNotifier({keySplitScreenCount: 0});
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
      backgroundColor: HybridConnectionList().isPresenting()
          ? AppColors.primary_grey_tran
          : AppColors.primary_grey,
      topTitleText: S.of(context).main_split_screen_title,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Wrap(
            direction: Axis.vertical,
            children: [
              RotationTransition(
                turns: _animation,
                child: const Icon(CustomIcons.loading),
              ),
              const SizedBox(height: 32),
            ],
          ),
          Text(
            S.of(context).main_split_screen_waiting,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
