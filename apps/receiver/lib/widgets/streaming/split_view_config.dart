import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/widgets/streaming/vertical_page_indicator.dart';
import 'package:flutter/material.dart';

import 'streaming_view_config.dart';

final splitViewConfig = StreamingViewConfig(
  mode: StreamingLayoutMode.split,
  dotCount: 2,
  adjustSplitCount: (count) {
    // 不能大於裝置的分割max
    if (count >= HybridConnectionList.maxHybridSplitScreen) {
      return HybridConnectionList.maxHybridSplitScreen;
    }
    if (count == 1) return count;
    if (count % 2 != 0) return count + 1;
    return count;
  },
  buildPageHeaderFooter: (pageIndex, dotCount, onNextPressed) {
    return Positioned(
      right: 5.33,
      bottom: 8,
      child: VerticalPageIndicator(
        pageIndex: pageIndex,
        dotCount: dotCount,
        onNextPressed: onNextPressed,
      ),
    );
  },

  /// 計算每個項目的位置與尺寸
  positionCalculator: ({
    required int index,
    required int count,
    required int? enlarged,
    required Size screenSize,
    required int pageIndex,
  }) {
    const maxColumnSize = 2;

    final fullW = screenSize.width;
    final fullH = screenSize.height;
    final halfW = fullW / maxColumnSize;
    if (count == 1) {
      return LayoutPosition(left: 0, top: 0, width: fullW, height: fullH);
    }
    if (enlarged != null) {
      return enlarged == index
          ? LayoutPosition(left: 0, top: 0, width: fullW, height: fullH)
          : LayoutPosition.zero();
    }

    final listStart = pageIndex * maxColumnSize;
    final listEnd = listStart + 1;
    if (index < listStart || index > listEnd) {
      return LayoutPosition.zero();
    }

    final position = index % maxColumnSize;

    return LayoutPosition(
      left: position == 0 ? 0 : halfW,
      top: 0,
      width: halfW,
      height: fullH,
    );
  },
);
