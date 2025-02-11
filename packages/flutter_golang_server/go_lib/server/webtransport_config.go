package server

type WebTransportConfig struct {
	Port               int
	InitCert           []byte
	InitKey            []byte
	AllowOrigins       []string
	InitReadBufferSize int
	MaxReadBufferSize  int
}

func (c *WebTransportConfig) AddAllowOrigin(origin string) {
	c.AllowOrigins = append(c.AllowOrigins, origin)
}
