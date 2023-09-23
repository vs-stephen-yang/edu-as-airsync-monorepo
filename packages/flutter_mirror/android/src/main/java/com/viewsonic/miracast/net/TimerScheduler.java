package com.viewsonic.miracast.net;

import java.util.Comparator;
import java.util.PriorityQueue;

public class TimerScheduler {
  private static final int INITIAL_CAPACITY = 16;

  public static class Timer {
    public Runnable task_;
    public long timeMs_;

    Timer(Runnable task, long timeMs){
      task_= task;
      timeMs_ = timeMs;
    }
  }

  PriorityQueue<Timer> timers_ = new PriorityQueue<>(INITIAL_CAPACITY,
    new Comparator<Timer>() {
      @Override
      public int compare(Timer t1, Timer t2) {
          return Long.compare(t1.timeMs_, t2.timeMs_);
      }
  });

  public Object setTimer(Runnable task, long timeMs) {
    Timer timer = new Timer(task, timeMs);
    timers_.add(timer);

    return timer;
  }

  public void clearTimer(Object timer) {
    timers_.remove(timer);
  }

  public long nextTimeoutMs(long nowMs, long defaultTimeoutMs){
    if(timers_.isEmpty()) {
      return defaultTimeoutMs;
    }

    Timer earliestTimer = timers_.peek();
    long timeoutMs = earliestTimer.timeMs_ - nowMs;

    return Math.max(timeoutMs, 0);
  }

  public void schedule(long nowMs){
    while(!timers_.isEmpty()) {
      Timer earliestTimer = timers_.peek();

      if(earliestTimer.timeMs_ > nowMs){
          break;
      }
      timers_.poll();

      earliestTimer.task_.run();
    }
  }
}
