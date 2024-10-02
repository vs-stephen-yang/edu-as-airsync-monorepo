import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/pref_language_provider.dart';
import 'package:display_cast_flutter/utilities/web_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3WebMain extends StatelessWidget {
  const V3WebMain({super.key, this.scrollTo});

  final Function()? scrollTo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 700,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Row(
            children: [
              if (isBigThan1024(context))
                Container(
                  width: 460,
                  color: const Color(0xFFEDEEF3),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/images/ic_web_connection.png'),
                    ],
                  ),
                ),
              Expanded(
                child: Container(
                  color: context.tokens.color.vsdslColorSurface100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        top: 21,
                        right: 40,
                        child: Row(
                          children: [
                            const LanguageShowMenu(),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 5.0,
                                shadowColor:
                                    context.tokens.color.vsdslColorSecondary,
                                foregroundColor: context
                                    .tokens.color.vsdslColorOnSurfaceInverse,
                                backgroundColor:
                                    context.tokens.color.vsdslColorSecondary,
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              onPressed: () {
                                scrollTo?.call();
                              },
                              child:
                                  AutoSizeText(S.of(context).v3_main_download),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            left: 40,
            top: 16,
            child: Image(
              image: Svg('assets/images/ic_logo_airsync.svg'),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageShowMenu extends StatelessWidget {
  const LanguageShowMenu({super.key});

  // This method shows a custom dropdown (using showMenu)
  void _showCustomDropdown(BuildContext context) async {
    PrefLanguageProvider prefLanguageProvider =
        Provider.of<PrefLanguageProvider>(context, listen: false);

    // Get the size and position of the button (for dropdown placement)
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    // Calculate the position of the dropdown
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, button.size.height), ancestor: overlay),
        // Lower than the button
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    // Show the menu below the button
    String? newValue = await showMenu<String>(
      context: context,
      position: position,
      color: context.tokens.color.vsdslColorSurface100,
      items: prefLanguageProvider.localeMap.entries.map((entry) {
        return PopupMenuItem<String>(
          value: entry.key,
          child: Container(
            width: 116,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: (entry.key == prefLanguageProvider.language)
                  ? context.tokens.color.vsdslColorTertiary
                  : context.tokens.color.vsdslColorSurface100,
            ),
            alignment: Alignment.centerLeft,
            child: Text(entry.key),
          ),
        );
      }).toList(),
    );

    // If a new language was selected, update the state
    if (newValue != null) {
      prefLanguageProvider.setLanguage(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    PrefLanguageProvider prefLanguageProvider =
        Provider.of<PrefLanguageProvider>(context, listen: false);
    return GestureDetector(
      onTap: () => _showCustomDropdown(context),
      child: Row(
        children: [
          const Icon(Icons.language, size: 16),
          const SizedBox(width: 8),
          AutoSizeText(prefLanguageProvider.language),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down_sharp),
        ],
      ),
    );
  }
}
