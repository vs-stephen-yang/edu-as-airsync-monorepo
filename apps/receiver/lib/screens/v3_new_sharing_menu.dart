import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
              width: 242,
              height: 95,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: context.tokens.radii.vsdslRadiusLg,
                ),
                insetPadding: EdgeInsets.zero,
                backgroundColor: context.tokens.color.vsdslColorSurface800,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 16,
                      right: 0,
                      child: SvgPicture.asset(
                        'assets/images/ic_new_sharing_user.svg',
                        excludeFromSemantics: true,
                        width: 27,
                        height: 27,
                      ),
                    ),
                    Positioned(
                      left: 13,
                      top: 51,
                      right: 13,
                      bottom: 20,
                      child: AutoSizeText.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: widget.name,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: context
                                    .tokens.color.vsdslColorOnSurfaceInverse,
                              ),
                            ),
                            TextSpan(
                              text: S.of(context).v3_new_sharing_join_session,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w400,
                                color: context
                                    .tokens.color.vsdslColorOnSurfaceInverse,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        minFontSize: 8,
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: V3Focus(
                        child: SizedBox(
                          width: 27,
                          height: 27,
                          child: IconButton(
                            icon: SvgPicture.asset(
                              'assets/images/ic_new_sharing_close.svg',
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.tokens.color.vsdslColorSuccess,
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
      if (!mounted) {
        return;
      }
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

/// V3NewSharingMenuContent - 用於 NotificationCenter 的版本
///
/// 移除了 Stack 和 Positioned，只保留通知內容
/// 定位由 V3NotificationCenter 統一管理
class V3NewSharingMenuContent extends StatefulWidget {
  const V3NewSharingMenuContent({
    super.key,
    required this.name,
    this.onDismiss,
    this.onTimeout,
  });

  final String name;
  final VoidCallback? onDismiss;
  final VoidCallback? onTimeout;

  @override
  State<StatefulWidget> createState() => _V3NewSharingMenuContentState();
}

class _V3NewSharingMenuContentState extends State<V3NewSharingMenuContent> {
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
    // 🐛 調試輸出：確認 widget 正在渲染
    log.fine(
        'V3NewSharingMenuContent: 正在渲染通知，用戶名 = ${widget.name}, 進度 = $_progress');

    // 使用 Material 替代 Dialog，因為 Dialog 需要透過 showDialog() 顯示
    // 這裡我們需要一個可以直接作為 child 的 widget
    return SizedBox(
      width: 242,
      height: 95,
      child: Material(
        type: MaterialType.card,
        elevation: 24,
        // Dialog 的預設 elevation
        shadowColor: Colors.black,
        borderRadius: context.tokens.radii.vsdslRadiusLg,
        color: context.tokens.color.vsdslColorSurface800,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 16,
              right: 0,
              child: SvgPicture.asset(
                'assets/images/ic_new_sharing_user.svg',
                excludeFromSemantics: true,
                width: 27,
                height: 27,
              ),
            ),
            Positioned(
              left: 13,
              top: 51,
              right: 13,
              bottom: 20,
              child: AutoSizeText.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: widget.name,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: context.tokens.color.vsdslColorOnSurfaceInverse,
                      ),
                    ),
                    TextSpan(
                      text: S.of(context).v3_new_sharing_join_session,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: context.tokens.color.vsdslColorOnSurfaceInverse,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                minFontSize: 8,
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: V3Focus(
                child: SizedBox(
                  width: 27,
                  height: 27,
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/images/ic_new_sharing_close.svg',
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      widget.onDismiss?.call();
                    },
                  ),
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
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.tokens.color.vsdslColorSuccess,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startCountdown() {
    int elapsedTime = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        return;
      }
      setState(() {
        elapsedTime++;
        _progress = 1.0 - (elapsedTime / _duration);

        if (elapsedTime >= _duration) {
          _timer?.cancel();
          widget.onTimeout?.call();
        }
      });
    });
  }
}
