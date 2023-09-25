package com.viewsonic.miracast.rtsp;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.List;

class RtspParserTest {

  final String REUQEST1 = "OPTIONS * RTSP/1.0\r\n" +
      "CSeq: 0\r\n" +
      "User-Agent: wfdsinkemu\r\n" +
      "\r\n";

  final String REUQEST2 = "SET_PARAMETER rtsp://localhost/wfd1.0 RTSP/1.0\r\n" +
      "CSeq: 3\r\n" +
      "Content-type: text/parameters\r\n" +
      "Content-length: 67\r\n" +
      "\r\n" +
      "wfd_video_formats: 00 00 01 01\r\n" +
      "wfd_audio_codecs: AAC 00000001 00\r\n";

  RtspParser parser;

  @BeforeEach
  void setUp() throws IOException {
    parser = new RtspParser();
  }

  List<RtspMessage> parse(String str, int beginIndex, int endIndex) {
    String s = str.substring(beginIndex, endIndex);
    ByteBuffer buffer = ByteBuffer.wrap(s.getBytes());

    return parser.parse(buffer);
  }

  @Test
  void parse_OneFullMessage() {
    // Arrange

    // Action
    List<RtspMessage> actual = parse(REUQEST1, 0, REUQEST1.length());

    // Assert
    assertEquals(actual.size(), 1);
    RtspMessage message = actual.get(0);
    assertEquals(message.headers.size(), 2);
  }

  @Test
  void parse_OneFullMessageWithBody() {
    // Arrange

    // Action
    List<RtspMessage> actual = parse(REUQEST2, 0, REUQEST2.length());

    // Assert
    assertEquals(1, actual.size());
    RtspMessage message = actual.get(0);
    assertEquals(3, message.headers.size());
    assertEquals(2, message.bodyMap.size());
  }

  @Test
  void parse_PartialMessage() {
    // Arrange

    // Action
    List<RtspMessage> actual1 = parse(REUQEST2, 0, 10);
    List<RtspMessage> actual2 = parse(REUQEST2, 10, 100);
    List<RtspMessage> actual3 = parse(REUQEST2, 100, 177);

    // Assert
    assertEquals(0, actual1.size());
    assertEquals(0, actual2.size());
    assertEquals(1, actual3.size());
  }

  @Test
  void parse_MultipleRequests() {
    // Arrange

    // Action
    List<RtspMessage> actual1 = parse(REUQEST1, 0, REUQEST1.length());
    List<RtspMessage> actual2 = parse(REUQEST2, 0, REUQEST2.length());

    // Assert
    assertEquals(1, actual1.size());
    assertEquals(1, actual2.size());
  }

  @Test
  void parse_MultipleRequestsInOneMessage() {
    // Arrange
    String message = REUQEST1 + REUQEST2;

    // Action
    List<RtspMessage> actual = parse(message, 0, message.length());

    // Assert
    assertEquals(2, actual.size());
  }
}
