package server

import (
	"context"
	"encoding/binary"
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

	buf := make([]byte, 4) // Buffer to read the 4-byte length prefix

	for {
		_, err := io.ReadFull(stream, buf)
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

		// Convert 4-byte buffer to an integer (Big Endian)
		messageLength := int(binary.BigEndian.Uint32(buf))
		if messageLength <= 0 || messageLength > int(maxReadBufferSize) {
			log.Printf("Invalid message length: %d", messageLength)
			return
		}

		// Step 2: Read the full message based on the extracted length
		messageBuf := make([]byte, messageLength)
		_, err = io.ReadFull(stream, messageBuf)
		if err != nil {
			log.Printf("Error reading message: %v", err)
			return
		}

		// Step 3: Decode the UTF-8 message
		content := string(messageBuf)

		msg := WebTransportMessage{
			ClientID: c.id,
			Content:  content,
		}

		msgChan <- msg
	}
}

func (c *WebTransportClient) sendMessage(msg string) {
	// Convert message to bytes (UTF-8 encoding)
	messageBytes := []byte(msg)

	// Create a 4-byte length prefix (Big Endian)
	lengthPrefix := make([]byte, 4)
	binary.BigEndian.PutUint32(lengthPrefix, uint32(len(messageBytes)))

	// Concatenate length header + message
	finalMessage := append(lengthPrefix, messageBytes...)

	// Send to all streams
	for _, stream := range c.streams {
		s := *stream
		if _, err := s.Write(finalMessage); err != nil {
			log.Printf("Client: %s, Stream write error: %v\n", c.id, err)
			return
		}
	}
}
