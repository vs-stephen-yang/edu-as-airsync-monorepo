package com.viewsonic.miracast.net;

import java.nio.channels.SelectionKey;

public interface ChannelListener {
  void onOpsReady(SelectionKey key);
}
