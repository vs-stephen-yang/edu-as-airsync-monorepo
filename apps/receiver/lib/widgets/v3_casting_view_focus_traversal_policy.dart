import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

/// - `←` / `→`： 選擇水平方向距離最近的按鈕（歐幾里得距離）
/// - `↑` / `↓`：優先選擇 **X 軸最接近** 且符合方向的按鈕，否則選擇歐幾里得距離最短的
class CastingViewFocusTraversalPolicy extends ReadingOrderTraversalPolicy {
  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    super.inDirection(currentNode, direction);
    final FocusScopeNode nearestScope = currentNode.nearestScope!;
    final Rect currentRect = currentNode.rect;

    final Iterable<FocusNode> allNodes = nearestScope.traversalDescendants;

    // 過濾掉自己，避免選到自己
    final Iterable<FocusNode> filteredNodes =
        allNodes.where((node) => node != currentNode);

    FocusNode? nextNode;

    if (direction == TraversalDirection.left ||
        direction == TraversalDirection.right) {
      nextNode =
          _findClosestHorizontally(currentRect, filteredNodes, direction);
    } else if (direction == TraversalDirection.up ||
        direction == TraversalDirection.down) {
      nextNode = _findClosestVertically(currentRect, filteredNodes, direction);
    }

    if (nextNode != null) {
      requestFocusCallback(nextNode);
      return true;
    }

    return false;
  }

  FocusNode? _findClosestHorizontally(Rect currentRect,
      Iterable<FocusNode> candidates, TraversalDirection direction) {
    FocusNode? closestNode;
    double minDistance = double.infinity;
    List<FocusNode> strictYAlignedNodes = [];
    List<FocusNode> relaxedYAlignedNodes = [];

    for (final FocusNode node in candidates) {
      final Rect nodeRect = node.rect;

      bool isValid = direction == TraversalDirection.left
          ? nodeRect.right <= currentRect.left
          : nodeRect.left >= currentRect.right;

      if (!isValid) continue;

      // 計算與 Y 軸的距離
      double yDistance = (nodeRect.center.dy - currentRect.center.dy).abs();

      // Y 軸 有些許誤差對齊者, 50 為下排 widget 的容忍高度
      if (yDistance < 50.0) {
        strictYAlignedNodes.add(node);
      } else {
        relaxedYAlignedNodes.add(node);
      }
    }

    // 如果有些許誤差對齊者，則選擇 Y 軸距離最短的
    if (strictYAlignedNodes.isNotEmpty) {
      for (final FocusNode node in strictYAlignedNodes) {
        double xDistance = (node.rect.center.dx - currentRect.center.dx).abs();
        double yDistance = (node.rect.center.dy - currentRect.center.dy).abs();
        double euclideanDistance = (xDistance * xDistance) +
            (yDistance * yDistance); // 省略 sqrt 來避免浮點計算開銷

        if (euclideanDistance < minDistance) {
          minDistance = euclideanDistance;
          closestNode = node;
        }
      }
      return closestNode;
    }

    // 如果沒有對齊的節點，則選擇 Y 軸符合的最短歐幾里得距離
    if (relaxedYAlignedNodes.isNotEmpty) {
      for (final FocusNode node in relaxedYAlignedNodes) {
        double xDistance = (node.rect.center.dx - currentRect.center.dx).abs();
        double yDistance = (node.rect.center.dy - currentRect.center.dy).abs();
        double euclideanDistance =
            (xDistance * xDistance) + (yDistance * yDistance);

        if (euclideanDistance < minDistance) {
          minDistance = euclideanDistance;
          closestNode = node;
        }
      }
      return closestNode;
    }

    return closestNode;
  }

  FocusNode? _findClosestVertically(Rect currentRect,
      Iterable<FocusNode> candidates, TraversalDirection direction) {
    FocusNode? closestNode;
    double minDistance = double.infinity;
    double minXDistance = double.infinity;
    List<FocusNode> xAlignedNodes = [];

    for (final FocusNode node in candidates) {
      final Rect nodeRect = node.rect;

      bool isValid;
      if (direction == TraversalDirection.up) {
        isValid = nodeRect.bottom <= currentRect.top;
      } else {
        isValid = nodeRect.top >= currentRect.bottom;
      }
      if (!isValid) continue;

      double xDistance = (nodeRect.center.dx - currentRect.center.dx).abs();

      // 優先挑選 X 軸距離最小的
      if (xDistance < minXDistance) {
        minXDistance = xDistance;
        xAlignedNodes = [node];
      } else if (xDistance == minXDistance) {
        xAlignedNodes.add(node);
      }
    }

    //  如果有 X 軸對齊的節點，選擇 Y 軸距離最短的
    if (xAlignedNodes.isNotEmpty) {
      for (final FocusNode node in xAlignedNodes) {
        final Rect nodeRect = node.rect;
        double distance = _euclideanDistance(
          Offset(currentRect.center.dx, currentRect.center.dy),
          Offset(nodeRect.center.dx, nodeRect.center.dy),
        );

        if (distance < minDistance) {
          minDistance = distance;
          closestNode = node;
        }
      }
      return closestNode;
    }

    // 如果沒有 X 軸對齊的，則選擇 Y 軸符合的最短歐幾里得距離
    for (final FocusNode node in candidates) {
      final Rect nodeRect = node.rect;

      bool isValid;
      if (direction == TraversalDirection.up) {
        isValid = nodeRect.bottom <= currentRect.top;
      } else {
        isValid = nodeRect.top >= currentRect.bottom;
      }
      if (!isValid) continue;

      double distance = _euclideanDistance(
        Offset(currentRect.center.dx, currentRect.center.dy),
        Offset(nodeRect.center.dx, nodeRect.center.dy),
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestNode = node;
      }
    }

    return closestNode;
  }

  double _euclideanDistance(Offset p1, Offset p2) {
    final dx = p1.dx - p2.dx;
    final powDx = math.pow(dx, 2);
    final dy = p1.dy - p2.dy;
    final powDy = math.pow(dy, 2);
    return math.sqrt(powDx + powDy);
  }
}
