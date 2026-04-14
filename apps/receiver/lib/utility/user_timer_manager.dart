import 'dart:async';

enum ConnectionType {
  webrtc,
  airplay,
  airplayWithPin,
  googlecast,
  miracast,
}

class UserTimer {
  final String id;
  final String deviceName;
  final ConnectionType connectionType;
  final int totalSeconds;
  int remainingSeconds;
  Timer? timer;

  UserTimer({
    required this.id,
    required this.deviceName,
    required this.connectionType,
    required this.totalSeconds,
  }) : remainingSeconds = totalSeconds;

  double get progress => remainingSeconds / totalSeconds;

  void start(Function(String) onTimeout) {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingSeconds--;
      if (remainingSeconds <= 0) {
        timer.cancel();
        onTimeout(id);
      }
    });
  }

  void cancel() {
    timer?.cancel();
    timer = null;
  }

  void reset() {
    remainingSeconds = totalSeconds;
  }
}

class UserTimerManager {
  final Map<String, UserTimer> _userTimers = {};
  String? _currentDisplayTimerId;

  // 回調函數
  Function(double progress, int remainingSeconds)? onProgressUpdate;
  Function(String userId)? onUserTimeout;

  // 倒數時間配置
  static const Map<ConnectionType, int> _timeoutConfig = {
    ConnectionType.webrtc: 10,
    ConnectionType.airplay: 10,
    ConnectionType.airplayWithPin: 40,
    ConnectionType.googlecast: 10,
    ConnectionType.miracast: 10,
  };

  // 添加用戶計時器
  void addUser({
    required String id,
    required String deviceName,
    required ConnectionType connectionType,
  }) {
    // 如果用戶已存在，不要重置，直接返回
    if (_userTimers.containsKey(id)) {
      return; // 保持現有的倒數進度
    }

    final totalSeconds = _timeoutConfig[connectionType]!;
    final userTimer = UserTimer(
      id: id,
      deviceName: deviceName,
      connectionType: connectionType,
      totalSeconds: totalSeconds,
    );

    _userTimers[id] = userTimer;
    userTimer.start(_handleUserTimeout);

    _updateDisplayTimer();
    _ensureProgressUpdaterRunning();
  }

  // 新增：專門用於重置用戶計時器的方法
  void resetUser(String id) {
    final userTimer = _userTimers[id];
    if (userTimer != null) {
      userTimer.cancel();
      userTimer.reset();
      userTimer.start(_handleUserTimeout);

      // 如果重置的是當前顯示的用戶，延遲更新進度顯示
      if (_currentDisplayTimerId == id) {
        Future.microtask(() {
          onProgressUpdate?.call(
              userTimer.progress, userTimer.remainingSeconds);
        });
      }
    }
  }

  // 移除用戶計時器
  void removeUser(String id) {
    final userTimer = _userTimers[id];
    if (userTimer != null) {
      userTimer.cancel();
      _userTimers.remove(id);

      // 如果移除的是當前顯示的計時器，需要 fallback
      if (_currentDisplayTimerId == id) {
        _updateDisplayTimer();
      }
    }
  }

  // 更新顯示的計時器（選擇剩餘時間最長的）
  void _updateDisplayTimer() {
    if (_userTimers.isEmpty) {
      _currentDisplayTimerId = null;
      // 延遲調用回調，避免在 build 過程中觸發
      Future.microtask(() {
        onProgressUpdate?.call(0.0, 0);
      });
      return;
    }

    // 找到剩餘時間最長的用戶
    String? longestId;
    int maxRemainingTime = -1; // 改為 -1 確保能找到 0 秒的情況

    for (final entry in _userTimers.entries) {
      if (entry.value.remainingSeconds > maxRemainingTime) {
        maxRemainingTime = entry.value.remainingSeconds;
        longestId = entry.key;
      }
    }

    // 只有當顯示的用戶真的改變時才更新
    if (_currentDisplayTimerId != longestId) {
      _currentDisplayTimerId = longestId;

      if (longestId != null) {
        final timer = _userTimers[longestId]!;
        // 延遲調用回調，避免在 build 過程中觸發
        Future.microtask(() {
          onProgressUpdate?.call(timer.progress, timer.remainingSeconds);
        });
      }
    }
  }

  // 處理用戶超時
  void _handleUserTimeout(String userId) {
    removeUser(userId);
    onUserTimeout?.call(userId);
  }

  // 啟動進度更新器
  Timer? _progressUpdateTimer;

  void _startProgressUpdater() {
    // 如果已經在運行，就不要重新啟動
    if (_progressUpdateTimer != null && _progressUpdateTimer!.isActive) {
      return;
    }

    _progressUpdateTimer?.cancel();
    _progressUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_userTimers.isEmpty) {
        timer.cancel();
        return;
      }

      if (_currentDisplayTimerId != null) {
        final currentTimer = _userTimers[_currentDisplayTimerId];
        if (currentTimer != null) {
          // 🔧 關鍵修復：直接使用當前用戶的實際進度
          onProgressUpdate?.call(
              currentTimer.progress, currentTimer.remainingSeconds);
        }
      }
    });
  }

  // 確保進度更新器運行
  void _ensureProgressUpdaterRunning() {
    if (_userTimers.isNotEmpty &&
        (_progressUpdateTimer == null || !_progressUpdateTimer!.isActive)) {
      _startProgressUpdater();
    }
  }

  // 停止進度更新器
  void _stopProgressUpdater() {
    _progressUpdateTimer?.cancel();
    _progressUpdateTimer = null;
  }

  // 清空所有計時器
  void clearAll() {
    for (final timer in _userTimers.values) {
      timer.cancel();
    }
    _userTimers.clear();
    _currentDisplayTimerId = null;
    _stopProgressUpdater();
    onProgressUpdate?.call(0.0, 0);
  }

  // 獲取當前顯示的計時器信息
  UserTimer? get currentDisplayTimer {
    if (_currentDisplayTimerId != null) {
      return _userTimers[_currentDisplayTimerId];
    }
    return null;
  }

  // 獲取所有用戶計時器
  Map<String, UserTimer> get allTimers => Map.unmodifiable(_userTimers);

  // 檢查是否有用戶
  bool get hasUsers => _userTimers.isNotEmpty;

  // 獲取用戶數量
  int get userCount => _userTimers.length;

  // 根據 MirrorType 字符串確定 ConnectionType
  static ConnectionType getConnectionTypeFromString(String mirrorType,
      {bool hasPin = false}) {
    switch (mirrorType.toLowerCase()) {
      case 'airplay':
        return hasPin ? ConnectionType.airplayWithPin : ConnectionType.airplay;
      case 'googlecast':
        return ConnectionType.googlecast;
      case 'miracast':
        return ConnectionType.miracast;
      default:
        return ConnectionType.airplay; // 默認值
    }
  }

  // 為 WebRTC 請求獲取 ConnectionType
  static ConnectionType getWebRTCConnectionType() {
    return ConnectionType.webrtc;
  }
}
