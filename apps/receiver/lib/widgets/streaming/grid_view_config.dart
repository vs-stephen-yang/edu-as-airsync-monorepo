import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/widgets/v3_streaming_expandable.dart';
import 'package:flutter/material.dart';

import 'streaming_view_config.dart';

final gridViewConfig = StreamingViewConfig(
  mode: StreamingLayoutMode.grid,
  adjustSplitCount: (count) {
    // 不能大於裝置的分割max
    if (count >= HybridConnectionList.maxHybridSplitScreen) {
      return HybridConnectionList.maxHybridSplitScreen;
    }
    if (count == 7) return count + 2;
    if ([3, 5, 8].contains(count)) return count + 1;
    return count;
  },
  buildPageHeaderFooter: (_, __, ___) {
    return const Positioned(
      left: 13,
      bottom: 8,
      child: ExpandableWidget(),
    );
  },
  positionCalculator: ({
    required int index,
    required int count,
    required int? enlarged,
    required Size screenSize,
    required int pageIndex,
  }) {
    final fullW = screenSize.width;
    final fullH = screenSize.height;
    final halfW = fullW / 2;
    final halfH = fullH / 2;
    final thirdW = fullW / 3;
    final thirdH = fullH / 3;

    if (enlarged != null) {
      return enlarged == index
          ? LayoutPosition(left: 0, top: 0, width: fullW, height: fullH)
          : LayoutPosition.zero();
    }

    if (count == 1) {
      return LayoutPosition(left: 0, top: 0, width: fullW, height: fullH);
    } else if (count <= 2) {
      return index == 1
          ? LayoutPosition(right: 0, top: 0, width: halfW, height: fullH)
          : LayoutPosition(left: 0, top: 0, width: halfW, height: fullH);
    } else if (count <= 4) {
      final grid = [Offset(0, 0), Offset(1, 0), Offset(0, 1), Offset(1, 1)];
      return LayoutPosition.fromGrid(
        cell: grid[index],
        cellW: halfW,
        cellH: halfH,
      );
    } else if (count <= 6) {
      final grid = [
        Offset(0, 0),
        Offset(1, 0),
        Offset(2, 0),
        Offset(0, 1),
        Offset(1, 1),
        Offset(2, 1),
      ];
      return LayoutPosition.fromGrid(
        cell: grid[index],
        cellW: thirdW,
        cellH: halfH,
      );
    } else {
      final grid = [
        Offset(0, 0),
        Offset(1, 0),
        Offset(2, 0),
        Offset(0, 1),
        Offset(1, 1),
        Offset(2, 1),
        Offset(0, 2),
        Offset(1, 2),
        Offset(2, 2),
      ];
      return LayoutPosition.fromGrid(
        cell: grid[index],
        cellW: thirdW,
        cellH: thirdH,
      );
    }
  },
);
