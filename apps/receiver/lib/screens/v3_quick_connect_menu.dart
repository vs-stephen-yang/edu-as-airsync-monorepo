import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_instruction.dart';
import 'package:display_flutter/widgets/v3_qrcode_quick_connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

class V3QuickConnectMenu extends StatefulWidget {
  const V3QuickConnectMenu({
    super.key,
    required this.primaryFocusNode,
  });

  final FocusNode primaryFocusNode;

  @override
  State<V3QuickConnectMenu> createState() => _V3QuickConnectMenuState();
}

class _V3QuickConnectMenuState extends State<V3QuickConnectMenu> {
  final List<FocusNode> _focusNodes = List.generate(2, (_) => FocusNode());
  int selected = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selected);
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 55,
          child: Dialog(
            backgroundColor: context.tokens.color.vsdslColorSurface100,
            insetPadding: EdgeInsets.zero,
            elevation: 16.0,
            shadowColor: context.tokens.color.vsdslColorOpacityNeutralSm,
            child: SizedBox(
              width: 512,
              height: 555,
              child: DefaultTabController(
                length: 2,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: context.tokens.color.vsdslColorOutline,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        S.current.v3_instruction_share_screen,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.tokens.color.vsdslColorOnSurface,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 72,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/images/ic_screen.svg',
                            excludeFromSemantics: true,
                            width: 27,
                            height: 27,
                            colorFilter: ColorFilter.mode(
                              context.tokens.color.vsdslColorSurface600,
                              BlendMode.srcIn,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(
                                context.tokens.spacing.vsdslSpacingSm.left),
                            child: Consumer<InstanceInfoProvider>(
                              builder: (_, instanceInfoProvider, __) {
                                return AutoSizeText(
                                  instanceInfoProvider.deviceName,
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: context
                                        .tokens.color.vsdslColorOnSurfaceVariant,
                                    letterSpacing: -0.48,
                                  ),
                                );
                              },
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable:
                                AppPreferences().connectivityTypeNotifier,
                            builder: (context, connectivityType, child) {
                              if (AppPreferences().connectivityType ==
                                  ConnectivityType.local.name) {
                                return Container(
                                  decoration: ShapeDecoration(
                                    color: context
                                        .tokens.color.vsdslColorSurface200,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: context
                                          .tokens.spacing.vsdslSpacingXl.left,
                                      vertical: context
                                          .tokens.spacing.vsdslSpacingSm.top),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/ic_local_connection_only.svg',
                                        width: 21,
                                        height: 21,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: context.tokens.spacing
                                                .vsdslSpacingSm.left),
                                        child: AutoSizeText(
                                          S
                                              .of(context)
                                              .v3_settings_local_connection_only,
                                          style: context.tokens.textStyle
                                              .airsyncFontSubtitle600
                                              .apply(
                                            color: context.tokens.color
                                                .vsdslColorSurface600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return const SizedBox();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 13,
                      top: 117,
                      right: 13,
                      child: Container(
                        width: 485,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: context.tokens.radii.vsdslRadiusLg,
                          color: context.tokens.color.vsdslColorSurface200,
                        ),
                        child: Row(
                          children: List.generate(_focusNodes.length, (index) {
                            return Expanded(
                              child: Focus(
                                focusNode: _focusNodes[index],
                                onFocusChange: (hasFocus) {
                                  if (hasFocus) {
                                    _focusNodes[index].requestFocus();
                                    setState(() {});
                                  } else {
                                    _focusNodes[index].unfocus();
                                    setState(() {});
                                  }
                                },
                                onKeyEvent: (node, event) {
                                  if (event.logicalKey ==
                                          LogicalKeyboardKey.enter ||
                                      event.logicalKey ==
                                          LogicalKeyboardKey.select) {
                                    setState(() {
                                      selected = index;
                                    });
                                    _pageController.animateToPage(
                                      index,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.ease,
                                    );
                                    return KeyEventResult.handled;
                                  }
                                  return KeyEventResult.ignored;
                                },
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selected = index;
                                    });
                                    _pageController.animateToPage(
                                      index,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.ease,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          context.tokens.radii.vsdslRadiusXs,
                                      border: Border.all(
                                        color: _focusNodes[index].hasFocus
                                            ? context.tokens.color
                                                .vsdslColorSecondary
                                            : Colors.transparent,
                                        width: _focusNodes[index].hasFocus
                                            ? 2.0
                                            : 0,
                                      ),
                                      color: Colors.transparent,
                                    ),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            context.tokens.radii.vsdslRadiusLg,
                                        color: selected == index
                                            ? context
                                                .tokens.color.vsdslColorPrimary
                                            : Colors.transparent,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        index == 0
                                            ? S
                                                .of(context)
                                                .v3_quick_connect_menu_display_code
                                            : S
                                                .of(context)
                                                .v3_quick_connect_menu_qrcode,
                                        style: TextStyle(
                                          color: selected == index
                                              ? context.tokens.color
                                                  .vsdslColorOnSurfaceInverse
                                              : context.tokens.color
                                                  .vsdslColorPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 154,
                      child: Container(
                        alignment: Alignment.center,
                        height: 340,
                        width: 485,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              selected = index;
                              final bool openedWithLogicalKey = HardwareKeyboard
                                  .instance.logicalKeysPressed.isNotEmpty;
                              if (openedWithLogicalKey) {
                                FocusScope.of(context)
                                    .requestFocus(_focusNodes[index]);
                              }
                            });
                          },
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: V3Instruction(isQuickConnect: true),
                            ),
                            V3QrCodeQuickConnect(
                                isStringOnTop: true, size: 195),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 494,
                      child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/images/ic_split_screen_quick_menu.svg',
                                excludeFromSemantics: true,
                                width: 21,
                                height: 21,
                              ),
                              const Gap(3),
                              Text(
                                S.current.v3_quick_connect_menu_bottom_msg,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: context.tokens.color.vsdslColorOnSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          )),
                    ),
                    Positioned(
                      right: 13,
                      bottom: 13,
                      child: V3Focus(
                        label:
                            S.of(context).v3_lbl_minimal_streaming_qrcode_menu,
                        identifier: 'v3_qa_minimal_streaming_qrcode_menu',
                        child: SizedBox(
                          width: 33,
                          height: 33,
                          child: IconButton(
                            focusNode: widget.primaryFocusNode,
                            icon: SvgPicture.asset(
                              'assets/images/ic_menu_close_gray.svg',
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
