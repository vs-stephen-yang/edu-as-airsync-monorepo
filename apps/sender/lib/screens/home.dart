import 'package:display_cast_flutter/widgets/bottom_bar.dart';
import 'package:display_cast_flutter/widgets/title_bar.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          ],
        ),
      ),
    );
  }
}
