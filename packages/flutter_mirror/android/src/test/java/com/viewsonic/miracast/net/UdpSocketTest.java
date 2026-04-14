
package com.viewsonic.miracast.net;

import static com.viewsonic.miracast.net.TestUtil.readBytes;
import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.verify;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.time.Clock;

public class UdpSocketTest {
  MockUdpPeer peerSocket;
  int port = 0;
  int peerPort = 0;
  EventBase eventBase;
  UdpSocket socket;

  ByteBuffer readBuffer;

  UdpSocketListener listener;

  @BeforeEach
  void setUp() throws IOException {
    // peer socket
    peerSocket = new MockUdpPeer();
    peerSocket.init();

    // event base
    eventBase = new EventBase();
    eventBase.init();
    eventBase.start();

    listener = Mockito.mock(UdpSocketListener.class);

    // UdpSocket
    socket = new UdpSocket(eventBase, listener);
    socket.bind(0);
    socket.setRemoteAddress("localhost", peerSocket.getLocalPort());

    peerSocket.setRemoteAddress("localhost", socket.getLocalPort());

    readBuffer = ByteBuffer.allocate(1024);

    doAnswer(invocation -> {
      // when onReadable is called, call read()
      socket.receive(readBuffer);
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
    eventBase.stop();
  }

  @Test
  void send_PeerShouldReceiveMessage() throws IOException {
    // arrange

    // action
    run(() -> {
      String message = "abcd";
      ByteBuffer buffer = ByteBuffer.wrap(message.getBytes());

      socket.send(buffer);
    });

    // assert
    byte[] actual = peerSocket.receive();
    assertArrayEquals("abcd".getBytes(), actual);
  }

  @Test
  void PeerSendMessage_onReadableShouldBeCalled() throws IOException {
    // arrange
    run(() -> {
      socket.enableRead();

      peerSocket.send("abcd".getBytes());
    });

    // action

    // assert
    verify(listener,
        timeout(1000).times(1))
        .onReadable(any());

    readBuffer.flip(); // flip to read mode

    assertArrayEquals(
        "abcd".getBytes(),
        readBytes(readBuffer, 4));
  }
}
