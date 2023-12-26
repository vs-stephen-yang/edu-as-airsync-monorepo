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

var (
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

func load() {
	conf.SFU.Ballast = 0
	conf.SFU.WithStats = false
	conf.Router.MaxBandwidth = 1500
	conf.Router.MaxPacketTrack = 500
	conf.Router.AudioLevelThreshold = 40
	conf.Router.AudioLevelInterval = 1000
	conf.Router.AudioLevelFilter = 20
	conf.Router.Simulcast.BestQualityFirst = true
	conf.Router.Simulcast.EnableTemporalLayer = false
	conf.WebRTC.ICEPortRange = []uint16{5000, 5200}
	conf.WebRTC.SDPSemantics = "unified-plan"
	conf.WebRTC.MDNS = true
	conf.WebRTC.Timeouts.ICEDisconnectedTimeout = 5
	conf.WebRTC.Timeouts.ICEFailedTimeout = 25
	conf.WebRTC.Timeouts.ICEKeepaliveInterval = 2
	conf.Turn.Auth.Credentials = "pion=ion,pion2=ion2"
}

func Initialize() {
	load()
	if verbosityLevel < 0 {
		verbosityLevel = logConfig.Config.V
	}
}

func StartServer() {
	go serverMain()
}

func StopServer() {
	stoppingChann <- true
	<-stoppedChann
}

func serverMain() {

	log.SetGlobalOptions(log.GlobalConfig{V: verbosityLevel})
	logger.Info("--- Starting SFU Node ---")

	sfu.Logger = logger
	s := sfu.NewSFU(conf)
	dc := s.NewDatachannel(sfu.APIChannelLabel)
	dc.Use(datachannel.SubscriberAPI)

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
			panic(err)
		}
		defer c.Close()

		p := server.NewJSONSignal(sfu.NewPeer(s), logger)
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
		panic(err)
	}
	<-idleConnsClosed
	stoppedChann <- true
}
