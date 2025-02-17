package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"go_lib/server"
	"log"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	go func() {
		quit := make(chan os.Signal, 1)
		signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
		defer signal.Stop(quit)

		select {
		case <-quit:
			server.StopWebTransportServer()
		}
	}()

	cert := []string{
		"-----BEGIN CERTIFICATE-----",
		"MIIBSzCB8aADAgECAhQsvsEkoX0ejH8koims25SIuce+bTAKBggqhkjOPQQDAjAU",
		"MRIwEAYDVQQDDAkxMjcuMC4wLjEwHhcNMjUwMjAzMDIyMTE0WhcNMjUwMjE3MDIy",
		"MTE0WjAUMRIwEAYDVQQDDAkxMjcuMC4wLjEwWTATBgcqhkjOPQIBBggqhkjOPQMB",
		"BwNCAASvcFfEf/u2h1UQeajhLdGgT5mGedkp1G+4OlhIyDdpS7Uru/Y82Z3oTg90",
		"oxTxaQf3NXe6IHijekxxPQzJf0mGoyEwHzAdBgNVHQ4EFgQUmgBMRZU/+Jpawb/4",
		"0SJtrx5CKekwCgYIKoZIzj0EAwIDSQAwRgIhAOMNNbpKPeDCiWJMQCM/6ALmoLk9",
		"f/FmI6ptna/5b5yvAiEAwzyDXEFpZrpc8m3yEERhQHfrwaGYIV37/Ba5UYjy4ik=",
		"-----END CERTIFICATE-----",
	}

	key := []string{
		"-----BEGIN EC PRIVATE KEY-----",
		"MHcCAQEEIGKirrHxdk1UijzcOWc4KaO3dHaexOYLMDm46epK2W9WoAoGCCqGSM49",
		"AwEHoUQDQgAEr3BXxH/7todVEHmo4S3RoE+ZhnnZKdRvuDpYSMg3aUu1K7v2PNmd",
		"6E4PdKMU8WkH9zV3uiB4o3pMcT0MyX9Jhg==",
		"-----END EC PRIVATE KEY-----",
	}

	// Encode the certificate and key as JSON
	certPEM, err := json.Marshal(cert)
	if err != nil {
		log.Fatalf("Failed to marshal cert: %v", err)
	}

	keyPEM, err := json.Marshal(key)
	if err != nil {
		log.Fatalf("Failed to marshal key: %v", err)
	}

	// server.RegisterListener(&server.ListenerStub{})

	// Start the WebTransport server
	config := &server.WebTransportConfig{
		Port:     8443,
		InitCert: certPEM,
		InitKey:  keyPEM,
	}

	// config.AddAllowOrigin("https://test.thomasthomas.org:8443")

	if err := server.StartWebTransportServer(config); err != nil {
		log.Fatalf("StartWebTransportServer err: %s", err)
	}

	handleUserInput()
}

// handleUserInput accepts user input from the console and sends messages to clients
func handleUserInput() {
	scanner := bufio.NewScanner(os.Stdin)
	for {
		fmt.Print("Enter clientID and message (format: clientID message): ")
		if scanner.Scan() {
			input := scanner.Text()
			if input == "" {
				continue
			}

			// Split the input into clientID and message
			parts := splitInput(input)
			if len(parts) < 2 {
				fmt.Println("Invalid input. Format: clientID message")
				continue
			}

			clientID := parts[0]
			message := parts[1]

			if message == "quit" {
				server.CloseWebTransportConn(clientID)
				continue
			}
			// Call SendMessage to send the message to the specified client
			server.SendMessage(clientID, message)
		}
	}
}

// splitInput splits the user input into clientID and message
func splitInput(input string) []string {
	parts := make([]string, 2)
	index := 0
	for i, char := range input {
		if char == ' ' {
			parts[0] = input[:i]
			parts[1] = input[i+1:]
			index = i
			break
		}
	}

	// If no space was found, return the input as a single part
	if index == 0 {
		parts[0] = input
		parts[1] = ""
	}
	return parts
}
