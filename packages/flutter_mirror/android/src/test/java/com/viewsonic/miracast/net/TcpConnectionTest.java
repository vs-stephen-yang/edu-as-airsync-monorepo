package com.viewsonic.miracast.net;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.io.IOException;
import java.nio.ByteBuffer;

class TcpConnectionTest {

  MockTcpServer server;
  int port = 0;
  EventBase eventBase;
  TcpConnection connection;

  ByteBuffer readBuffer;

  TcpConnectionListener listener;

  @BeforeEach
  void setUp() throws IOException {
    // tcp server
    server = new MockTcpServer();
    server.init();
    port = server.getPort();

    // event base
    eventBase = new EventBase();
    eventBase.init();
    eventBase.start();

    listener = Mockito.mock(TcpConnectionListener.class);

    // TcpConnection
    connection = new TcpConnection(eventBase, listener);

    readBuffer = ByteBuffer.allocate(1024);

    doAnswer(invocation -> {
      // when onReadable is called, call read()
      connection.read(readBuffer);
      return null;
    })
        .when(listener)
        .onReadable(any());
  }

  // run inside the thread of the EventBase
  private void run(CallableWithThrow task) {
    eventBase.post(() -> {
      try {
        task.run();
      } catch (Exception e) {
        throw new RuntimeException(e);
      }
    });
  }

  @AfterEach
  void tearDown() throws IOException {
    server.close();
    eventBase.stop();
  }

  @Test
  void connect_onConnectedShouldBeCalled() {
    // arrange

    // action
    run(() -> connection.connect("localhost", port));

    // assert
    verify(listener,
        timeout(1000).times(1))
        .onConnected(any());
  }

  @Test
  void ServerWriteMessage_onReadableShouldBeCalled() throws IOException {
    // arrange
    run(() -> connection.connect("localhost", port));

    server.accept();

    // action
    server.write("abcd");

    // assert
    verify(listener,
        timeout(1000).times(1))
        .onReadable(any());

    readBuffer.flip(); // flip to read mode

    assertArrayEquals(
        "abcd".getBytes(),
        TestUtil.readBytes(readBuffer, 4));
  }

  @Tag("slow")
  @Test
  void NotReachable_ShouldConnectTimeout() throws IOException {
    // arrange
    int kNotBoundPort = 100;

    // action
    run(() -> {
      connection.setReconnectAttempts(100, 3);

      connection.connect("localhost", kNotBoundPort);
    });

    // assert
    // onConnectTimeout() should be called once
    verify(listener,
        timeout(1000).times(1))
        .onConnectTimeout(any());

    // onReconnect() should be called 3 times
    verify(listener,
        times(3))
        .onReconnect(any(), anyInt());

    // onConnected() should never be called
    verify(listener, never())
        .onConnected(any());
  }
}
