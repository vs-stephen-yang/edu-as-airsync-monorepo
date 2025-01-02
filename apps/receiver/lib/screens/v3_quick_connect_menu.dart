import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_instruction.dart';
import 'package:display_flutter/widgets/v3_qrcode_quick_connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class V3QuickConnectMenu extends StatefulWidget {
  const V3QuickConnectMenu({super.key});

  @override
  _V3QuickConnectMenuState createState() => _V3QuickConnectMenuState();
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
          bottom: 53,
          child: Dialog(
            backgroundColor: context.tokens.color.vsdslColorSurface100,
            insetPadding: EdgeInsets.zero,
            elevation: 16.0,
            shadowColor: context.tokens.color.vsdslColorOpacityNeutralSm,
            child: SizedBox(
              width: 512,
              height: 507,
              child: DefaultTabController(
                length: 2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 13,
                      top: 27,
                      right: 13,
                      child: Container(
                        width: 485,
                        height: 37,
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
                                onKey: (node, event) {
                                  if (event.logicalKey ==
                                      LogicalKeyboardKey.enter) {
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
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          context.tokens.radii.vsdslRadiusLg,
                                      border: Border.all(
                                        color: _focusNodes[index].hasFocus
                                            ? context
                                                .tokens.color.vsdslColorPrimary
                                            : Colors.transparent,
                                        width: 2.0,
                                      ),
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
                                            : context
                                                .tokens.color.vsdslColorPrimary,
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
                      top: 117,
                      height: 340,
                      width: 485,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            selected = index;
                            FocusScope.of(context)
                                .requestFocus(_focusNodes[index]);
                          });
                        },
                        children: const [
                          V3Instruction(isQuickConnect: true),
                          V3QrCodeQuickConnect(isStringOnTop: true, size: 195),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 13,
                      bottom: 13,
                      child: V3Focus(
                        child: SizedBox(
                          width: 33,
                          height: 33,
                          child: IconButton(
                            icon: const Image(
                              image: Svg('assets/images/ic_menu_minimal.svg'),
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
