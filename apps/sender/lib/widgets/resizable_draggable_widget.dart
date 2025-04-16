import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ResizableDraggableWidget extends StatefulWidget {
  final double halfScreen;
  final String text;
  final VoidCallback onStop;
  final double height;

  const ResizableDraggableWidget({
    super.key,
    required this.halfScreen,
    required this.text,
    required this.onStop,
    this.height = 62,
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final textPainter = TextPainter(
        text: TextSpan(
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.tokens.color.vsdswColorOnSuccess,
          ),
          text: widget.text,
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      setState(() {
        const iconSize = 26;
        final textWidth = textPainter.size.width;

        final gap = context.tokens.spacing.vsdswSpacingSm.right;
        final textPadding = context.tokens.spacing.vsdswSpacingXs.right;
        final textWithFullWidth =
            textWidth + (iconSize * 3) + (gap * 2) + (textPadding * 2) + 8;
        _width = math.min(textWithFullWidth, widget.halfScreen * 2);
        // 1 icon + 2 gaps
        _collapsedWidth = iconSize + (gap * 2);

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
        parentContext: context,
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
      child: V3Focus(
        label: S.of(context).v3_lbl_streaming_expand_button,
        identifier: 'v3_qa_streaming_expand_button',
        child: InkWell(
          onTap: () {
            _updatePositionForExpandOrCollapse(
                true, _collapsedWidth, screenWidth);
            setState(() => _isExpanded = true);
          },
          child: CollapsedContentWidget(
            width: _collapsedWidth,
            height: widget.height,
            isDragging: false,
            parentContext: context,
          ),
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

  const ExpandedContentWidget({
    super.key,
    required this.width,
    required this.height,
    required this.text,
    required this.onMinimize,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final borderSide = BorderSide(
      width: 2,
      color: context.tokens.color.vsdswColorOnSurface,
    );
    final gap = SizedBox(width: context.tokens.spacing.vsdswSpacingSm.right);
    final textPadding =
        SizedBox(width: context.tokens.spacing.vsdswSpacingXs.right);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border(left: borderSide, top: borderSide, right: borderSide),
        borderRadius: BorderRadius.only(
          topLeft: context.tokens.radii.vsdswRadiusXl.topLeft,
          topRight: context.tokens.radii.vsdswRadiusXl.topRight,
        ),
        color: context.tokens.color.vsdswColorSuccess,
      ),
      child: Row(
        children: [
          gap,
          _buildIcon('assets/images/ic_drag.svg'),
          textPadding,
          Flexible(child: _buildText(context)),
          textPadding,
          _buildStopButton(context),
          // gap,
          _buildMinimizeButton(),
          gap,
        ],
      ),
    );
  }

  Widget _buildIcon(String assetPath) {
    return Container(
      alignment: Alignment.center,
      child: ExcludeSemantics(
        child: SvgPicture.asset(
          assetPath,
          height: 30,
          width: 30,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    return AutoSizeText(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: context.tokens.color.vsdswColorOnSuccess,
      ),
      maxLines: 1,
      minFontSize: 5,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStopButton(BuildContext context) {
    return V3Focus(
      label: S.of(context).v3_lbl_streaming_stop_button,
      identifier: 'v3_qa_streaming_stop_button',
      child: InkWell(
        onTap: onStop,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: CircleAvatar(
              radius: 16,
              backgroundColor: context.tokens.color.vsdswColorError,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: context.tokens.color.vsdswColorSurface100,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimizeButton() {
    return V3Focus(
      label: S.current.v3_lbl_streaming_minimize_button,
      identifier: 'v3_qa_streaming_minimize_button',
      child: InkWell(
        onTap: onMinimize,
        child: SizedBox(
          height: 48,
          width: 48,
          child: _buildIcon('assets/images/ic_minimize.svg'),
        ),
      ),
    );
  }
}

class CollapsedContentWidget extends StatelessWidget {
  final double width;
  final double height;
  final bool isDragging;
  final BuildContext parentContext;

  const CollapsedContentWidget({
    super.key,
    required this.width,
    required this.height,
    required this.isDragging,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    final borderSide = BorderSide(
      width: 2,
      color: parentContext.tokens.color.vsdswColorOnSurface,
    );
    final gap = parentContext.tokens.spacing.vsdswSpacingSm.right;

    return Container(
      padding: EdgeInsets.only(right: gap, left: gap, bottom: 4),
      width: width,
      height: 44,
      decoration: BoxDecoration(
        border: Border(left: borderSide, top: borderSide, right: borderSide),
        borderRadius: BorderRadius.only(
          topLeft: parentContext.tokens.radii.vsdswRadiusXl.topLeft,
          topRight: parentContext.tokens.radii.vsdswRadiusXl.topRight,
        ),
        color: parentContext.tokens.color.vsdswColorSuccess
            .withOpacity(isDragging ? 1.0 : 0.3),
      ),
      alignment: Alignment.center,
      child: ExcludeSemantics(
          child: SvgPicture.asset('assets/images/ic_expend.svg')),
    );
  }
}
