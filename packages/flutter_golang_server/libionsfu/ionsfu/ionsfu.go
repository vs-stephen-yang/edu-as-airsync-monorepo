package ionsfu

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"net/http"
	_ "net/http/pprof"
	"os"

	"github.com/gorilla/websocket"
	"github.com/pion/ion-sfu/cmd/signal/json-rpc/server"
	log "github.com/pion/ion-sfu/pkg/logger"
	"github.com/pion/ion-sfu/pkg/middlewares/datachannel"
	"github.com/pion/ion-sfu/pkg/sfu"
	"github.com/pion/webrtc/v3"
	"github.com/sourcegraph/jsonrpc2"
	websocketjsonrpc2 "github.com/sourcegraph/jsonrpc2/websocket"
)

type logC struct {
	Config log.GlobalConfig `mapstructure:"log"`
}

type IonSfuListener interface {
	OnError(err string, msg string)
	OnSignalMessage(channelId int, msg string)
	OnIceConnectionState(channelId int, state int)
}

type IonSfuServer struct {
	listener_ IonSfuListener
	sfu       *sfu.SFU

	channels         map[int]*sfu.PeerLocal
	channelIdCounter int
}

var (
	sfuServer = &IonSfuServer{
		channels: make(map[int]*sfu.PeerLocal),
	}
	conf           = sfu.Config{}
	cert           string
	key            string
	addr           string = ":7000"
	metricsAddr    string
	verbosityLevel int
	logConfig      logC
	srv            *http.Server
	logger                   = log.New()
	stoppingChann  chan bool = make(chan bool)
	stoppedChann   chan bool = make(chan bool)
)

const (
	portRangeLimit = 100
)

func showHelp() {
	fmt.Printf("Usage:%s {params}\n", os.Args[0])
	fmt.Println("      -c {config file}")
	fmt.Println("      -cert {cert file}")
	fmt.Println("      -key {key file}")
	fmt.Println("      -a {listen addr}")
	fmt.Println("      -h (show help info)")
	fmt.Println("      -v {0-10} (verbosity level, default 0)")
}

type ICEServerConfig struct {
	URLs       []string
	Username   string
	Credential string
}

func NewICEServerConfig() *ICEServerConfig { return &ICEServerConfig{} }

func (config *ICEServerConfig) AddURL(url string) {
	config.URLs = append(config.URLs, url)
}

type ConfigInfo struct {
	Ballast                int
	WithStats              bool
	MaxBandwidth           int
	MaxPacketTrack         int
	AudioLevelThreshold    int
	AudioLevelInterval     int
	AudioLevelFilter       int
	BestQualityFirst       bool
	EnableTemporalLayer    bool
	ICEPortRangeStart      int
	ICEPortRangeEnd        int
	ICEServers             []ICEServerConfig
	SDPSemantics           string
	MDNS                   bool
	ICEDisconnectedTimeout int
	ICEFailedTimeout       int
	ICEKeepaliveInterval   int
	Credentials            string
}

func NewConfigInfo() *ConfigInfo { return &ConfigInfo{} }

func (config *ConfigInfo) AddICEServer(iceServer *ICEServerConfig) {
	config.ICEServers = append(config.ICEServers, *iceServer)
}

func Initialize() {
	logger.Info("Initialize")

	if verbosityLevel < 0 {
		verbosityLevel = logConfig.Config.V
	}

	log.SetGlobalOptions(log.GlobalConfig{V: verbosityLevel})
}

func RegisterListener(listener IonSfuListener) {
	sfuServer.listener_ = listener
}

func CreateSignalChannel() int {
	if sfuServer.channelIdCounter >= math.MaxInt32 {
		sfuServer.channelIdCounter = 0
	}

	sfuServer.channelIdCounter++

	peer := sfu.NewPeer(sfuServer.sfu)

	sfuServer.channels[sfuServer.channelIdCounter] = peer

	logger.Info("CreateSignalChannel", "channelId", sfuServer.channelIdCounter)
	return sfuServer.channelIdCounter
}

func CloseSignalChannel(channelId int) {
	logger.Info("CloseSignalChannel", "channelId", channelId)

	peer, exists := sfuServer.channels[channelId]
	if !exists {
		logger.Info("CloseSignalChannel: channel not found", "channelId", channelId)
		return
	}
	delete(sfuServer.channels, channelId)

	go func() {
		// peer.Close() is a blocking call.
		// execute peer.Close() concurrently without blocking the current flow
		if err := peer.Close(); err != nil {
			logger.Error(err, "Error closing peer", "channelId", channelId)
		}
	}()
}

func replyError(err error) {
	// TODO
}

// Send the signal message to the peer
func sendSignal(channelId int, jsonData []byte) {
	if sfuServer.listener_ != nil {
		sfuServer.listener_.OnSignalMessage(channelId, string(jsonData))
	}
}

func notifyIceConnectionState(channelId int, state webrtc.ICEConnectionState) {
	if sfuServer.listener_ != nil {
		sfuServer.listener_.OnIceConnectionState(channelId, int(state))
	}
}

// send a JSON-RPC notification over channel
func sendNotification(channelId int, method string, params interface{}) error {
	req := &jsonrpc2.Request{Method: method}
	if err := req.SetParams(params); err != nil {
		return err
	}

	jsonData, err := json.Marshal(req)
	if err != nil {
		return err
	}

	sendSignal(channelId, jsonData)

	return nil
}

// send a JSON-RPC reply over channel
func sendReply(channelId int, id jsonrpc2.ID, result interface{}) error {
	resp := &jsonrpc2.Response{ID: id}
	if err := resp.SetResult(result); err != nil {
		return err
	}

	jsonData, err := json.Marshal(resp)
	if err != nil {
		return err
	}

	sendSignal(channelId, jsonData)

	return nil
}

// Handle signal messages from the peer
// The signal messages are in json-RPC format
func ProcessSignalMessage(channelId int, message string) {
	peer, exists := sfuServer.channels[channelId]
	if !exists {
		logger.Info("ProcessSignalMessage: channel not found", "channelId", channelId)
		return
	}

	var req jsonrpc2.Request
	err := json.Unmarshal([]byte(message), &req)
	if err != nil {
		logger.Error(err, "ProcessSignalMessage: invalid request", "message", message)
		return
	}

	switch req.Method {
	case "join":
		var join server.Join
		err := json.Unmarshal(*req.Params, &join)
		if err != nil {
			logger.Error(err, "error parsing join")
			replyError(err)
			break
		}

		peer.OnOffer = func(offer *webrtc.SessionDescription) {
			if err := sendNotification(channelId, "offer", offer); err != nil {
				logger.Error(err, "error sending offer")
			}

		}

		peer.OnICEConnectionStateChange = func(state webrtc.ICEConnectionState) {
			notifyIceConnectionState(channelId, state)
		}

		peer.OnIceCandidate = func(candidate *webrtc.ICECandidateInit, target int) {
			if err := sendNotification(channelId, "trickle", server.Trickle{
				Candidate: *candidate,
				Target:    target,
			}); err != nil {
				logger.Error(err, "error sending ice candidate")
			}
		}

		err = peer.Join(join.SID, join.UID, join.Config)
		if err != nil {
			logger.Error(err, "PeerLocal Join")
			replyError(err)
			break
		}

		answer, err := peer.Answer(join.Offer)
		if err != nil {
			logger.Error(err, "PeerLocal Answer")
			replyError(err)
			break
		}

		_ = sendReply(channelId, req.ID, answer)

	case "offer":
		var negotiation server.Negotiation
		err := json.Unmarshal(*req.Params, &negotiation)
		if err != nil {
			logger.Error(err, "error parsing offer")
			replyError(err)
			break
		}

		answer, err := peer.Answer(negotiation.Desc)
		if err != nil {
			logger.Error(err, "PeerLocal Answer")
			replyError(err)
			break
		}
		_ = sendReply(channelId, req.ID, answer)

	case "answer":
		var negotiation server.Negotiation
		err := json.Unmarshal(*req.Params, &negotiation)
		if err != nil {
			logger.Error(err, "error parsing answer")
			replyError(err)
			break
		}

		err = peer.SetRemoteDescription(negotiation.Desc)
		if err != nil {
			logger.Error(err, "PeerLocal SetRemoteDescription")
			replyError(err)
		}

	case "trickle":
		var trickle server.Trickle
		err := json.Unmarshal(*req.Params, &trickle)
		if err != nil {
			logger.Error(err, "error parsing candidate")
			replyError(err)
			break
		}

		err = peer.Trickle(trickle.Candidate, trickle.Target)
		if err != nil {
			logger.Error(err, "PeerLocal Trickle")
			replyError(err)
		}
	}
}

func printICEServers(config sfu.Config) {
	logger.Info("ICEServers:")
	for _, iceServer := range config.WebRTC.ICEServers {
		logger.Info("ICEServer", "URL", iceServer.URLs[0], "Username", iceServer.Username, "Credential", iceServer.Credential)
	}
}

func initializeSFU() {
	sfu.Logger = logger

	printICEServers(conf)
	sfuServer.sfu = sfu.NewSFU(conf)

	dc := sfuServer.sfu.NewDatachannel(sfu.APIChannelLabel)
	dc.Use(datachannel.SubscriberAPI)
}

func StartServer(configInfo *ConfigInfo) {
	updateConfig(configInfo)
	initializeSFU()
	go serverMain()
}

func StopServer() {
	stoppingChann <- true
	<-stoppedChann
}

func convertICEServerConfig(iceServers []ICEServerConfig) []sfu.ICEServerConfig {
	var sfuIceServers []sfu.ICEServerConfig

	for _, server := range iceServers {
		sfuServer := sfu.ICEServerConfig{
			URLs:       server.URLs,
			Username:   server.Username,
			Credential: server.Credential,
		}
		sfuIceServers = append(sfuIceServers, sfuServer)
	}
	return sfuIceServers
}

func updateConfig(configInfo *ConfigInfo) {
	conf.SFU.Ballast = int64(configInfo.Ballast)
	conf.SFU.WithStats = configInfo.WithStats

	conf.Router.MaxBandwidth = uint64(configInfo.MaxBandwidth)
	conf.Router.MaxPacketTrack = configInfo.MaxPacketTrack
	conf.Router.AudioLevelThreshold = uint8(configInfo.AudioLevelThreshold)
	conf.Router.AudioLevelInterval = configInfo.AudioLevelInterval
	conf.Router.AudioLevelFilter = configInfo.AudioLevelFilter
	conf.Router.Simulcast.BestQualityFirst = configInfo.BestQualityFirst
	conf.Router.Simulcast.EnableTemporalLayer = configInfo.EnableTemporalLayer
	conf.WebRTC.ICEPortRange = []uint16{uint16(configInfo.ICEPortRangeStart), uint16(configInfo.ICEPortRangeEnd)}
	conf.WebRTC.ICEServers = convertICEServerConfig(configInfo.ICEServers)
	conf.WebRTC.SDPSemantics = configInfo.SDPSemantics
	conf.WebRTC.MDNS = configInfo.MDNS
	conf.WebRTC.Timeouts.ICEDisconnectedTimeout = configInfo.ICEDisconnectedTimeout
	conf.WebRTC.Timeouts.ICEFailedTimeout = configInfo.ICEFailedTimeout
	conf.WebRTC.Timeouts.ICEKeepaliveInterval = configInfo.ICEKeepaliveInterval

	logger.Info("Update config", "conf", fmt.Sprintf("%+v", conf))
}

func serverMain() {
	logger.Info("--- Starting SFU Node ---")

	defer func() {
		if r := recover(); r != nil {
			logger.Error(fmt.Errorf("recover from panic: %v", r), "error")
		}
	}()

	upgrader := websocket.Upgrader{
		CheckOrigin: func(r *http.Request) bool {
			return true
		},
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
	}

	// response "hello" when navigate http://xxxx/hello
	http.HandleFunc("/hello", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("hello"))
	})

	http.Handle("/ws", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		c, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			logger.Error(err, "error")
		}
		defer c.Close()

		p := server.NewJSONSignal(sfu.NewPeer(sfuServer.sfu), logger)
		defer p.Close()

		jc := jsonrpc2.NewConn(r.Context(), websocketjsonrpc2.NewObjectStream(c), p)
		<-jc.DisconnectNotify()
	}))

	idleConnsClosed := make(chan struct{})
	go func() {
		<-stoppingChann
		err := srv.Shutdown(context.Background())
		if err != nil {
			logger.Error(err, "error")
		}
		logger.Info("idle connections closed")
		close(idleConnsClosed)
	}()

	logger.Info("Started listening", "addr", "http://"+addr)

	var err error
	srv = &http.Server{Addr: addr}
	err = srv.ListenAndServe()

	if err != http.ErrServerClosed {
		logger.Error(err, "error")
		if sfuServer.listener_ != nil {
			sfuServer.listener_.OnError("http-server", err.Error())
		}
	}
	<-idleConnsClosed
	stoppedChann <- true
}
