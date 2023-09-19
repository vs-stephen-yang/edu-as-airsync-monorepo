import 'package:display_flutter/widgets/custom_icons_icons.dart';
import 'package:flutter/material.dart';

class LoadingIcon extends StatefulWidget {
  const LoadingIcon({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LoadingIconState();
}

class LoadingIconState extends State<LoadingIcon>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: false);
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();// MUST before super.dispose!!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: const Icon(
        CustomIcons.loading,
        color: Colors.white,
      ),
    );
  }
}
