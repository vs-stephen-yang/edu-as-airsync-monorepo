import 'package:display_flutter/widgets/streaming/vertical_page_indicator.dart';
import 'package:flutter/material.dart';

import 'streaming_view_config.dart';

final singleViewConfig = StreamingViewConfig(
  mode: StreamingLayoutMode.single,
  dotCount: 1,
  adjustSplitCount: (count) => count,

  /// 建立分頁指示器（右下角）
  buildPageHeaderFooter: (pageIndex, dotCount, onNextPressed) {
    return Positioned(
      right: 5.33,
      bottom: 5.33,
      child: SingleViewIndicator(
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
    if (index != pageIndex) {
      return LayoutPosition.zero();
    }
    return LayoutPosition(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      width: screenSize.width,
      height: screenSize.height,
    );
  },
);
