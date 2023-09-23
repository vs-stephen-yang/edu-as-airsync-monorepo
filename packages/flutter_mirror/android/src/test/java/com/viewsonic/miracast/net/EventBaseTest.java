package com.viewsonic.miracast.net;

import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.io.IOException;
import java.time.Clock;

public class EventBaseTest {
  private Clock clock;
  private EventBase base;
  private Runnable task1;

  @BeforeEach
  public void setUp() throws IOException {
    clock = Clock.systemDefaultZone();
    task1 = Mockito.mock(Runnable.class);

    base = new EventBase();
    base.init();
    base.start();
  }

  @AfterEach
  public void tearDown() {
    base.stop();
  }

  @Tag("slow")
  @Test
  public void post_TaskShouldRun() {
    // Arrange

    // Act
    base.post(task1);

    // Assert
    verify(task1, timeout(1000)).run();
  }

  @Tag("slow")
  @Test
  public void setTimer_FromPost_TimerTaskShouldRun() {
    // Arrange
    Runnable timerTask = () -> {
      base.setTimer(task1, 100);
    };

    // Act
    base.post(timerTask);

    // Assert
    verify(task1, timeout(1000)).run();
  }
}
