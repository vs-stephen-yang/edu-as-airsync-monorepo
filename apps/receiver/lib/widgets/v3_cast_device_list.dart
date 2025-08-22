import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/v3_cast_device_item.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_help_center.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3CastDeviceList extends StatefulWidget {
  const V3CastDeviceList({super.key});

  @override
  State<V3CastDeviceList> createState() => _V3CastDeviceListState();
}

class _V3CastDeviceListState extends State<V3CastDeviceList> {
  static const int _pageSize = 8; // >10 時一頁只顯示 8 筆
  final ScrollController _scrollController = ScrollController();
  int _page = 0;
  bool? asc;

  @override
  void initState() {
    context.read<ChannelProvider>().restoreRemoteScreenConnectors();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goPrev() {
    if (_page > 0) {
      setState(() => _page--);
      _scrollController.jumpTo(0);
    }
  }

  void _goNext(int totalPages) {
    if (_page < totalPages - 1) {
      setState(() => _page++);
      _scrollController.jumpTo(0);
    }
  }

  void _onSort(ChannelProvider channelProvider) {
    if (asc == null) {
      asc = true;
    } else {
      asc = !asc!;
    }
    channelProvider.sortRemoteScreenConnectors(asc!);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.tokens.spacing;
    final colors = context.tokens.color;

    return Consumer<ChannelProvider>(
      builder: (_, channelProvider, __) {
        final total = channelProvider.remoteScreenConnectors.length;
        final bool showToolbar = total > 10;
        final int totalPages =
            showToolbar ? ((total + _pageSize - 1) ~/ _pageSize) : 1;

        // 保證 page 不會超出範圍（例如資料變動時）
        final int clampedPage =
            showToolbar ? _page.clamp(0, totalPages - 1) : 0;
        if (clampedPage != _page) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _page = clampedPage);
          });
        }

        final int start = showToolbar ? clampedPage * _pageSize : 0;
        final int end =
            showToolbar ? math.min(start + _pageSize, total) : total;
        final int visibleCount = math.max(end - start, 0);

        return Column(
          children: [
            AutoSizeText.rich(
              TextSpan(children: [
                TextSpan(
                  text: S.of(context).v3_cast_to_device_title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.vsdslColorOnSurface,
                  ),
                ),
                TextSpan(
                  text:
                      ' ($total/${channelProvider.maxRemoteScreenConnection})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: colors.vsdslColorOnSurface,
                  ),
                )
              ]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.vsdslSpacingXs.top),

            if (total == channelProvider.maxRemoteScreenConnection)
              AutoSizeText(
                S.of(context).v3_cast_to_device_reached_maximum,
                style: TextStyle(fontSize: 12, color: colors.vsdslColorWarning),
              ),

            SizedBox(height: spacing.vsdslSpacingXl.top),

            Expanded(
              child: total > 0
                  ? V3Scrollbar(
                      controller: _scrollController,
                      child: ListView.separated(
                        controller: _scrollController,
                        itemCount: visibleCount,
                        itemBuilder: (BuildContext context, int index) {
                          final int absoluteIndex = start + index;
                          final connector = channelProvider
                              .remoteScreenConnectors[absoluteIndex];
                          return V3CastDeviceItem(
                              key: ValueKey(connector.sessionId),
                              index: absoluteIndex);
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            height: spacing.vsdslSpacingMd.top,
                            color: Colors.transparent,
                          );
                        },
                      ),
                    )
                  : const Center(child: DeviceEmpty()),
            ),

            // 分頁工具列（當 total > 10 時顯示）
            if (showToolbar)
              _PagerBar(
                page: clampedPage,
                totalPages: totalPages,
                onPrev: _goPrev,
                onNext: () => _goNext(totalPages),
                onSort: () => _onSort(channelProvider),
                asc: asc ?? false,
              ),
            const Gap(10),
            Align(
              alignment: Alignment.centerLeft,
              child: V3HelpCenterWidget(),
            ),
          ],
        );
      },
    );
  }
}

class _PagerBar extends StatelessWidget {
  const _PagerBar({
    required this.page,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
    required this.onSort,
    required this.asc,
  });

  final int page;
  final int totalPages;
  final bool asc;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.color;

    final bool canPrev = page > 0;
    final bool canNext = page < totalPages - 1;
    final double progress = totalPages == 0 ? 0 : (page + 1) / totalPages;

    return Column(
      children: [
        // 進度條
        SizedBox(
          height: 4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colors.vsdslColorSurface200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0, 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.vsdslColorTertiary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(10),
        Row(
          children: [
            _RoundIconButton(
              label: S.of(context).v3_lbl_cast_device_previous,
              identifier: 'v3_qa_cast_device_previous',
              icon: Icon(
                Icons.chevron_left,
                size: 20,
                color: colors.vsdslColorOnSurface,
              ),
              enabled: canPrev,
              onPressed: canPrev ? onPrev : null,
            ),
            const Gap(8),
            _RoundIconButton(
              label: S.of(context).v3_lbl_cast_device_next,
              identifier: 'v3_qa_cast_device_next',
              icon: Icon(
                Icons.chevron_right,
                size: 20,
                color: colors.vsdslColorOnSurface,
              ),
              enabled: canNext,
              onPressed: canNext ? onNext : null,
            ),
            const Gap(20),
            Container(
              width: 1,
              height: 20,
              color: colors.vsdslColorOutline,
            ),
            const Gap(20),
            _RoundIconButton(
              label: asc
                  ? S.of(context).v3_lbl_cast_device_sort_asc
                  : S.of(context).v3_lbl_cast_device_sort_desc,
              identifier: asc
                  ? 'v3_qa_cast_device_sort_asc'
                  : 'v3_qa_cast_device_sort_desc',
              icon: Padding(
                padding: EdgeInsets.all(6),
                child: SvgPicture.asset(
                  asc
                      ? 'assets/images/ic_cast_device_asc.svg'
                      : 'assets/images/ic_cast_device_desc.svg',
                ),
              ),
              enabled: true,
              onPressed: onSort,
            ),
            const Gap(24),
          ],
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.enabled,
    this.onPressed,
    this.label,
    this.identifier,
  });

  final Widget icon;
  final bool enabled;
  final String? label;
  final String? identifier;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return V3Focus(
      label: label,
      identifier: identifier,
      child: Opacity(
        opacity: enabled ? 1 : 0.24,
        child: Material(
          color: context.tokens.color.vsdslColorSurface200,
          shape: const CircleBorder(),
          elevation: 0,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? onPressed : null,
            child: SizedBox(
              width: 32,
              height: 32,
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}

class DeviceEmpty extends StatelessWidget {
  const DeviceEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/images/ic_csat_device_empty.svg',
          excludeFromSemantics: true,
          width: 126,
          height: 110,
        ),
        const Gap(13),
        Text(
          S.of(context).v3_cast_to_device_list_msg,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.tokens.color.vsdslColorOnSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
