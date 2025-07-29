import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_instruction.dart';
import 'package:display_flutter/widgets/v3_qrcode_quick_connect.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

class V3QuickConnectMenu extends StatefulWidget {
  const V3QuickConnectMenu({super.key, required this.primaryFocusNode});

  final FocusNode primaryFocusNode;

  @override
  State<V3QuickConnectMenu> createState() => _V3QuickConnectMenuState();
}

class _V3QuickConnectMenuState extends State<V3QuickConnectMenu> {
  late final PageController _pageController;
  late final List<FocusNode> _focusNodes;
  int selected = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selected);
    _focusNodes = List.generate(2, (_) => FocusNode());
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scrollController = ScrollController();
    return Container(
      alignment: Alignment.center,
      child: Dialog(
        backgroundColor: tokens.color.vsdslColorSurface100,
        insetPadding: EdgeInsets.zero,
        elevation: 16,
        shadowColor: tokens.color.vsdslColorOpacityNeutralSm,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 512, maxHeight: 600),
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(context),
                  const Gap(10),
                  _buildDeviceInfo(context),
                  const Gap(10),
                  _buildTabSwitch(context),
                  const Gap(10),
                  _buildTabContent(context, scrollController),
                  const Gap(10),
                  _buildFooter(context),
                ],
              ),
              Positioned(
                right: 13,
                bottom: 13,
                child: V3Focus(
                  label: S.of(context).v3_lbl_minimal_streaming_qrcode_menu,
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.tokens.color.vsdslColorOutline,
            width: 1,
          ),
        ),
      ),
      child: V3AutoHyphenatingText(
        S.of(context).v3_instruction_share_screen,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: context.tokens.color.vsdslColorOnSurface,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDeviceInfo(BuildContext context) {
    return Row(
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
          padding: EdgeInsets.all(context.tokens.spacing.vsdslSpacingSm.left),
          child: Consumer<InstanceInfoProvider>(
            builder: (_, instanceInfoProvider, __) {
              return V3AutoHyphenatingText(
                instanceInfoProvider.deviceName,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: context.tokens.color.vsdslColorOnSurfaceVariant,
                  letterSpacing: -0.48,
                ),
              );
            },
          ),
        ),
        ValueListenableBuilder(
          valueListenable: AppPreferences().connectivityTypeNotifier,
          builder: (context, value, child) {
            if (value == ConnectivityType.local.name) {
              return Container(
                decoration: ShapeDecoration(
                  color: context.tokens.color.vsdslColorSurface200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: context.tokens.spacing.vsdslSpacingXl.left,
                  vertical: context.tokens.spacing.vsdslSpacingSm.top,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/images/ic_local_connection_only.svg',
                      width: 21,
                      height: 21,
                    ),
                    const Gap(5),
                    V3AutoHyphenatingText(
                      S.of(context).v3_settings_local_connection_only,
                      style: context.tokens.textStyle.airsyncFontSubtitle600
                          .apply(
                              color: context.tokens.color.vsdslColorSurface600),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildTabSwitch(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: context.tokens.radii.vsdslRadiusLg,
        color: context.tokens.color.vsdslColorSurface200,
      ),
      child: Row(
        children: List.generate(_focusNodes.length, (index) {
          return Expanded(
            child: Focus(
              focusNode: _focusNodes[index],
              onFocusChange: (hasFocus) => setState(() {}),
              onKeyEvent: (node, event) {
                if (event.logicalKey == LogicalKeyboardKey.enter ||
                    event.logicalKey == LogicalKeyboardKey.select) {
                  _onTabSelected(index);
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: QuickConnectTabButton(
                isSelected: selected == index,
                isFocused: _focusNodes[index].hasFocus,
                label: index == 0
                    ? S.of(context).v3_quick_connect_menu_display_code
                    : S.of(context).v3_quick_connect_menu_qrcode,
                onTap: () => _onTabSelected(index),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(
      BuildContext context, ScrollController scrollController) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              selected = index;
              if (HardwareKeyboard.instance.logicalKeysPressed.isNotEmpty) {
                FocusScope.of(context).requestFocus(_focusNodes[index]);
              }
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: V3Scrollbar(
                controller: scrollController,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: const V3Instruction(isQuickConnect: true),
                ),
              ),
            ),
            const FittedBox(
              fit: BoxFit.contain,
              child: V3QrCodeQuickConnect(isStringOnTop: true, size: 195),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/ic_split_screen_quick_menu.svg',
            width: 21,
            height: 21,
          ),
          const Gap(3),
          Expanded(
            child: AutoSizeText(
              S.of(context).v3_quick_connect_menu_bottom_msg,
              style: TextStyle(
                color: context.tokens.color.vsdslColorOnSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTabSelected(int index) {
    setState(() {
      selected = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }
}

class QuickConnectTabButton extends StatelessWidget {
  final bool isSelected;
  final bool isFocused;
  final VoidCallback onTap;
  final String label;

  const QuickConnectTabButton({
    required this.isSelected,
    required this.isFocused,
    required this.onTap,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: tokens.radii.vsdslRadiusXs,
          border: Border.all(
            color: isFocused
                ? tokens.color.vsdslColorSecondary
                : Colors.transparent,
            width: isFocused ? 2.0 : 0,
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: tokens.radii.vsdslRadiusLg,
            color: isSelected
                ? tokens.color.vsdslColorPrimary
                : Colors.transparent,
          ),
          alignment: Alignment.center,
          child: V3AutoHyphenatingText(
            label,
            style: TextStyle(
              color: isSelected
                  ? tokens.color.vsdslColorOnSurfaceInverse
                  : tokens.color.vsdslColorPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
