import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class HighQualityButton extends StatefulWidget {
  const HighQualityButton(
      {super.key, required this.onPressed, required this.initialValue});

  final ValueChanged<bool> onPressed;
  final bool initialValue;

  @override
  State<HighQualityButton> createState() => HighQualityButtonState();
}

class HighQualityButtonState extends State<HighQualityButton> {
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    isButtonEnabled = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    var textStyle14 = const TextStyle(
        color: Colors.white, fontSize: AppConstants.fontSizeNormal);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.high_quality,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              S.of(context).present_state_high_quality_title,
              style: textStyle14,
            ),
            IconButton(
              icon: Image(
                image: isButtonEnabled
                    ? const Svg('assets/images/ic_activate_on.svg')
                    : const Svg('assets/images/ic_activate_off.svg'),
              ),
              focusColor: Colors.grey,
              onPressed: () {
                isButtonEnabled = !isButtonEnabled;
                widget.onPressed(isButtonEnabled);
                if (!mounted) return;
                setState(() {});
              },
            ),
          ],
        ),
        IntrinsicHeight(
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(8, 0, 11, 0),
                width: 5,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: Text(
                  S.of(context).present_state_high_quality_description,
                  style: textStyle14,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
