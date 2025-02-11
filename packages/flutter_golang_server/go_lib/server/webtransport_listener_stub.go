package server

import "log"

type WebTransportListenerStub struct {
}

func (t *WebTransportListenerStub) OnMessage(clientID string, msg string) {
	log.Printf("listener receive message: %s, %s\n", clientID, msg)
}

func (t *WebTransportListenerStub) OnClose(clientID string) {
	log.Printf("client %s closed\n", clientID)
}

func (t *WebTransportListenerStub) OnConnect(clientID string, queryStr string, clientIp string) {
	log.Printf("client %s connected, query: %s\n", clientID, queryStr)
}
