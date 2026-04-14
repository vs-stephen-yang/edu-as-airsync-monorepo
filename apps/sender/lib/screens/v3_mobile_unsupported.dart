import 'dart:async';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/utilities/web_util.dart';
import 'package:display_cast_flutter/widgets/v3_scroll_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

/// Mobile unsupported page - shows logo, unsupported message banner and overlay dialog
class V3MobileUnsupported extends StatelessWidget {
  const V3MobileUnsupported({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tokens.color.vsdswColorSurface100,
      body: Stack(
        children: [
          // Background with logo and unsupported message
          Column(
            children: [
              _buildHeader(context),
              _buildUnsupportedMessage(context),
            ],
          ),

          // Overlay dialog (non-dismissible)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: _buildNotSupportDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final bool isSmallScreen = !isBigThan768(context);
    final bool isMiniScreen = !isBigThan384(context);
    final horizontalPadding = isSmallScreen ? 16.0 : 40.0;
    final verticalPadding = isSmallScreen ? 8.0 : 16.0;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          top: verticalPadding,
          left: horizontalPadding,
          right: horizontalPadding,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: SvgPicture.asset(
                isMiniScreen
                    ? 'assets/images/ic_logo_airsync_no_word.svg'
                    : 'assets/images/ic_logo_airsync.svg',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnsupportedMessage(BuildContext context) {
    bool showUnsupportedMassage = true;
    return StatefulBuilder(builder: (context, setState) {
      final isSmallScreen = !isBigThan768(context);
      return showUnsupportedMassage
          ? Container(
              color: context.tokens.color.vsdswColorWarning,
              padding: EdgeInsets.symmetric(
                  horizontal: 24, vertical: isSmallScreen ? 16 : 0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Wrap(
                  direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
                  alignment: WrapAlignment.center,
                  spacing: 24,
                  runAlignment: isSmallScreen
                      ? WrapAlignment.start
                      : WrapAlignment.center,
                  runSpacing: 0,
                  crossAxisAlignment: isSmallScreen
                      ? WrapCrossAlignment.start
                      : WrapCrossAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isSmallScreen
                            ? MediaQuery.of(context).size.width - 48
                            : double.infinity,
                      ),
                      child: Text(
                        S.current.v3_main_web_nonsupport,
                        style: TextStyle(
                          color: context.tokens.color.vsdswColorOnWarning,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    InkWell(
                      child: Container(
                        alignment: Alignment.center,
                        width: 67,
                        height: 32,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          S.current.v3_main_web_nonsupport_confirm,
                          style: TextStyle(
                            color: context.tokens.color.vsdswColorWarning,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      onTap: () {
                        if (!context.mounted) {
                          return;
                        }
                        setState(() {
                          showUnsupportedMassage = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox();
    });
  }

  Widget _buildNotSupportDialog(BuildContext context) {
    final sc = ScrollController();
    return AlertDialog(
      backgroundColor: Colors.white,
      // Can not use V3AutoHyphenatingText
      title: Text(S.of(context).main_notice_title),
      content: SizedBox(
        width: 100,
        height: 100,
        child: V3Scrollbar(
          controller: sc,
          child: SingleChildScrollView(
            controller: sc,
            // Can not use V3AutoHyphenatingText
            child: Text(S.of(context).main_notice_not_support_description),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
            // 设置按钮背景颜色
            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            // 设置按钮文字颜色
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // 设置按钮圆角
                side: const BorderSide(color: Colors.blue), // 设置按钮边框
              ),
            ),
          ),
          onPressed: () async {
            if (defaultTargetPlatform == TargetPlatform.android) {
              unawaited(launchUrl(Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.viewsonic.display.cast&pcampaignid=web_share')));
            } else if (defaultTargetPlatform == TargetPlatform.iOS) {
              unawaited(launchUrl(Uri.parse(
                  'https://apps.apple.com/tw/app/airsync-sender/id6453759985')));
            }
          },
          // Can not use V3AutoHyphenatingText
          child: Text(S.of(context).main_notice_positive_button),
        ),
      ],
    );
  }
}
