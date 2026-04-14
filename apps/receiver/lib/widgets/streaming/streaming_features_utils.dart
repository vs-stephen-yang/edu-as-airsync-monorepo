import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:flutter/material.dart';

/// 常數定義
class StreamingFeaturesConstants {
  /// 縮小模式尺寸
  static const double collapsedSize = 48.0;

  /// 螢幕邊界 padding（貼齊左邊）
  static const double screenEdgePadding = 0.0;

  /// 垂直拖曳安全距離（距離螢幕上下邊）
  static const double verticalSafeMargin = 13.0;

  /// 展開模式主體寬度（參考 V3FeatureSet 的 featureWidth）
  static const double expandedMainWidth = 40.0;

  /// 展開模式功能按鈕高度（參考 V3FeatureSet 單個功能的高度）
  static const double expandedButtonHeight = 48.5;

  /// 按鈕之間的分隔線高度
  static const double dividerHeight = 1.0;

  /// Badge 需要的額外寬度
  static const double badgeExtraWidth = 11.0;

  /// 對話框與 widget 的水平間距（避免擋住 badge）
  static const double dialogHorizontalSpacing = 20.0;

  /// 圓角半徑（只有右側）
  static const double borderRadius = 20.0;
}

/// 判斷是否為緊湊模式（響應式隱藏條件）
///
/// 隱藏條件：
/// - 多視窗模式下且寬度比例 ≤ 預設浮動視窗比例
/// - 或高度比例 < 1/3 全螢幕高度
bool isCompactMode(BuildContext context) {
  return context.isInMultiWindow &&
          context.splitScreenRatio.widthFraction <=
              SplitScreenRatio.floatingDefault.widthFraction ||
      context.splitScreenRatio.heightFraction <
          SplitScreenRatio.oneThirdFull.heightFraction;
}

/// 垂直拖曳位置限制（clamp）
///
/// 限制範圍：[top + margin, bottom - margin]
///
/// [yPosition] 當前 y 座標
/// [screenHeight] 螢幕高度
/// [widgetHeight] widget 高度
/// [margin] 安全邊距（預設為 verticalSafeMargin）
double clampVerticalPosition({
  required double yPosition,
  required double screenHeight,
  required double widgetHeight,
  double margin = StreamingFeaturesConstants.verticalSafeMargin,
}) {
  final minY = margin;
  final maxY = screenHeight - widgetHeight - margin;
  return yPosition.clamp(minY, maxY);
}

/// 對話框定位計算（用於 Moderator / Shortcuts）
///
/// 規則：
/// 1. 對話框的垂直中心點對齊 widget 的垂直中心點
/// 2. 對話框顯示在 widget 右側，水平間距為 [horizontalSpacing]
/// 3. 對話框必須完整落在安全範圍內：[margin, screenHeight - margin]
///
/// 返回：Offset(left, top)
Offset calculateDialogPosition({
  required Offset widgetPosition,
  required Size widgetSize,
  required Size dialogSize,
  required Size screenSize,
  double margin = StreamingFeaturesConstants.verticalSafeMargin,
  double horizontalSpacing = StreamingFeaturesConstants.dialogHorizontalSpacing,
}) {
  // Widget 的垂直中心點
  final widgetCenterY = widgetPosition.dy + widgetSize.height / 2;

  // 理想的對話框 top（使其中心點對齊）
  final idealTop = widgetCenterY - dialogSize.height / 2;

  // Clamp 到安全範圍
  final minTop = margin;
  final maxTop = screenSize.height - dialogSize.height - margin;

  // 確保 maxTop >= minTop，避免 clamp 錯誤
  final safeMaxTop = maxTop < minTop ? minTop : maxTop;
  final clampedTop = idealTop.clamp(minTop, safeMaxTop);

  // 對話框顯示在 widget 右側
  final left = widgetPosition.dx + widgetSize.width + horizontalSpacing;

  return Offset(left, clampedTop);
}

/// 對話框定位計算器（從中心點計算版本）
///
/// 用於已知 widget centerY 的情況
Offset calculateDialogPositionFromCenter({
  required double widgetCenterY,
  required double widgetRight,
  required Size dialogSize,
  required double screenHeight,
  double margin = StreamingFeaturesConstants.verticalSafeMargin,
  double horizontalSpacing = StreamingFeaturesConstants.dialogHorizontalSpacing,
}) {
  // 理想的對話框 top（使其中心點對齊）
  final idealTop = widgetCenterY - dialogSize.height / 2;

  // Clamp 到安全範圍
  final minTop = margin;
  final maxTop = screenHeight - dialogSize.height - margin;

  // 確保 maxTop >= minTop，避免 clamp 錯誤
  final safeMaxTop = maxTop < minTop ? minTop : maxTop;
  final clampedTop = idealTop.clamp(minTop, safeMaxTop);

  // 對話框顯示在 widget 右側
  final left = widgetRight + horizontalSpacing;

  return Offset(left, clampedTop);
}
