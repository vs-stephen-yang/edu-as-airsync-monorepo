package com.viewsonic.miracast.net;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import org.junit.jupiter.api.BeforeEach;
import org.mockito.InOrder;
import org.mockito.Mockito;
import org.junit.jupiter.api.Test;

public class TimerSchedulerTest {
  private TimerScheduler ts;
  private Runnable task1, task2, task3;

  @BeforeEach
  public void setUp() {
    ts = new TimerScheduler();

    task1 = Mockito.mock(Runnable.class);
    task2 = Mockito.mock(Runnable.class);
    task3 = Mockito.mock(Runnable.class);
  }

  @Test
  public void schedule_ExpiredTimer_TaskShouldRun() {
    // Arrange
    ts.setTimer(task1, 100);

    // Act
    ts.schedule(101);

    // Assert
    verify(task1, times(1)).run();
  }

  @Test
  public void schedule_EarlyTimer_TaskShouldNotRun() {
    // Arrange
    ts.setTimer(task1, 100);

    // Act
    ts.schedule(99);

    // Assert
    verify(task1, never()).run();
  }

  @Test
  public void schedule_MultipleTimers_ShouldRunInOrder() {
    // Arrange
    ts.setTimer(task1, 100);
    ts.setTimer(task2, 110);
    ts.setTimer(task3, 120);

    InOrder inOrder = inOrder(task1, task2, task3);

    // Act
    ts.schedule(100);
    ts.schedule(110);
    ts.schedule(120);

    // Assert
    inOrder.verify(task1).run();
    inOrder.verify(task2).run();
    inOrder.verify(task3).run();
  }

  @Test
  public void schedule_RemovedTimer_TaskShouldNotRun() {
    // Arrange
    Object t = ts.setTimer(task1, 100);
    ts.clearTimer(t);

    // Act
    ts.schedule(100);

    // Assert
    verify(task1, never()).run();
  }

  @Test
  public void schedule_RemovedOneTimer_OtherTaskShouldRun() {
    // Arrange
    Object t1 = ts.setTimer(task1, 100);
    ts.setTimer(task2, 100);
    ts.clearTimer(t1);

    // Act
    ts.schedule(100);

    // Assert
    verify(task1, never()).run();
    verify(task2, times(1)).run();
  }

  @Test
  public void nextTimeoutMs_EarlyTimer_ShouldReturnValidTimeout() {
    // Arrange
    ts.setTimer(task1, 100);

    // Act
    long actual = ts.nextTimeoutMs(33, 1000);

    // Assert
    assertEquals(67, actual);
  }

  @Test
  public void nextTimeoutMs_EmptyTimer_ShouldReturnDefault() {
    // Arrange

    // Act
    long actual = ts.nextTimeoutMs(100, 2000);

    // Assert
    assertEquals(2000, actual);
  }
}
