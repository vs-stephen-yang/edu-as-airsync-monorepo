package server

import (
	"context"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"strings"
	"sync"
	"sync/atomic"

	"github.com/pkg/errors"
	"github.com/quic-go/quic-go/http3"
	"github.com/quic-go/webtransport-go"
	"github.com/rs/xid"
)

const (
	DEFAULT_READ_BUFFER_SIZE     = 4096
	DEFAULT_MAX_READ_BUFFER_SIZE = 65536
)

type WebTransportListener interface {
	OnMessage(clientID string, msg string)
	OnClose(clientID string)
	OnConnect(clientID string, queryStr string, clientIp string)
}

type WebTransportServer struct {
	listener WebTransportListener
	wt       webtransport.Server

	clients map[string]*WebTransportClient
}

type WebTransportClientQuery struct {
	ID    string
	Query string
	Ip    string
}

var (
	currentCert   atomic.Pointer[tls.Certificate]
	clientMapLock sync.RWMutex

	initReadBufferSize uint = DEFAULT_READ_BUFFER_SIZE
	maxReadBufferSize  uint = DEFAULT_MAX_READ_BUFFER_SIZE

	webtransportServer = WebTransportServer{
		clients: make(map[string]*WebTransportClient),
	}

	msgChan           = make(chan WebTransportMessage)
	clientCloseChan   = make(chan string)
	clientConnectChan = make(chan WebTransportClientQuery)
	errCh             = make(chan error, 1)
	doneCh            = make(chan struct{}, 1)
)

// Function to load the certificate from in-memory content
func loadCertificate(certPEM, keyPEM []byte) (*tls.Certificate, error) {
	var certStr []string
	if err := json.Unmarshal(certPEM, &certStr); err != nil {
		return nil, errors.Wrap(err, "cert unmarshal failed")
	}
	log.Printf("cert: %v", certStr)

	var keyStr []string
	if err := json.Unmarshal(keyPEM, &keyStr); err != nil {
		return nil, errors.Wrap(err, "cert unmarshal failed")
	}
	log.Printf("key: %v", keyStr)

	certPEMBlock := []byte(strings.Join(certStr, "\n"))
	keyPEMBlock := []byte(strings.Join(keyStr, "\n"))

	cert, err := tls.X509KeyPair(certPEMBlock, keyPEMBlock)
	if err != nil {
		return nil, err
	}
	return &cert, nil
}

// Callback to get the current certificate during the TLS handshake
func getCertificate(clientHello *tls.ClientHelloInfo) (*tls.Certificate, error) {
	return currentCert.Load(), nil
}

// Function to update the certificate
func UpdateCertificate(certPEM, keyPEM []byte) {
	newCert, err := loadCertificate(certPEM, keyPEM)
	if err != nil {
		log.Printf("Failed to update certificate: %v", err)
		return
	}
	setCurrentCertificate(newCert)
}

func setCurrentCertificate(cert *tls.Certificate) {
	currentCert.Store(cert)
	log.Println("Certificate updated successfully")
}

func setReadBufferSize(config WebTransportConfig) {
	if config.InitReadBufferSize != 0 {
		initReadBufferSize = uint(config.InitReadBufferSize)
	}

	if config.MaxReadBufferSize != 0 {
		maxReadBufferSize = uint(config.MaxReadBufferSize)
	}
}

func initServer(config *WebTransportConfig) error {
	setReadBufferSize(*config)

	cert, err := loadCertificate(config.InitCert, config.InitKey)
	if err != nil {
		return errors.Wrap(err, "Failed to load initial certificate:")
	}
	setCurrentCertificate(cert)

	if webtransportServer.listener == nil {
		webtransportServer.listener = &WebTransportListenerStub{}
	}

	return nil
}

func checkOrigin(config WebTransportConfig) func(r *http.Request) bool {
	return func(r *http.Request) bool {
		if len(config.AllowOrigins) == 0 {
			return true
		}

		origin := r.Header.Get("Origin")
		for _, allowed := range config.AllowOrigins {
			if origin == allowed {
				return true
			}
		}
		return false
	}
}

func StartWebTransportServer(config *WebTransportConfig) error {
	if err := initServer(config); err != nil {
		log.Printf("init server failed, err: %s\n", err)
		return err
	}

	go func() {
		notifyListener(context.Background())
	}()

	go startWebTransport(config)
	return nil
}

func startWebTransport(config *WebTransportConfig) {
	defer func() {
		if r := recover(); r != nil {
			logger.Error(fmt.Errorf("recover from panic: %v", r), "error")
		}
	}()

	go func() {
		select {
		case err := <-errCh:
			log.Printf("errChannel get error, err: %s\n", err)
		case <-doneCh:
			webtransportServer.wt.Close()
		}
	}()

	// Load TLS certificate
	tlsConfig := &tls.Config{
		GetCertificate: getCertificate,
		NextProtos:     []string{"h3"},
		MinVersion:     tls.VersionTLS13,
	}

	// Create WebTransport server
	webtransportServer.wt = webtransport.Server{
		CheckOrigin: checkOrigin(*config),
	}

	// HTTP handler for WebTransport
	mux := http.NewServeMux()

	mux.HandleFunc("/webtransport", webTransportHandler())

	// Start HTTP/3 server
	webtransportServer.wt.H3 = http3.Server{
		Addr:      fmt.Sprintf(":%d", config.Port),
		Handler:   mux,
		TLSConfig: tlsConfig,
	}

	log.Println("WebTransport server is running")
	if err := webtransportServer.wt.ListenAndServe(); err != nil {
		errCh <- err
	}
}

func StopWebTransportServer() {
	doneCh <- struct{}{}
}

func addClient(client *WebTransportClient, paramStr string, clientIp string) {
	clientMapLock.Lock()
	defer clientMapLock.Unlock()

	clientConnectChan <- WebTransportClientQuery{
		ID:    client.id,
		Query: paramStr,
		Ip:    clientIp,
	}
	webtransportServer.clients[client.id] = client
}

func removeClient(clientID string) {
	clientMapLock.Lock()
	defer clientMapLock.Unlock()

	clientCloseChan <- clientID
	delete(webtransportServer.clients, clientID)
}

func getClient(clientID string) *WebTransportClient {
	clientMapLock.RLock()
	defer clientMapLock.RUnlock()

	return webtransportServer.clients[clientID]
}

func queryToJSON(values url.Values) (string, error) {
	// Convert url.Values to a simple map
	mapped := make(map[string]interface{})
	for key, value := range values {
		if len(value) == 1 {
			mapped[key] = value[0] // Store single values directly
		} else {
			mapped[key] = value // Store multiple values as a slice
		}
	}

	// Convert map to JSON
	jsonData, err := json.Marshal(mapped)
	if err != nil {
		return "", err
	}

	return string(jsonData), nil
}

func webTransportHandler() func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Request Headers: %+v\n", r.Header)
		log.Printf("Received request for /webtransport: Method=%s, URL=%s", r.Method, r.URL)

		// Handle preflight (OPTIONS) request
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}

		if r.Method != http.MethodConnect {
			log.Printf("Invalid method: %s", r.Method)
			http.Error(w, "CONNECT method required", http.StatusMethodNotAllowed)
			return
		}

		queryParams := r.URL.Query()
		jsonStr, err := queryToJSON(queryParams)
		if err != nil {
			http.Error(w, "Error converting query to JSON", http.StatusBadRequest)
			return
		}

		clientIp := strings.Split(r.RemoteAddr, ":")[0]

		// Upgrade to WebTransport
		session, err := webtransportServer.wt.Upgrade(w, r)
		if err != nil {
			log.Printf("Failed to upgrade to WebTransport: %v", err)
			http.Error(w, "Failed to upgrade to WebTransport", http.StatusInternalServerError)
			return
		}
		log.Println("WebTransport session established")

		client := &WebTransportClient{
			id:      xid.New().String(),
			session: session,
		}
		addClient(client, jsonStr, clientIp)

		handleSession(client)
	}
}

func handleSession(c *WebTransportClient) {
	defer c.session.CloseWithError(0, "Session closed")
	log.Printf("Client: %s, Handling WebTransport session\n", c.id)

	go c.acceptStream()

	<-c.session.Context().Done()
	log.Printf("Client: %s, Session closed, cleaning up resources\n", c.id)
	removeClient(c.id)
}

func notifyListener(ctx context.Context) {
	for {
		select {
		case msg := <-msgChan:
			webtransportServer.listener.OnMessage(msg.ClientID, msg.Content)
		case clientID := <-clientCloseChan:
			webtransportServer.listener.OnClose(clientID)
		case clientQuery := <-clientConnectChan:
			webtransportServer.listener.OnConnect(clientQuery.ID, clientQuery.Query, clientQuery.Ip)
		case <-ctx.Done():
			return
		}
	}
}

func RegisterWebTransportListener(l WebTransportListener) {
	if l == nil {
		webtransportServer.listener = &WebTransportListenerStub{}
		return
	}
	webtransportServer.listener = l
}

func SendMessage(clientID string, msg string) {
	client := getClient(clientID)
	if client == nil {
		return
	}

	client.sendMessage(msg)
}

func CloseWebTransportConn(clientID string) {
	client := getClient(clientID)
	if client == nil {
		return
	}

	client.session.CloseWithError(0, "Session closed")
}

type WebTransportMessage struct {
	ClientID string
	Content  string
}
