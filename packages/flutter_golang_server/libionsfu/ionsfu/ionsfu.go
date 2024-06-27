package ionsfu

import (
	"context"
	"fmt"
	"net/http"
	_ "net/http/pprof"
	"os"

	"github.com/gorilla/websocket"
	"github.com/pion/ion-sfu/cmd/signal/json-rpc/server"
	log "github.com/pion/ion-sfu/pkg/logger"
	"github.com/pion/ion-sfu/pkg/middlewares/datachannel"
	"github.com/pion/ion-sfu/pkg/sfu"
	"github.com/sourcegraph/jsonrpc2"
	websocketjsonrpc2 "github.com/sourcegraph/jsonrpc2/websocket"
)

type logC struct {
	Config log.GlobalConfig `mapstructure:"log"`
}

type IonSfuListener interface {
	OnError(err string, msg string)
}

type IonSfuServer struct {
	listener_ IonSfuListener
	sfu       *sfu.SFU
}

var (
	sfuServer      = new(IonSfuServer)
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
	SDPSemantics           string
	MDNS                   bool
	ICEDisconnectedTimeout int
	ICEFailedTimeout       int
	ICEKeepaliveInterval   int
	Credentials            string
}

func Initialize() {
	if verbosityLevel < 0 {
		verbosityLevel = logConfig.Config.V
	}

	log.SetGlobalOptions(log.GlobalConfig{V: verbosityLevel})
}

func RegisterListener(listener IonSfuListener) {
	sfuServer.listener_ = listener
}

func InitializeSFU() {
	sfu.Logger = logger

	sfuServer.sfu = sfu.NewSFU(conf)

	dc := sfuServer.sfu.NewDatachannel(sfu.APIChannelLabel)
	dc.Use(datachannel.SubscriberAPI)
}

func StartServer(configInfo *ConfigInfo) {
	updateConfig(configInfo)
	InitializeSFU()
	go serverMain()
}

func StopServer() {
	stoppingChann <- true
	<-stoppedChann
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
	conf.WebRTC.SDPSemantics = configInfo.SDPSemantics
	conf.WebRTC.MDNS = configInfo.MDNS
	conf.WebRTC.Timeouts.ICEDisconnectedTimeout = configInfo.ICEDisconnectedTimeout
	conf.WebRTC.Timeouts.ICEFailedTimeout = configInfo.ICEFailedTimeout
	conf.WebRTC.Timeouts.ICEKeepaliveInterval = configInfo.ICEKeepaliveInterval
	conf.Turn.Auth.Credentials = configInfo.Credentials
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
