import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class V3NewSharingMenu extends StatefulWidget {
  const V3NewSharingMenu({super.key, required this.name});

  final String name;

  @override
  State<StatefulWidget> createState() => _V3NewSharingMenuState();
}

class _V3NewSharingMenuState extends State<V3NewSharingMenu> {
  double _progress = 1.0;
  Timer? _timer;
  final int _duration = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 54,
          bottom: 54,
          child: UnconstrainedBox(
            // Use UnconstrainedBox to override Dialog minimum size
            // https://blog.csdn.net/shving/article/details/114485776
            constrainedAxis: Axis.vertical,
            child: SizedBox(
              width: 207,
              height: 87,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                insetPadding: EdgeInsets.zero,
                backgroundColor: const Color(0xFF20273E),
                child: Stack(
                  children: [
                    const Positioned(
                      left: 0,
                      top: 16,
                      right: 0,
                      child: SizedBox(
                        width: 27,
                        height: 27,
                        child: Image(
                          image: Svg('assets/images/ic_new_sharing_user.svg'),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 51,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText(
                            widget.name,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          AutoSizeText(
                            S.of(context).v3_new_sharing_join_session,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: SizedBox(
                        width: 27,
                        height: 27,
                        child: IconButton(
                          icon: const Image(
                            image:
                                Svg('assets/images/ic_new_sharing_close.svg'),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            if (navService.canPop()) {
                              navService.goBack();
                            }
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 5,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF3AC9CC),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _startCountdown() {
    int elapsedTime = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        elapsedTime++;
        _progress = 1.0 - (elapsedTime / _duration);

        if (elapsedTime >= _duration) {
          _timer?.cancel();
          if (navService.canPop()) {
            navService.goBack();
          }
        }
      });
    });
  }
}
