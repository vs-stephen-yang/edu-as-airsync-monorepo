package com.viewsonic.miracast.net;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;

public class MockTcpServer {
  private ServerSocket serverSocket_;
  private Socket clientSocket_;
  private BufferedReader reader_;
  private OutputStream outputStream_;

  // bind to the port
  public void init() throws IOException {
    serverSocket_ = new ServerSocket(0);
  }

  public int getPort() {
    return serverSocket_.getLocalPort();
  }

  public void accept() throws IOException {
    clientSocket_ = serverSocket_.accept();
    clientSocket_.setTcpNoDelay(true);

    reader_ = new BufferedReader(new InputStreamReader(clientSocket_.getInputStream()));
    outputStream_ = clientSocket_.getOutputStream();
  }

  public void read() throws IOException {
    reader_.readLine();
  }

  public void write(String msg) throws IOException {
    outputStream_.write(msg.getBytes());
    outputStream_.flush();
  }

  public void closeClientSocket() throws IOException {
    clientSocket_.close();
  }

  public void close() throws IOException {
    if (clientSocket_ != null) {
      reader_.close();
      outputStream_.close();
      clientSocket_.close();
    }

    if (serverSocket_ != null) {
      serverSocket_.close();
    }
  }

}
