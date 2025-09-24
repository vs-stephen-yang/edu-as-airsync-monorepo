import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/screens/v3_quick_connect_menu.dart';
import 'package:display_flutter/screens/v3_shortcuts_menu.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_settings_password_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import 'focus_aware_builder.dart';

class ExpandableWidget extends StatefulWidget {
  const ExpandableWidget({super.key});

  @override
  State<ExpandableWidget> createState() => _ExpandableWidgetState();
}

class _ExpandableWidgetState extends State<ExpandableWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;

  bool isExpanded = false;
  bool isAnimating = false;
  bool _showQuickConnect = false;
  bool _showShortcut = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // single icon row is -> 45, three icon row is -> 45x3 + Gap(8)x2 = 151
    _widthAnimation = Tween<double>(begin: 45.0, end: 151.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _widthAnimation.addStatusListener((AnimationStatus status) {
      isAnimating = status.isAnimating;
    });
  }

  void _toggle() {
    if (isAnimating) return;
    if (isExpanded) {
      _controller.reverse();
    } else {
      _controller.forward();
    }

    if (!mounted) {
      return;
    }
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isInMultiWindow &&
        context.splitScreenRatio.widthFraction <=
                SplitScreenRatio.floatingDefault.widthFraction ||
        context.splitScreenRatio.heightFraction <
            SplitScreenRatio.oneThirdFull.heightFraction;

    if (isCompact) return SizedBox.shrink();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipRect(
          child: SizedBox(
            width: _widthAnimation.value,
            height: 60.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                V3Focus(
                  label: isExpanded
                      ? S.of(context).v3_lbl_streaming_shortcut_minimize
                      : S.of(context).v3_lbl_streaming_shortcut_expand,
                  identifier: isExpanded
                      ? 'v3_qa_streaming_shortcut_minimize'
                      : 'v3_qa_streaming_shortcut_expand',
                  child: Container(
                    width: 41,
                    height: 41,
                    padding: EdgeInsets.zero,
                    decoration: ShapeDecoration(
                      color: context.tokens.color.vsdslColorSurface800,
                      shape: const OvalBorder(),
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        isExpanded
                            ? 'assets/images/ic_streaming_shortcut_minimize.svg'
                            : 'assets/images/ic_streaming_shortcut_expanded.svg',
                      ),
                      focusColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _toggle();
                      },
                    ),
                  ),
                ),
                if (isExpanded) ...[
                  const Gap(8),
                  Consumer<SettingsProvider>(
                      builder: (_, settingsProvider, __) {
                    final lock = settingsProvider.isSettingsLock;
                    return V3Focus(
                      label: lock
                          ? S.of(context).v3_lbl_streaming_shortcut_menu_locked
                          : S.of(context).v3_lbl_open_streaming_shortcut_menu,
                      identifier: lock
                          ? 'v3_qa_streaming_shortcut_menu_locked'
                          : 'v3_qa_open_streaming_shortcut_menu',
                      child: Container(
                        width: 41,
                        height: 41,
                        decoration: ShapeDecoration(
                          color: _showShortcut
                              ? context.tokens.color.vsdslColorSurface900
                              : context.tokens.color.vsdslColorSurface800,
                          shape: const OvalBorder(),
                        ),
                        child: IconButton(
                          icon: SvgPicture.asset(
                            lock
                                ? 'assets/images/ic_streaming_shortcut_locked.svg'
                                : 'assets/images/ic_streaming_shortcut.svg',
                            colorFilter: _showShortcut
                                ? ColorFilter.mode(
                                    context.tokens.color
                                        .vsdslColorOnSurfaceVariant,
                                    BlendMode.srcIn,
                                  )
                                : null,
                          ),
                          focusColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _showShortcutsMenuDialog(
                                  context, settingsProvider);
                            });
                            if (!mounted) return;
                            setState(() {
                              _showShortcut = true;
                            });
                          },
                        ),
                      ),
                    );
                  }),
                  const Gap(8),
                  V3Focus(
                    label: S.of(context).v3_lbl_open_streaming_qrcode_menu,
                    identifier: 'v3_qa_open_streaming_qrcode_menu',
                    child: Container(
                      width: 41,
                      height: 41,
                      decoration: ShapeDecoration(
                        color: _showQuickConnect
                            ? context.tokens.color.vsdslColorSurface900
                            : context.tokens.color.vsdslColorSurface800,
                        shape: const OvalBorder(),
                      ),
                      child: IconButton(
                        icon: SvgPicture.asset(
                          'assets/images/ic_streaming_qrcode.svg',
                          colorFilter: _showQuickConnect
                              ? ColorFilter.mode(
                                  context
                                      .tokens.color.vsdslColorOnSurfaceVariant,
                                  BlendMode.srcIn,
                                )
                              : null,
                        ),
                        focusColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showQuickConnectMenuDialog();
                          });
                          if (!mounted) return;
                          setState(() {
                            _showQuickConnect = true;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  _showShortcutsMenuDialog(
      BuildContext context, SettingsProvider settingsProvider) async {
    bool isShortcutsMenuUnLocked = true;

    if (settingsProvider.isSettingsLock) {
      await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return const V3SettingsPasswordDialog();
          }).then((value) {
        isShortcutsMenuUnLocked = value;
      });
    }

    if (!(isShortcutsMenuUnLocked && context.mounted)) return;

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) => FocusAwareBuilder(
          builder: (primaryFocusNode) =>
              V3ShortcutsMenu(primaryFocusNode: primaryFocusNode)),
    ).then((_) {
      if (!mounted) return;
      setState(() {
        _showShortcut = false;
      });
    });
  }

  _showQuickConnectMenuDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) => FocusAwareBuilder(
        builder: (primaryFocusNode) =>
            V3QuickConnectMenu(primaryFocusNode: primaryFocusNode),
      ),
    ).then((_) {
      if (!mounted) return;
      setState(() {
        _showQuickConnect = false;
      });
    });
  }
}
