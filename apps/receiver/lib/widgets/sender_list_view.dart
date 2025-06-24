import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/sender_item.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SenderListView extends StatefulWidget {
  const SenderListView(this.editMode, {super.key});

  final bool editMode;

  @override
  State createState() => _SenderListViewState();
}

class _SenderListViewState extends State<SenderListView> {
  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: !channelProvider.isSenderMode ||
              channelProvider.remoteScreenConnectors.isEmpty
          ? Container(
              alignment: Alignment.center,
              child: V3AutoHyphenatingText(
                S.of(context).main_settings_share_to_sender_limit_desc,
                style: const TextStyle(color: AppColors.toggleBg),
              ),
            )
          : ListView.separated(
              itemCount: channelProvider.remoteScreenConnectors.length,
              itemBuilder: (BuildContext context, int index) {
                if (index > 10) return const SizedBox();
                return SenderItem(index: index, editMode: widget.editMode);
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(height: 0, color: Colors.transparent);
              },
            ),
    );
  }
}
