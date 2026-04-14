import 'dart:async';

import 'package:display_flutter/utility/bounded_list.dart';
import 'package:display_flutter/utility/log.dart';

enum ZeroFpsDetectorState {
  normal, // 正常狀態
  waitingUserConfirm, // 等待用戶確認
  recreating, // 重建中
  observing, // 觀察期（recreate 完成後）
}

class ZeroFpsDetector {
  ZeroFpsDetectorState _state = ZeroFpsDetectorState.normal;

  int _autoRecreateAttempts = 0;
  final int _maxAutoRecreateAttempts;

  // FPS 檢測相關
  final BoundedList<int> _fpsHistory;
  final int _zeroFpsDetectLength; // 連續幾個 0 FPS 視為異常

  bool _isDisposed = false;

  // 回調函數
  final void Function()? onZeroFpsNotify;
  final Future<bool> Function()? onAutoRecreate;
  final void Function()? onRecreateSuccess;
  final void Function()? onRecreateFailure;

  ZeroFpsDetector({
    this.onZeroFpsNotify,
    this.onAutoRecreate,
    this.onRecreateSuccess,
    this.onRecreateFailure,
    int? maxAutoRecreateAttempts,
    int? zeroFpsDetectLength,
  })  : _maxAutoRecreateAttempts = maxAutoRecreateAttempts ?? 3,
        _zeroFpsDetectLength = zeroFpsDetectLength ?? 2,
        _fpsHistory = BoundedList<int>(zeroFpsDetectLength ?? 2);

  ZeroFpsDetectorState get state => _state;

  int get autoRecreateAttempts => _autoRecreateAttempts;

  /// 接收 FPS stats，detector 內部判斷
  void onFpsStatsReceived(int fps) {
    if (_isDisposed) return;

    _fpsHistory.add(fps);

    log.info(
        'ZeroFpsDetector: received FPS=$fps, state=$_state, history=${_fpsHistory.elements}');

    // 如果在觀察期且收到正常 FPS，立即視為成功
    if (_state == ZeroFpsDetectorState.observing && fps > 0) {
      log.info(
          'ZeroFpsDetector: received normal FPS during observation, recreate succeeded');
      _onRecreateSucceeded();
      return;
    }

    // 檢查連續 zero FPS
    final elements = _fpsHistory.elements;
    final isZeroFps = elements.isNotEmpty &&
        elements.length == _zeroFpsDetectLength &&
        elements.take(_zeroFpsDetectLength).every((f) => f == 0);

    if (isZeroFps) {
      _onZeroFpsDetected();
    }
  }

  void _onZeroFpsDetected() {
    log.warning('ZeroFpsDetector: zero FPS detected, state=$_state');

    switch (_state) {
      case ZeroFpsDetectorState.recreating:
        log.info('ZeroFpsDetector: ignoring zero FPS during recreation');
        return;

      case ZeroFpsDetectorState.observing:
        log.warning(
            'ZeroFpsDetector: zero FPS during observation, recreate failed');
        _onRecreateFailed();
        return;

      case ZeroFpsDetectorState.normal:
        log.info('ZeroFpsDetector: first zero FPS detected, notify listener');
        _state = ZeroFpsDetectorState.waitingUserConfirm;
        onZeroFpsNotify?.call();
        return;

      case ZeroFpsDetectorState.waitingUserConfirm:
        log.fine('ZeroFpsDetector: already waiting for user confirmation');
        return;
    }
  }

  void onUserConfirmRecreate() {
    log.info('ZeroFpsDetector: user confirmed recreate');
    _autoRecreateAttempts = 0;
    _triggerRecreate();
  }

  void _triggerRecreate() async {
    _state = ZeroFpsDetectorState.recreating;
    _autoRecreateAttempts++;
    _fpsHistory.clear(); // 清空 FPS 歷史
    log.info(
        'ZeroFpsDetector: triggering recreate (attempt $_autoRecreateAttempts/$_maxAutoRecreateAttempts)');

    if (onAutoRecreate != null) {
      final success = await onAutoRecreate!();

      if (_isDisposed) {
        log.info('ZeroFpsDetector: disposed during recreate, ignoring result');
        return;
      }

      _onRecreateOperationCompleted(success);
    }
  }

  void _onRecreateOperationCompleted(bool startSuccess) {
    log.info(
        'ZeroFpsDetector: recreate operation completed, startSuccess=$startSuccess');

    if (!startSuccess) {
      // start() 操作失敗
      _onRecreateFailed();
    } else {
      // start() 成功，進入觀察期
      _state = ZeroFpsDetectorState.observing;
      _fpsHistory.clear(); // 清空 FPS 歷史，重新收集
      log.info(
          'ZeroFpsDetector: entering observation period, waiting for normal FPS');
    }
  }

  void _onRecreateSucceeded() {
    log.info(
        'ZeroFpsDetector: recreate succeeded after $_autoRecreateAttempts attempts');
    reset();
    onRecreateSuccess?.call();
  }

  void _onRecreateFailed() {
    log.warning(
        'ZeroFpsDetector: recreate failed (attempt $_autoRecreateAttempts/$_maxAutoRecreateAttempts)');

    if (_autoRecreateAttempts < _maxAutoRecreateAttempts) {
      // 還可以再試
      log.info('ZeroFpsDetector: auto recreate again');
      _triggerRecreate();
    } else {
      // 達到最大嘗試次數
      log.warning('ZeroFpsDetector: max auto recreate attempts reached');
      onRecreateFailure?.call();
    }
  }

  void reset() {
    log.info('ZeroFpsDetector: reset');
    _state = ZeroFpsDetectorState.normal;
    _autoRecreateAttempts = 0;
    _fpsHistory.clear();
  }

  void dispose() {
    log.info('ZeroFpsDetector: dispose');
    _isDisposed = true;
    _fpsHistory.clear();
  }
}
