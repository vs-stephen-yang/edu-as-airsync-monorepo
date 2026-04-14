package com.viewsonic.miracast.rtsp;

import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class RtspParser {
  public enum State {
    Header,
    Body
  }

  private final StringBuilder data_ = new StringBuilder();
  private State state_ = State.Header;

  private int contentLength_;

  // current message
  RtspMessage message_;

  List<RtspMessage> messages_ = new ArrayList<>();

  // must flip ByteBuffer before calling parse()
  public List<RtspMessage> parse(ByteBuffer buf) {
    messages_.clear();

    String data = StandardCharsets.UTF_8.decode(buf).toString();
    data_.append(data);

    doParse();

    return new ArrayList<>(messages_);
  }

  private void doParse() {
    String str = data_.toString();
    int offset = 0;

    while (offset < str.length()) {
      int consumed;

      if (state_ == State.Header) {
        consumed = parseHeaderPart(str, offset);
      } else {
        consumed = parseBodyPart(str, offset);
      }

      if (consumed <= 0) {
        break;
      }
      offset += consumed;
    }

    data_.delete(0, offset);
  }

  private int parseBodyPart(String str, int offset) {
    assert contentLength_ > 0;

    int remaining = str.length() - offset;

    assert remaining >= 0;

    if (remaining < contentLength_) {
      return 0;
    }
    message_.bodyStr = str.substring(offset, offset + contentLength_);

    parseBody();

    messages_.add(message_);

    state_ = State.Header;

    return contentLength_;
  }

  private void parseBody() {
    String[] bodyLineArray = message_.bodyStr.split("\r\n");
    for (String bl : bodyLineArray) {
      String[] bodyLine = bl.split(":\\s");
      if (bodyLine.length == 2) {
        message_.bodyMap.put(bodyLine[0], bodyLine[1]);
      }
    }
  }

  private int parseHeaderPart(String str, int offset) {

    int pos = str.indexOf("\r\n\r\n", offset);
    if (pos == -1) {
      return 0;
    }

    String header = str.substring(offset, pos + 2);
    parseHeaders(header);

    if (contentLength_ > 0) {
      state_ = State.Body;
    } else {
      messages_.add(message_);
    }

    int consumed = pos + 4 - offset;
    assert consumed > 0;

    return consumed;
  }

  private void parseRequestOrStatusLine(String line) {
    String[] tokens = line.split("\\s");
    if (tokens.length != 3) {
      throw new RuntimeException("Invalid RTSP message");
    }

    if (line.startsWith("RTSP/")) {
      // This is a response message
      RtspResponseMessage response = new RtspResponseMessage();
      response.protocolVersion = tokens[0];
      response.statusCode = Integer.parseInt(tokens[1]);
      message_ = response;
    } else {
      // This is a request message
      RtspRequestMessage request = new RtspRequestMessage();
      request.methodType = tokens[0];
      request.path = tokens[1];
      request.protocolVersion = tokens[2];
      message_ = request;
    }
  }

  private void parseHeaders(String str) {
    contentLength_ = 0;

    String[] lines = str.split("\r\n");

    parseRequestOrStatusLine(lines[0]);

    for (int i = 1; i < lines.length; i++) {
      String line = lines[i];

      String[] tokens = line.split(":\\s");

      if (tokens.length == 2) {
        message_.headers.put(tokens[0], tokens[1]);

        if (tokens[0].equalsIgnoreCase("Content-Length")) {
          contentLength_ = Integer.parseInt(tokens[1]);
        }
      }
    }
  }
}
