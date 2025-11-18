import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class V3HelpCenterWidget extends StatefulWidget {
  const V3HelpCenterWidget({super.key});

  @override
  State<V3HelpCenterWidget> createState() => _V3HelpCenterWidgetState();
}

class _V3HelpCenterWidgetState extends State<V3HelpCenterWidget> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _iconKey = GlobalKey();
  final double _maxHeight = 500;

  void _showPopover() {
    final colorTokens = context.tokens.color;
    final renderBox = _iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final iconPosition = renderBox.localToGlobal(Offset.zero);

    final popoverMaxWidth =
        MediaQuery.of(context).size.width - iconPosition.dx - 10;

    final double popoverWidth = popoverMaxWidth < 383 ? popoverMaxWidth : 383;

    // 有些情況高度會超出畫面，這時會計算y的補正，維持在畫面中。
    final double positionY =
        iconPosition.dy < _maxHeight ? (_maxHeight - iconPosition.dy) : 0;
    // x軸若超出畫面，透過targetAnchor與followerAnchor來修正。
    final overflow = iconPosition.dx < (popoverWidth / 2);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        top: 0,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0, positionY),
          targetAnchor: overflow ? Alignment.topLeft : Alignment.topCenter,
          followerAnchor:
              overflow ? Alignment.bottomLeft : Alignment.bottomCenter,
          child: TapRegion(
            onTapOutside: (_) => _removePopover(),
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: overflow
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Container(
                    width: popoverWidth,
                    constraints: BoxConstraints(maxHeight: _maxHeight),
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 8),
                    decoration: BoxDecoration(
                      color: colorTokens.vsdslColorSurface100,
                      borderRadius: overflow
                          ? BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            )
                          : BorderRadius.circular(20),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildHelpCenterContent(colorTokens),
                  ),
                  CustomPaint(
                    painter: TrianglePainter(
                      color: colorTokens.vsdslColorSurface100,
                    ),
                    child: const SizedBox(width: 10, height: 7),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removePopover() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildHelpCenterContent(ColorTokens tokens) {
    final helpItems = [
      (
        icon: 'assets/images/ic_moderator_share.svg',
        title: S.of(context).v3_help_center_share_title,
        subtitle: S.of(context).v3_help_center_share_title_sub,
      ),
      (
        icon: 'assets/images/ic_moderator_cast_device.svg',
        title: S.of(context).v3_help_center_cast_device_title,
        subtitle: S.of(context).v3_help_center_cast_device_title_sub,
      ),
      (
        icon: 'assets/images/ic_moderator_touchback.svg',
        title: S.of(context).v3_help_center_touchback_title,
        subtitle: S.of(context).v3_help_center_touchback_title_sub,
      ),
      (
        icon: 'assets/images/ic_moderator_untouchback.svg',
        title: S.of(context).v3_help_center_untouchback_title,
        subtitle: S.of(context).v3_help_center_untouchback_title_sub,
      ),
      (
        icon: 'assets/images/ic_moderator_fullscreen.svg',
        title: S.of(context).v3_help_center_fullscreen_title,
        subtitle: null,
      ),
      (
        icon: 'assets/images/ic_moderator_mute.svg',
        title: S.of(context).v3_help_center_mute_user_title,
        subtitle: null,
      ),
      (
        icon: 'assets/images/ic_moderator_remove_user.svg',
        title: S.of(context).v3_help_center_remove_user_title,
        subtitle: null,
      ),
      (
        icon: 'assets/images/ic_moderator_stop_share.svg',
        title: S.of(context).v3_help_center_stop_share_title,
        subtitle: null,
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          S.of(context).v3_help_center_title,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: tokens.vsdslColorOnSurface),
        ),
        const Gap(12),
        Expanded(
          child: V3Scrollbar(
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  ...List.generate(helpItems.length * 2 - 1, (i) {
                    if (i.isEven) {
                      final index = i ~/ 2;
                      final item = helpItems[index];
                      return HelpCenterItem(
                        icon: SvgPicture.asset(
                          item.icon,
                          width: 26,
                          height: 26,
                        ),
                        title: item.title,
                        subtitle: item.subtitle,
                      );
                    } else {
                      return _divider(tokens.vsdslColorOutline);
                    }
                  }),
                ],
              ),
            ),
          ),
        ),
        const Gap(28),
        V3Focus(
          label: S.of(context).v3_lbl_close_help_center,
          identifier: 'v3_qa_close_help_center',
          child: InkWell(
            onTap: _removePopover,
            child: Container(
              alignment: Alignment.center,
              constraints: BoxConstraints(maxWidth: 150),
              color: context.tokens.color.vsdslColorSurface100,
              height: 25,
              child: Text(
                S.of(context).v3_help_center_close,
                style: TextStyle(color: tokens.vsdslColorInfo, fontSize: 9),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider(Color color) => Padding(
        padding: const EdgeInsets.only(left: 40),
        child: Divider(
          color: color,
          height: 20,
        ),
      );

  @override
  void dispose() {
    _scrollController.dispose();
    _removePopover();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens.color;

    return V3Focus(
      key: _iconKey,
      label: S.of(context).v3_lbl_open_help_center,
      identifier: 'v3_qa_open_help_center',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CompositedTransformTarget(
            link: _layerLink,
            child: InkWell(
              onTap: () =>
                  _overlayEntry == null ? _showPopover() : _removePopover(),
              child: SvgPicture.asset(
                'assets/images/ic_help_center.svg',
                width: 20,
                height: 20,
              ),
            ),
          ),
          const Gap(5),
          Container(
            color: context.tokens.color.vsdslColorSurface100,
            child: Text(
              S.of(context).v3_help_center_title,
              style: TextStyle(fontSize: 9, color: tokens.vsdslColorInfo),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpCenterItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;

  const HelpCenterItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: Container(
                alignment: Alignment.center,
                child: icon,
              ),
            ),
            const Gap(12),
            Expanded(
              child: SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 12,
                          color: context.tokens.color.vsdslColorOnSurface),
                    ),
                    if (subtitle != null)
                      Flexible(
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                              fontSize: 9,
                              color: context.tokens.color.vsdslColorInfo),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color;
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
