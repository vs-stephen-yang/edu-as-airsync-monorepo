import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart' as svg;
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:gap/gap.dart';

/// 設備名稱顯示組件
class DeviceNameDisplay extends StatelessWidget {
  final String deviceName;
  final TextStyle? textStyle;

  const DeviceNameDisplay({
    super.key,
    required this.deviceName,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Builder(builder: (context) {
        final sc = ScrollController();
        return V3Scrollbar(
          controller: sc,
          child: SingleChildScrollView(
            controller: sc,
            child: V3AutoHyphenatingText(
              deviceName,
              style: textStyle ??
                  TextStyle(
                    fontSize: 12,
                    color: context.tokens.color.vsdslColorOnSurfaceInverse,
                  ),
            ),
          ),
        );
      }),
    );
  }
}

/// 授權按鈕類型
enum AuthorizeButtonType {
  decline,
  accept,
  acceptAll,
}

/// 統一的授權按鈕組件
class AuthorizeButton extends StatelessWidget {
  final AuthorizeButtonType type;
  final String text;
  final VoidCallback onPressed;
  final String? focusLabel;
  final String? focusIdentifier;
  final double minWidth;
  final double minHeight;
  final String? iconPath;
  final bool showText;

  const AuthorizeButton({
    super.key,
    required this.type,
    required this.text,
    required this.onPressed,
    this.focusLabel,
    this.focusIdentifier,
    this.minWidth = 80,
    required this.minHeight,
    this.iconPath,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return V3Focus(
      label: focusLabel ?? text,
      identifier: focusIdentifier ?? 'authorize_button_${type.name}',
      child: Container(
        constraints: BoxConstraints(
          minWidth: showText ? minWidth : 26.6,
          maxWidth: showText ? double.infinity : 26.6,
          minHeight: minHeight,
        ),
        child: ElevatedButton(
          style: _getButtonStyle(context),
          onPressed: onPressed,
          child: _buildButtonContent(),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (iconPath == null) {
      return AutoSizeText(text);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ExcludeSemantics(
          child: Image(
            width: 16,
            image: Svg(iconPath!),
          ),
        ),
        if (showText) const SizedBox(width: 4),
        if (showText)
          Flexible(
            child: AutoSizeText(text, maxLines: 1),
          ),
      ],
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final basePadding =
        MediaQuery.of(context).textScaler.scale(1.0) <= 1.0 || !showText
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 10);

    const baseTextStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    return ElevatedButton.styleFrom(
      shape: showText ? null : CircleBorder(),
      foregroundColor: (type == AuthorizeButtonType.decline)
          ? context.tokens.color.vsdslColorError
          : context.tokens.color.vsdslColorNeutral,
      backgroundColor: context.tokens.color.vsdslColorOnSurfaceInverse,
      textStyle: baseTextStyle,
      padding: basePadding,
    );
  }
}

/// 請求行組件的數據模型

class RequestRowData {
  final String deviceName;
  final String iconAsset;
  final VoidCallback onDecline;
  final VoidCallback onAccept;
  final String declineText;
  final String acceptText;

  const RequestRowData({
    required this.deviceName,
    required this.iconAsset,
    required this.onDecline,
    required this.onAccept,
    required this.declineText,
    required this.acceptText,
  });
}

/// 統一的請求行組件
class RequestRow extends StatelessWidget {
  final RequestRowData data;
  final double containerHeight;

  const RequestRow({
    super.key,
    required this.data,
    required this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 508,
      height: containerHeight,
      child: MultiWindowAdaptiveLayout(
        launcher: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            // 設備名稱
            Expanded(
              child: Text(
                data.deviceName,
                style: TextStyle(
                  fontSize: 10.666,
                  color: context.tokens.color.vsdslColorOnSurfaceInverse,
                ),
              ),
            ),
            Gap(context.tokens.spacing.vsdslSpacingSm.left),
            // Accept 按鈕
            AuthorizeButton(
              iconPath:
                  'assets/images/ic_authorize_prompt_components_accept.svg',
              type: AuthorizeButtonType.accept,
              showText: false,
              text: data.acceptText,
              onPressed: data.onAccept,
              focusLabel: data.acceptText,
              focusIdentifier: 'v3_qa_authorize_prompt_accept',
              minHeight: containerHeight,
            ),
            Gap(context.tokens.spacing.vsdslSpacingSm.left),
            // Decline 按鈕
            AuthorizeButton(
              iconPath:
                  'assets/images/ic_authorize_prompt_components_cancel.svg',
              type: AuthorizeButtonType.decline,
              showText: false,
              text: data.declineText,
              onPressed: data.onDecline,
              focusLabel: data.declineText,
              focusIdentifier: 'v3_qa_authorize_prompt_decline',
              minHeight: containerHeight,
            ),
            Gap(context.tokens.spacing.vsdslSpacingSm.left),
          ],
        ),
        landscape: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 圖標
            svg.SvgPicture.asset(
              data.iconAsset,
              excludeFromSemantics: true,
              width: 21,
              height: 21,
            ),
            Gap(context.tokens.spacing.vsdslSpacingSm.left),

            // 設備名稱
            DeviceNameDisplay(
                deviceName: data.deviceName),
            Gap(context.tokens.spacing.vsdslSpacingSm.left),
            // Accept 按鈕
            AuthorizeButton(
              iconPath:
                  'assets/images/ic_authorize_prompt_components_accept.svg',
              type: AuthorizeButtonType.accept,
              text: data.acceptText,
              onPressed: data.onAccept,
              focusLabel: data.acceptText,
              focusIdentifier: 'v3_qa_authorize_prompt_accept',
              minHeight: containerHeight,
            ),

            Gap(context.tokens.spacing.vsdslSpacingSm.left),

            // Decline 按鈕
            AuthorizeButton(
              iconPath:
                  'assets/images/ic_authorize_prompt_components_cancel.svg',
              type: AuthorizeButtonType.decline,
              text: data.declineText,
              onPressed: data.onDecline,
              focusLabel: data.declineText,
              focusIdentifier: 'v3_qa_authorize_prompt_decline',
              minHeight: containerHeight,
            ),
            Gap(context.tokens.spacing.vsdslSpacingSm.left),
          ],
        ),
      ),
    );
  }
}
