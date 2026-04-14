import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/utility/navigation_service_util.dart';
import 'package:display_flutter/widgets/resizable_draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

class V3GroupHostView extends StatefulWidget {
  const V3GroupHostView({super.key});

  @override
  State<StatefulWidget> createState() => _V3GroupHostViewState();
}

class _V3GroupHostViewState extends State<V3GroupHostView> {
  @override
  Widget build(BuildContext context) {
    final mirrorStateProvider =
        Provider.of<MirrorStateProvider>(context, listen: false);

    return Consumer<ChannelProvider>(
      builder: (context, provider, child) {
        final videoView = provider.displayGroupVideoView;
        if (!provider.isDisplayGroupVideoAvailable || videoView == null) {
          return const SizedBox.shrink();
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navService.dismissRegisteredDialogs();

            if (provider.displayGroupVideoView != null &&
                provider.isDisplayGroupVideoAvailable) {
              HybridConnectionList().removeAllPresenters();
              mirrorStateProvider.stopAllMirror();
              if (provider.isSenderMode) {
                provider.removeSender(fromSender: true);
              }
              if (provider.isGroupMode) {
                provider.removeSender(fromGroup: true);
              }
              if (ChannelProvider.isModeratorMode) {
                provider.setModeratorMode(false);
              }
            }
          });
        }
        bool audioEnabled = provider.isDisplayGroupAudioEnabled;

        return FocusScope(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.tokens.color.vsdslColorSuccess,
                    width: 4.0,
                  ),
                  color: Colors.black,
                ),
                child: provider.displayGroupVideoView,
              ),
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 4,
                      color: context.tokens.color.vsdslColorSuccess,
                    ),
                  ),
                ),
              ),
              ResizableDraggableWidget(
                halfScreen: MediaQuery.of(context).size.width / 2,
                text:
                    '${S.of(context).v3_group_receive_view_status_from} ${provider.displayGroupHostName}',
                // TODO: test onMute function when unblock Cast to Board onMute
                onMute: provider.displayGroupOnMute,
                onStop: () {
                  provider.stopReceivedFromHost(
                      closeReason: 'member click stop');
                  mirrorStateProvider.restartMirror();
                },
                isMute: !audioEnabled,
              ),
              IgnorePointer(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 4,
                          color: context.tokens.color.vsdslColorSuccess,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
