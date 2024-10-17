import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

typedef ColorSelectCallback = Function(Color color);

class ColorBoxGroup extends StatelessWidget {
  const ColorBoxGroup({
    super.key,
    required this.width,
    required this.height,
    this.colors = const [],
    this.selectedBorderColor = Colors.white,
    this.selectedBorderWidth = 2.0,
    this.spacing = 0.0,
    this.groupValue,
    this.onTap,
    this.usingWrapLayout = true,
  });

  /// The width of each color box in the group
  final double? width;

  /// The height of each color box in the group
  final double? height;

  /// The callback for if a given color is clicked
  final ColorSelectCallback? onTap;

  /// The colors to display in this color group
  final List<Color> colors;

  /// The color that is selected for the group
  final Color? groupValue;

  /// The spacing between each color
  final double spacing;

  final Color selectedBorderColor;

  final double selectedBorderWidth;

  final bool usingWrapLayout;

  @override
  Widget build(BuildContext context) {
    List<Widget> colorWidgets = List.from(colors.map((color) => ColorBox(
      key: Key("color-$color"),
      width: width,
      height: height,
      color: color,
      selectedBorderColor: selectedBorderColor,
      selectedBorderWidth: selectedBorderWidth,
      isSelected: color.value == groupValue?.value,
      onTap: () => {
        if (onTap != null) {onTap!(color)}
      },
    )));

    if (usingWrapLayout) {
      return Wrap(
        spacing: spacing,
        children: colorWidgets,
      );
    }

    return Row(
      children: colorWidgets.mapIndexed((index, colorWidget) {
        final isLast = index == colorWidgets.length - 1;

        return Padding(
          padding: EdgeInsets.only(
            right: isLast ? 0 : spacing,
          ),
          child: colorWidget,
        );
      }).toList(),
    );
  }
}

class ColorBox extends StatelessWidget {
  const ColorBox({
    super.key,
    @required this.width,
    @required this.height,
    @required this.color,
    this.selectedBorderColor = Colors.white,
    this.selectedBorderWidth = 2.0,
    this.isSelected = false,
    this.onTap,
  })  : assert(width != null && width > 0),
        assert(height != null && height > 0),
        assert(color != null);

  /// The width of the ColorBox
  final double? width;

  /// The height of the ColorBox
  final double? height;

  /// The color to fill the ColorBox with
  final Color? color;

  /// Override the groupValue toggling
  final bool isSelected;

  /// Callback for when this ColorBox is tapped
  final VoidCallback? onTap;

  final Color selectedBorderColor;

  final double selectedBorderWidth;

  @override
  Widget build(BuildContext context) {
    BoxBorder border = const Border();
    if (isSelected) {
      border = Border.all(color: selectedBorderColor, width: selectedBorderWidth);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: border,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}
