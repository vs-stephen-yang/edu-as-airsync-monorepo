import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

const String keySplitScreenEnable = 'enable';
const String keySplitScreenCount = 'count';
const String keySplitScreenLastId = 'lastId';

class SplitScreen extends StatefulWidget {
  const SplitScreen({Key? key}) : super(key: key);
  static ValueNotifier<Map<String, dynamic>> mapSplitScreen =
      ValueNotifier({keySplitScreenEnable: false, keySplitScreenCount: 0});

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
    String path = 'assets/images/ic_activate_off.svg';
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      path = 'assets/images/ic_activate_on.svg';
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: ControlSocket().isPresenting()
            ? AppColors.primary_grey_tran
            : AppColors.primary_grey,
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
                      if (SplitScreen
                              .mapSplitScreen.value[keySplitScreenEnable] &&
                          ControlSocket().isPresenting()) {
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
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerRight,
                    fit: BoxFit.fitHeight,
                    child: IconButton(
                      icon: Image(image: Svg(path)),
                      onPressed: () {
                        setState(() {
                          SplitScreen
                                  .mapSplitScreen.value[keySplitScreenEnable] =
                              !SplitScreen
                                  .mapSplitScreen.value[keySplitScreenEnable];
                          // Using below method to trigger value changed. https://github.com/flutter/flutter/issues/29958
                          SplitScreen.mapSplitScreen.value =
                              Map.from(SplitScreen.mapSplitScreen.value);
                          streamFunctionKey.currentState?.setState(() {});
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.2,
                  horizontal: 30),
              child: Column(
                children: <Widget>[
                  Visibility(
                    visible:
                        SplitScreen.mapSplitScreen.value[keySplitScreenEnable],
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
                    SplitScreen.mapSplitScreen.value[keySplitScreenEnable]
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
        ],
      ),
    );
  }
}
