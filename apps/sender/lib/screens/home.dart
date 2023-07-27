import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/debug_mode_print.dart';
import 'package:display_cast_flutter/widgets/bottom_bar.dart';
import 'package:display_cast_flutter/widgets/moderator_idle.dart';
import 'package:display_cast_flutter/widgets/moderator_present_start.dart';
import 'package:display_cast_flutter/widgets/moderator_wait.dart';
import 'package:display_cast_flutter/widgets/present_idle.dart';
import 'package:display_cast_flutter/widgets/present_present_start.dart';
import 'package:display_cast_flutter/widgets/present_select_screen.dart';
import 'package:display_cast_flutter/widgets/title_bar.dart';
import 'package:display_cast_flutter/widgets/tool_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: PresentStateProvider(context)),
      ],
      child: Scaffold(
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(
                left: 0,
                top: 0,
                right: 0,
                child: TitleBar(),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomBar(),
              ),
              const Positioned(
                left: 0,
                top: 0,
                bottom: 80,
                child: ToolBar(),
              ),
              Consumer<PresentStateProvider>(
                builder: (context, provider, child) {
                  debugModePrint('PresentState: ${provider.state}');
                  switch (provider.state) {
                    case ViewState.idle:
                      return PresentIdle();
                    case ViewState.moderatorIdle:
                      return ModeratorIdle(displayCode: provider.displayCode, otp: provider.otp);
                    case ViewState.moderatorWait:
                      return const ModeratorWait();
                    case ViewState.selectScreen:
                      return const PresentSelectScreen();
                    case ViewState.presentStart:
                      return PresentPresentStart();
                    case ViewState.moderatorStart:
                      return ModeratorPresentStart();
                    default:
                      return const SizedBox();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
