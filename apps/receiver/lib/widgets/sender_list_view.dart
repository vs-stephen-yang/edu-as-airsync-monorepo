
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/sender_item.dart';
import 'package:flutter/material.dart';

class SenderListView extends StatefulWidget {
  const SenderListView(this.editMode, {super.key});
  final bool editMode;

  @override
  State createState() => _SenderListViewState();
}

class _SenderListViewState extends State<SenderListView> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: !ChannelProvider.isSenderMode || ChannelProvider.remoteScreenConnectors.isEmpty
          ? Container(
              alignment: Alignment.center,
              child: Text(
                'Up to 10 receivers can join.',
                style: const TextStyle(color: AppColors.toggle_bg),
              ),
            )
          : ListView.separated(
              itemCount: ChannelProvider.remoteScreenConnectors.length,
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