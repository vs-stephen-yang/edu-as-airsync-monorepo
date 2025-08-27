import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/widgets/streaming/vertical_page_indicator.dart';
import 'package:flutter/material.dart';

import 'streaming_view_config.dart';

final listViewConfig = StreamingViewConfig(
  mode: StreamingLayoutMode.list,
  dotCount: 3,
  adjustSplitCount: (count) {
    // 不能大於裝置的分割max
    if (count >= HybridConnectionList.maxHybridSplitScreen) {
      return count;
    }
    if ([1, 4, 7].contains(count)) return count + 2;
    if ([2, 5, 8].contains(count)) return count + 1;
    return count;
  },
  buildPageHeaderFooter: (pageIndex, dotCount, onNextPressed) {
    return Positioned(
      right: 53,
      bottom: 8,
      child: VerticalPageIndicator(
        pageIndex: pageIndex,
        dotCount: dotCount,
        onNextPressed: onNextPressed,
      ),
    );
  },
  positionCalculator: ({
    required int index,
    required int count,
    required int? enlarged,
    required Size screenSize,
    required int pageIndex,
  }) {
    const maxColumnSize = 3;
    final fullW = screenSize.width;
    final fullH = screenSize.height;
    final thirdH = fullH / maxColumnSize;

    if (enlarged != null) {
      return enlarged == index
          ? LayoutPosition(left: 0, top: 0, width: fullW, height: fullH)
          : LayoutPosition.zero();
    }

    final listStart = pageIndex * maxColumnSize;
    final listEnd = listStart + 2;
    if (index < listStart || index > listEnd) {
      return LayoutPosition.zero();
    }

    final position = index % maxColumnSize;
    return LayoutPosition(
      left: 0,
      top: position * thirdH,
      width: fullW,
      height: thirdH,
    );
  },
);
