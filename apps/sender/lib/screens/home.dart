import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/widgets/bottom_bar.dart';
import 'package:display_cast_flutter/widgets/present_idle.dart';
import 'package:display_cast_flutter/widgets/present_present_start.dart';
import 'package:display_cast_flutter/widgets/present_wait_ready.dart';
import 'package:display_cast_flutter/widgets/title_bar.dart';
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
              Consumer<PresentStateProvider>(
                builder: (context, provider, child) {
                  print('PresentState: ${provider.state}');
                  switch (provider.state) {
                    case ViewState.idle:
                      return PresentIdle();
                    case ViewState.waitReady:
                      return PresentWaitReady();
                    case ViewState.selectScreen:
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Select Screen',
                            style: TextStyle(color: Colors.white),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  provider.presentStop();
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  provider.presentStart();
                                },
                                child: const Text('Share'),
                              ),
                            ],
                          )
                        ],
                      );
                    case ViewState.presentStart:
                      return PresentPresentStart();
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
