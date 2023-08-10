import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_colors.dart';
import 'package:display_cast_flutter/utilities/debug_mode_print.dart';
import 'package:display_cast_flutter/widgets/bottom_bar.dart';
import 'package:display_cast_flutter/widgets/language.dart';
import 'package:display_cast_flutter/widgets/moderator_idle.dart';
import 'package:display_cast_flutter/widgets/moderator_present_start.dart';
import 'package:display_cast_flutter/widgets/moderator_wait.dart';
import 'package:display_cast_flutter/widgets/present_idle.dart';
import 'package:display_cast_flutter/widgets/present_present_start.dart';
import 'package:display_cast_flutter/widgets/present_select_screen.dart';
import 'package:display_cast_flutter/widgets/present_wait_ready.dart';
import 'package:display_cast_flutter/widgets/settings.dart';
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
          child: Container(
            decoration: const BoxDecoration(
                gradient: RadialGradient(
                    center: Alignment(0, -0.7),
                    radius: 1,
                    colors: [
                      AppColors.homeBackground,
                      Colors.black,
                    ])),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BottomBar(),
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
                      case ViewState.waitReady:
                        return const PresentWaitReady();
                      case ViewState.selectScreen:
                        return const PresentSelectScreen();
                      case ViewState.presentStart:
                        return PresentPresentStart();
                      case ViewState.moderatorStart:
                        return ModeratorPresentStart();
                      case ViewState.settings:
                        return const Settings();
                      case ViewState.language:
                        return const Language();
                      default:
                        return const SizedBox();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
