import 'package:display_cast_flutter/widgets/tool_language_selection.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ToolBar extends StatelessWidget {
  const ToolBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.cyan,
      padding: const EdgeInsets.fromLTRB(30, 30, 0, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ToolButton(
            icons: Icons.language,
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return const LanguageSelection();
                },
              );
            },
          ),
          ToolButton(
            icons: Icons.help_outline,
            onPressed: () {
              _launchUrl('https://myviewboard.com/support/zh-TW');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String link) async {
    Uri url = Uri.parse(link);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}

class ToolButton extends StatelessWidget {
  const ToolButton({super.key, this.icons, this.onPressed});

  final IconData? icons;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color.fromRGBO(0x59, 0x59, 0x59, 1),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icons,
            color: const Color.fromRGBO(0xBD, 0xBD, 0xBD, 1),
          ),
        ),
      ),
    );
  }
}
