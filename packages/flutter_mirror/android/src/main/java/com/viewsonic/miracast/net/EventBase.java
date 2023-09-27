package com.viewsonic.miracast.net;

import java.io.IOException;
import java.nio.channels.ClosedChannelException;
import java.nio.channels.SelectableChannel;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

public class EventBase {

  private Selector selector_;

  private Thread thread_;
  private volatile boolean isRunning_ = true;

  TimerScheduler timerScheduler_ = new TimerScheduler();

  // pending tasks
  private List<Runnable> pendingTasks_ = new ArrayList<>();
  private final Object mutex_ = new Object();

  public void init() throws IOException {
    selector_ = Selector.open();
  }

  public SelectionKey registerChannel(
      SelectableChannel channel,
      int ops,
      ChannelListener listener) throws ClosedChannelException {
    assert selector_ != null;
    assert thread_ == Thread.currentThread();

    return channel.register(selector_, ops, listener);
  }

  public Object setTimer(Runnable task, long timeoutMs) {
    assert selector_ != null;
    assert thread_ == Thread.currentThread();

    long nowMs = System.currentTimeMillis();
    return timerScheduler_.setTimer(task, nowMs + timeoutMs);
  }

  public void clearTimer(Object timer) {
    assert selector_ != null;
    assert thread_ == Thread.currentThread();

    timerScheduler_.clearTimer(timer);
  }

  // run the task in the selector's thread
  public void post(Runnable task) {
    assert selector_ != null;

    synchronized (mutex_) {
      pendingTasks_.add(task);
    }

    selector_.wakeup();
  }

  public void start() {
    assert selector_ != null;
    assert thread_ == null;

    isRunning_ = true;

    thread_ = new Thread(() -> {
      try {
        loop();
      } catch (IOException e) {
        e.printStackTrace();
      }
    });

    thread_.start();
  }

  public void stop() {
    assert thread_ != null;

    try {
      isRunning_ = false;

      thread_.join();
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
  }

  public void loop() throws IOException {
    while (isRunning_) {
      runStep();
    }
  }

  private void runStep() throws IOException {
    assert selector_ != null;

    final long DEFAULT_TIMEOUT_MS = 1000;

    long timeoutMs = timerScheduler_.nextTimeoutMs(System.currentTimeMillis(), DEFAULT_TIMEOUT_MS);

    // select() blocks until at least one channel is selected or wakeup() is invoked
    int numReadyChannels = selector_.select(timeoutMs);

    // handle timers
    timerScheduler_.schedule(System.currentTimeMillis());
    // handle pending tasks
    handlePendingTasks();

    if (numReadyChannels == 0) {
      return;
    }

    // handle ready operations
    handleReadyOperations();
  }

  // handle ready operations
  private void handleReadyOperations() {
    Set<SelectionKey> selectedKeys = selector_.selectedKeys();
    Iterator<SelectionKey> keyIterator = selectedKeys.iterator();

    while (keyIterator.hasNext()) {
      SelectionKey key = keyIterator.next();
      if (key.isValid()) {

        ChannelListener listener = (ChannelListener) key.attachment();

        listener.onOpsReady(key);
      }
      keyIterator.remove();
    }
  }

  // handle pending tasks
  private void handlePendingTasks() {
    List<Runnable> tasks;

    // swap pendingTasks_ and tasks variables
    synchronized (mutex_) {
      if (pendingTasks_.isEmpty()) {
        return;
      }

      tasks = pendingTasks_;
      pendingTasks_ = new ArrayList<>();
    }

    // run each task
    for (Runnable task : tasks) {
      try {
        task.run();
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
  }
}
