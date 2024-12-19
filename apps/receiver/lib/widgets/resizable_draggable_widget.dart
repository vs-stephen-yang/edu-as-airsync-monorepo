import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class ResizableDraggableWidget extends StatefulWidget {
  final double halfScreen;
  final String text;
  final VoidCallback onStop;
  final VoidCallback onMute;
  final double height;

  const ResizableDraggableWidget({
    super.key,
    required this.halfScreen,
    required this.text,
    required this.onStop,
    this.height = 37,
    required this.onMute,
  });

  @override
  State<ResizableDraggableWidget> createState() =>
      _ResizableDraggableWidgetState();
}

class _ResizableDraggableWidgetState extends State<ResizableDraggableWidget> {
  double _currentX = 0;
  double _width = 0;
  double _collapsedWidth = 0;
  bool _isExpanded = true;
  double? _previousScreenWidth;
  bool _isCollapsedTapDown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final textPainter = TextPainter(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          text: widget.text,
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      setState(() {
        final textWidth = textPainter.size.width;

        final gap = context.tokens.spacing.vsdslSpacingSm.right;
        final textPadding = context.tokens.spacing.vsdslSpacingXs.right;
        final textWithFullWidth =
            textWidth + (26 * 3) + (gap * 5) + (textPadding * 2) + 8 + 26;
        _width = math.min(textWithFullWidth, widget.halfScreen * 2);
        // 1 icon + 2 gaps
        _collapsedWidth =
            26 + (context.tokens.spacing.vsdslSpacingLg.right * 2);

        // initial position
        _currentX = widget.halfScreen - (_width / 2);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        double maxAllowedWidth = _isExpanded ? _width : _collapsedWidth;

        if (_previousScreenWidth != null &&
            _previousScreenWidth != screenWidth) {
          double oldAvailableSpace = _previousScreenWidth! - maxAllowedWidth;
          double newAvailableSpace = screenWidth - maxAllowedWidth;

          if (oldAvailableSpace > 0) {
            double positionRatio = _currentX / oldAvailableSpace;
            _currentX = positionRatio * newAvailableSpace;
          } else {
            _currentX =
                math.min(math.max(0, _currentX), screenWidth - maxAllowedWidth);
          }
        }

        _previousScreenWidth = screenWidth;

        _currentX =
            math.min(math.max(0, _currentX), screenWidth - maxAllowedWidth);

        return Stack(
          children: [
            Positioned(
              left: _currentX,
              bottom: 0,
              child: _isExpanded
                  ? _buildExpandedWidget(screenWidth, onStop: widget.onStop)
                  : _buildCollapsedWidget(screenWidth),
            ),
          ],
        );
      },
    );
  }

  void _updatePositionForExpandOrCollapse(
      bool isExpanding, double collapsedWidth, double screenWidth) {
    double widgetCurrentWidth = _isExpanded ? _width : collapsedWidth;
    double widgetCenter = _currentX + (widgetCurrentWidth / 2);
    double screenCenter = screenWidth / 2;

    setState(() {
      if (widgetCenter > screenCenter) {
        if (isExpanding) {
          _currentX -= (_width - collapsedWidth);
        } else {
          _currentX += (_width - collapsedWidth);
        }
      } else if (widgetCenter == screenCenter) {
        _currentX = isExpanding
            ? (screenCenter - _width / 2)
            : (screenCenter - collapsedWidth / 2);
      }

      if (isExpanding) {
        _currentX = _currentX.clamp(0.0, screenWidth - _width);
      } else {
        final newX = _currentX.clamp(0.0, screenWidth - collapsedWidth);
        _currentX = (newX + collapsedWidth > screenWidth)
            ? (screenWidth - collapsedWidth)
            : newX;
      }
    });
  }

  Widget _buildExpandedWidget(double screenWidth,
      {required VoidCallback onStop}) {
    return Draggable(
      axis: Axis.horizontal,
      feedback: const SizedBox.shrink(),
      childWhenDragging: ExpandedContentWidget(
        width: _width,
        height: widget.height,
        text: widget.text,
        onMinimize: () {},
        onStop: () {},
        onMute: () {},
      ),
      onDragUpdate: (details) {
        setState(() {
          _currentX =
              (_currentX + details.delta.dx).clamp(0.0, screenWidth - _width);
        });
      },
      onDragEnd: (_) {
        setState(() {
          _currentX = _currentX.clamp(0.0, screenWidth - _width);
        });
      },
      child: ExpandedContentWidget(
        width: _width,
        height: widget.height,
        text: widget.text,
        onMinimize: () {
          _updatePositionForExpandOrCollapse(
              false, _collapsedWidth, screenWidth);
          setState(() => _isExpanded = false);
        },
        onMute: widget.onMute,
        onStop: onStop,
      ),
    );
  }

  Widget _buildCollapsedWidget(double screenWidth) {
    return Draggable(
      axis: Axis.horizontal,
      feedback: const SizedBox.shrink(),
      childWhenDragging: CollapsedContentWidget(
        width: _collapsedWidth,
        height: widget.height,
        isDragging: true,
        isTapped: false,
      ),
      onDragUpdate: (details) {
        setState(() {
          _currentX = (_currentX + details.delta.dx)
              .clamp(0.0, screenWidth - _collapsedWidth);
        });
      },
      onDragEnd: (_) {
        setState(() {
          _currentX = _currentX.clamp(0.0, screenWidth - _collapsedWidth);
        });
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isCollapsedTapDown = true),
        onTap: () {
          _updatePositionForExpandOrCollapse(
              true, _collapsedWidth, screenWidth);
          setState(() {
            _isExpanded = true;
            _isCollapsedTapDown = false;
          });
        },
        onTapCancel: () => setState(() => _isCollapsedTapDown = false),
        child: CollapsedContentWidget(
          width: _collapsedWidth,
          height: widget.height,
          isDragging: false,
          isTapped: _isCollapsedTapDown,
        ),
      ),
    );
  }
}

class ExpandedContentWidget extends StatelessWidget {
  final double width;
  final double height;
  final String text;
  final VoidCallback onMinimize;
  final VoidCallback onStop;
  final VoidCallback onMute;

  const ExpandedContentWidget({
    super.key,
    required this.width,
    required this.height,
    required this.text,
    required this.onMinimize,
    required this.onStop,
    required this.onMute,
  });

  @override
  Widget build(BuildContext context) {
    final gap = Gap(context.tokens.spacing.vsdslSpacingSm.right);
    final textPadding = Gap(context.tokens.spacing.vsdslSpacingXs.right);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: context.tokens.radii.vsdslRadiusmd.topLeft,
          topRight: context.tokens.radii.vsdslRadiusmd.topRight,
        ),
        color: context.tokens.color.vsdslColorSuccess,
      ),
      child: Row(
        children: [
          gap,
          _buildIcon('assets/images/ic_drag.svg'),
          textPadding,
          Flexible(child: _buildText(context)),
          textPadding,
          gap,
          _buildMuteButton(context),
          gap,
          _buildStopButton(context),
          gap,
          _buildMinimizeButton(),
          gap,
        ],
      ),
    );
  }

  Widget _buildIcon(String assetPath) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      child: SvgPicture.asset(assetPath),
    );
  }

  Widget _buildText(BuildContext context) {
    return AutoSizeText(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      maxLines: 1,
      minFontSize: 5,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMuteButton(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: IconButton(
        icon: SvgPicture.asset('assets/images/ic_group_mute.svg'),
        //TODO:unmute
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: onMute,
      ),
    );
  }

  Widget _buildStopButton(BuildContext context) {
    return GestureDetector(
      onTap: onStop,
      child: SizedBox(
        width: 26,
        height: 26,
        child: CircleAvatar(
          radius: 13,
          backgroundColor: context.tokens.color.vsdslColorError,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: context.tokens.color.vsdslColorSurface100,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimizeButton() {
    return GestureDetector(
      onTap: onMinimize,
      child: Opacity(
          opacity: 0.64, child: _buildIcon('assets/images/ic_minimize.svg')),
    );
  }
}

class CollapsedContentWidget extends StatelessWidget {
  final double width;
  final double height;
  final bool isDragging;
  final bool isTapped;

  const CollapsedContentWidget({
    super.key,
    required this.width,
    required this.height,
    required this.isDragging,
    required this.isTapped,
  });

  @override
  Widget build(BuildContext context) {
    final gap = context.tokens.spacing.vsdslSpacingLg.right;
    final isTappedOrDragging = isTapped || isDragging;

    return Opacity(
      opacity: isTappedOrDragging ? 1 : 0.3,
      child: Container(
        padding: EdgeInsets.only(right: gap, left: gap, bottom: 4),
        width: width,
        height: height * 0.7,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: context.tokens.radii.vsdslRadiusmd.topRight),
            color: context.tokens.color.vsdslColorSuccess),
        alignment: Alignment.center,
        child: SvgPicture.asset('assets/images/ic_expend.svg'),
      ),
    );
  }
}
