package com.viewsonic.miracast.net;

import java.util.PriorityQueue;

public class TimerScheduler {
  private static final int INITIAL_CAPACITY = 16;

  public static class Timer {
    public Runnable task_;
    public long timeMs_;

    Timer(Runnable task, long timeMs) {
      task_ = task;
      timeMs_ = timeMs;
    }
  }

  PriorityQueue<Timer> timers_ = new PriorityQueue<>(INITIAL_CAPACITY,
      (t1, t2) -> Long.compare(t1.timeMs_, t2.timeMs_));

  public Object setTimer(Runnable task, long timeMs) {
    Timer timer = new Timer(task, timeMs);
    timers_.add(timer);

    return timer;
  }

  public void clearTimer(Object timer) {
    assert timer instanceof Timer;

    timers_.remove((Timer)timer);
  }

  public long nextTimeoutMs(long nowMs, long defaultTimeoutMs) {
    Timer earliestTimer = timers_.peek();

    if (earliestTimer == null) {
      return defaultTimeoutMs;
    }

    long timeoutMs = earliestTimer.timeMs_ - nowMs;

    return Math.max(timeoutMs, 0);
  }

  public void schedule(long nowMs) {
    while (!timers_.isEmpty()) {
      Timer earliestTimer = timers_.peek();

      if (earliestTimer == null ||
          earliestTimer.timeMs_ > nowMs) {
        break;
      }
      timers_.poll();

      earliestTimer.task_.run();
    }
  }
}
