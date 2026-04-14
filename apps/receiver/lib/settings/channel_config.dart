// Channel reconnect timeout
// When the channel connection is disconnected, the channel will wait for the client to reconnect within a specified period.
// If the client cannot successfully reconnect within this time frame, a "timeout" will occur.

// Channel reconnect timeout during streaming
// During streaming, if the channel gets disconnected, do not interrupt the stream.
// Instead, wait indefinitely for the client to reconnect.
const channelReconnectTimeoutInStreaming = Duration(hours: 10);

// Channel reconnect timeout during idle
const channelReconnectTimeoutInIdle = Duration(seconds: 10);
