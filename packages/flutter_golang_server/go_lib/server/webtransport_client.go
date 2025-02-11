package server

import (
	"context"
	"io"
	"log"
	"strings"

	"github.com/pkg/errors"
	"github.com/quic-go/webtransport-go"
)

type WebTransportClient struct {
	id      string
	session *webtransport.Session
	streams []*webtransport.Stream
}

func (c *WebTransportClient) addStream(stream *webtransport.Stream) {
	c.streams = append(c.streams, stream)
}

func (c *WebTransportClient) acceptStream() {
	for {
		// Accept bidirectional stream
		stream, err := c.session.AcceptStream(context.Background())
		if err != nil {
			if sessionErr, ok := err.(*webtransport.SessionError); ok {
				if sessionErr.ErrorCode == 0 {
					log.Printf("Client: %s, Session closed, stopping stream acceptance\n", c.id)
					return
				}
			}

			// Log other unexpected errors
			log.Printf("Error accepting stream: %v", err)
			return
		}
		log.Printf("Client: %s, Accept Stream\n", c.id)

		c.addStream(&stream)
		go c.handleSignalingStream(stream)
	}
}

func (c *WebTransportClient) handleSignalingStream(stream webtransport.Stream) {
	defer stream.Close()

	buf := make([]byte, initReadBufferSize)
	for {
		n, err := stream.Read(buf)
		if err != nil {
			if errors.Is(err, io.EOF) {
				log.Println("Stream closed by peer")
			} else if strings.Contains(err.Error(), "stream reset") {
				log.Println("Stream closed by peer")
				return
			} else {
				log.Printf("Stream read error: %v", err)
			}
			return
		}

		content := string(buf[:n])
		msg := WebTransportMessage{
			ClientID: c.id,
			Content:  content,
		}
		msgChan <- msg

		// Resize the buffer before it’s completely consumed
		if len(content) > len(buf)*3/4 && len(buf) < int(maxReadBufferSize) {
			buf = make([]byte, len(buf)*2)
			log.Printf("Buffer size increased to %d bytes", len(buf))
		}
	}
}

func (c *WebTransportClient) sendMessage(msg string) {
	for _, stream := range c.streams {
		s := *stream
		if _, err := s.Write([]byte(msg)); err != nil {
			log.Printf("Client: %s, Stream write error: %v\n", c.id, err)
			return
		}
	}
}
