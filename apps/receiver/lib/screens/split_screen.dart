import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class SplitScreen extends StatefulWidget {
  const SplitScreen({Key? key}) : super(key: key);
  static ValueNotifier<bool> splitScreenEnabled = ValueNotifier(false);

  @override
  State createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

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
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: AppColors.primary_grey,
        //TODO: the color is AppColors.primary_grey_tran during presenting
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.06,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            color: Colors.transparent,
            child: Row(
              children: [
                FittedBox(
                  fit: BoxFit.fitHeight,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppColors.primary_white),
                    onPressed: () {
                      if (SplitScreen.splitScreenEnabled.value && ControlSocket().isPresenting()) {
                        StreamFunction.showStreamMenu.value = true;
                      }
                      StreamFunction.showSplitScreen.value = false;
                    },
                  ),
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: const Text(
                        "Split Screen",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary_white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Visibility(
                    visible: SplitScreen.splitScreenEnabled.value,
                    child: RotationTransition(
                      turns: _animation,
                      child: const Image(
                        image: Svg(
                          'assets/images/ic_loading.svg',
                          size: Size.square(32),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    SplitScreen.splitScreenEnabled.value
                        ? '“Waiting for a sender a screen...”'
                        : 'Would you like to turn on the split screen feature?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  SplitScreen.splitScreenEnabled.value =
                      !SplitScreen.splitScreenEnabled.value;
                  streamFunctionKey.currentState?.setState(() {});
                });
              },
              child: Text(
                SplitScreen.splitScreenEnabled.value
                    ? 'Deactivate'
                    : 'Activate',
                style: const TextStyle(
                  color: AppColors.neutral1,
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  return Colors.white;
                }),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
