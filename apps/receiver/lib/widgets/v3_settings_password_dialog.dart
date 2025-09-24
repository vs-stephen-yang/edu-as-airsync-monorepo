import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3SettingsPasswordDialog extends StatelessWidget {
  const V3SettingsPasswordDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: context.tokens.radii.vsdslRadiusXl,
      ),
      insetPadding: EdgeInsets.zero,
      backgroundColor: context.tokens.color.vsdslColorOnSurfaceInverse,
      elevation: 16.0,
      shadowColor: context.tokens.color.vsdslColorOpacityNeutralSm,
      child: SizedBox(
        width: 417,
        height: 220,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.tokens.spacing.vsdslSpacing3xl.left,
            27,
            context.tokens.spacing.vsdslSpacing3xl.right,
            20,
          ),
          child: const V3SettingsPasswordContent(),
        ),
      ),
    );
  }
}

class V3SettingsPasswordContent extends StatefulWidget {
  const V3SettingsPasswordContent({super.key});

  @override
  State<StatefulWidget> createState() => _V3SettingsPasswordContentState();
}

class _V3SettingsPasswordContentState extends State<V3SettingsPasswordContent> {
  final TextEditingController _controller = TextEditingController(text: '');
  final FocusNode _focusNode = FocusNode();
  final FocusNode _confirmButtonFocus = FocusNode();
  bool _errorState = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var border = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(
        color: context.tokens.color.vsdslColorSecondary,
        width: 2,
      ),
    );
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 21,
              height: 21,
              child: SvgPicture.asset('assets/images/ic_unlock_black.svg'),
            ),
            AutoSizeText(
              S.of(context).v3_setting_passcode_title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.tokens.color.vsdslColorOnSurface,
              ),
            ),
          ],
        ),
        Gap(context.tokens.spacing.vsdslSpacing4xl.top),
        SizedBox(
          width: 216,
          height: 46,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textAlign: TextAlign.center,
            obscureText: true,
            obscuringCharacter: '*',
            style: TextStyle(
              // cursorHeight / fontSize
              height: 26 / 40,
              color: context.tokens.color.vsdslColorNeutral,
              fontSize: 40,
              fontWeight: FontWeight.w500,
              letterSpacing: 13,
            ),
            cursorHeight: 26,
            decoration: InputDecoration(
              border: border,
              enabledBorder: border,
              focusedBorder: border,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
              LengthLimitingTextInputFormatter(4),
            ],
            onChanged: (value) {
              if (!mounted) return;
              setState(() {
                _errorState = false;
              });
            },
            onSubmitted: (_) => _passcodeCheck(),
          ),
        ),
        if (_errorState) ...[
          Gap(context.tokens.spacing.vsdslSpacingSm.top),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: context.tokens.color.vsdslColorError,
              ),
              V3AutoHyphenatingText(
                S.of(context).v3_setting_passcode_error_description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.tokens.color.vsdslColorError,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Gap(context.tokens.spacing.vsdslSpacingMd.top),
        ],
        if (!_errorState) Gap(context.tokens.spacing.vsdslSpacing4xl.top),
        Row(
          children: [
            SizedBox(
              width: 108,
              height: 40,
              child: V3Focus(
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: context.tokens.color.vsdslColorTertiary,
                    backgroundColor: Colors.transparent,
                    // remove onFocused color, this is also ripple color
                    overlayColor: Colors.transparent,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context, false);
                    }
                  },
                  child: AutoSizeText(
                    S.of(context).v3_setting_passcode_cancel,
                  ),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 108,
              height: 40,
              child: V3Focus(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: context.tokens.color.vsdslColorPrimary,
                    backgroundColor: context.tokens.color.vsdslColorSurface100,
                    // remove onFocused color, this is also ripple color
                    overlayColor: Colors.transparent,
                    side: BorderSide(
                      color: context.tokens.color.vsdslColorPrimary,
                      width: 1.5,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    _clearFields();
                  },
                  child: AutoSizeText(
                    S.of(context).v3_setting_passcode_clear,
                  ),
                ),
              ),
            ),
            const Gap(8),
            SizedBox(
              width: 108,
              height: 40,
              child: V3Focus(
                child: ElevatedButton(
                  focusNode: _confirmButtonFocus,
                  style: ElevatedButton.styleFrom(
                    elevation: 5.0,
                    shadowColor: context.tokens.color.vsdslColorPrimary,
                    foregroundColor:
                        context.tokens.color.vsdslColorOnSurfaceInverse,
                    backgroundColor: context.tokens.color.vsdslColorPrimary,
                    // remove onFocused color, this is also ripple color
                    overlayColor: Colors.transparent,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    _passcodeCheck();
                  },
                  child: AutoSizeText(
                    S.of(context).v3_setting_passcode_confirm,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _passcodeCheck() {
    String passcode = _controller.text;
    if (passcode.length == 4) {
      SettingsProvider settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      var same = settingsProvider.settingsPassword == passcode;
      if (same) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      } else {
        if (!mounted) return;
        setState(() {
          _clearFields();
          _errorState = true;
        });
      }
    }
  }

  void _clearFields() {
    _controller.clear();
    _errorState = false;
    FocusScope.of(context).requestFocus(_focusNode);
  }
}
