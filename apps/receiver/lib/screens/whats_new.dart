import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/widgets/focus_single_child_scroll_view.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:flutter/material.dart';

class WhatsNew extends StatefulWidget {
  const WhatsNew({super.key});

  @override
  State createState() => _WhatsNewState();
}

class _WhatsNewState extends State<WhatsNew> {
  @override
  Widget build(BuildContext context) {
    return MenuDialog(
      backgroundColor: HybridConnectionList().isPresenting()
          ? AppColors.primary_grey_tran
          : AppColors.primary_grey,
      topTitleText: S.of(context).main_whats_new_title,
      content: FocusSingleChildScrollView(
          textContent: S.of(context).main_whats_new_content),
    );
  }
}
