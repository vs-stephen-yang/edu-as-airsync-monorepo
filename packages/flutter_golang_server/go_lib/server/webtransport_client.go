package server

import (
	"context"
	"encoding/binary"
	"fmt"
	"io"
	"log"
	"strings"

	"github.com/pkg/errors"
	"github.com/quic-go/webtransport-go"
)

type WebTransportClient struct {
	id             string
	session        *webtransport.Session
	streams        []*webtransport.Stream
	isDisconneting bool
}

type WebTransportError struct {
	clientID string
	err      error
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

			if strings.Contains(err.Error(), "NormalClose") {
				c.isDisconneting = true
				return
			}
			errCh <- WebTransportError{
				clientID: c.id,
				err:      errors.Wrap(err, "Error accepting stream"),
			}
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
		if _, err := io.ReadFull(stream, buf); err != nil {
			if c.isDisconneting {
				return
			}
			if errors.Is(err, io.EOF) {
				errCh <- WebTransportError{
					clientID: c.id,
					err:      errors.Wrap(err, "Stream EOF"),
				}
			} else if strings.Contains(err.Error(), "stream reset") {
				errCh <- WebTransportError{
					clientID: c.id,
					err:      errors.Wrap(err, "Stream closed by peer"),
				}
			} else {
				errCh <- WebTransportError{
					clientID: c.id,
					err:      errors.Wrap(err, "Stream read error"),
				}
			}
			return
		}

		// Convert 4-byte buffer to an integer (Big Endian)
		messageLength := int(binary.BigEndian.Uint32(buf))
		if messageLength <= 0 {
			errCh <- WebTransportError{
				clientID: c.id,
				err:      fmt.Errorf("Invalid message length: %d", messageLength),
			}
			return
		}

		// Step 2: Read the full message based on the extracted length
		messageBuf := make([]byte, messageLength)
		if _, err := io.ReadFull(stream, messageBuf); err != nil {
			errCh <- WebTransportError{
				clientID: c.id,
				err:      errors.Wrap(err, "Error reading message"),
			}
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
		// TODO: handle stream buffer full
		if _, err := s.Write(finalMessage); err != nil {
			errCh <- WebTransportError{
				clientID: c.id,
				err:      errors.Wrap(err, "Failed to write message"),
			}
			return
		}
	}
}
