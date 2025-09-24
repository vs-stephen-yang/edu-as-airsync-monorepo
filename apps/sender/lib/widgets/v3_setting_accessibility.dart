import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/pref_text_scale_provider.dart';
import 'package:display_cast_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class V3SettingAccessibility extends StatelessWidget {
  const V3SettingAccessibility({super.key, this.isAppMode = false});

  final bool isAppMode;

  @override
  Widget build(BuildContext context) {
    return TextSizeDropdown(
      isAppMode: isAppMode,
    );
  }
}

class TextSizeDropdown extends StatefulWidget {
  const TextSizeDropdown({super.key, required this.isAppMode});

  final bool isAppMode;

  @override
  TextSizeDropdownState createState() => TextSizeDropdownState();
}

class TextSizeDropdownState extends State<TextSizeDropdown> {
  TextSizeOption selected = TextSizeOption.normal;

  @override
  void initState() {
    selected = Provider.of<TextScaleProvider>(context, listen: false).textSize;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: widget.isAppMode
          ? const EdgeInsets.all(16)
          : EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              V3AutoHyphenatingText(
                S.current.v3_setting_accessibility_text_size,
                style: TextStyle(
                  color: context.tokens.color.vsdswColorOnSurfaceInverse,
                  decoration: TextDecoration.underline,
                ),
              ),
              Spacer(),
              SizedBox(
                width: 160,
                child: SizeDropdown(
                  options: TextSizeOption.values,
                  selected: selected,
                  onSelected: (option) {
                    Provider.of<TextScaleProvider>(context, listen: false)
                        .setTextSize(option);
                    if (!mounted) return;
                    setState(() {
                      selected = option;
                    });
                  },
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            height: 1,
            color: context.tokens.color.vsdswColorOutlineVariant,
          )
        ],
      ),
    );
  }
}

class SizeDropdown extends StatefulWidget {
  final List<TextSizeOption> options;
  final TextSizeOption selected;
  final Function(TextSizeOption) onSelected;

  const SizeDropdown({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<SizeDropdown> createState() => _SizeDropdownState();
}

class _SizeDropdownState extends State<SizeDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late TextSizeOption _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  void _toggleOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    // Offset offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          offset: Offset(0, size.height + 4),
          link: _layerLink,
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            color: context.tokens.color.vsdswColorSurface100,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(8),
              children: widget.options.map((option) {
                final isSelected = option.value == _selected.value;
                return InkWell(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.tokens.color.vsdswColorPrimary
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: V3AutoHyphenatingText(
                            option.name,
                            style: TextStyle(
                              color: isSelected
                                  ? context.tokens.color.vsdswColorSurface100
                                  : context.tokens.color.vsdswColorNeutral,
                            ),
                          ),
                        ),
                        Spacer(),
                        if (isSelected)
                          SvgPicture.asset(
                              'assets/images/v3_ic_accessibility_selected.svg'),
                      ],
                    ),
                  ),
                  onTap: () {
                    if (!mounted) return;
                    setState(() {
                      _selected = option;
                    });
                    widget.onSelected(option);
                    _removeOverlay();
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleOverlay,
        child: Container(
          constraints: BoxConstraints(
            minHeight: 48,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.tokens.color.vsdswColorSurface100,
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: context.tokens.color.vsdswColorSurface100),
          ),
          child: Row(
            children: [
              Expanded(child: V3AutoHyphenatingText(_selected.name)),
              SvgPicture.asset('assets/images/v3_ic_accessibility_arrow.svg'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }
}
