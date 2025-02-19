package server

type WebTransportConfig struct {
	Port         int
	InitCert     []byte
	InitKey      []byte
	AllowOrigins []string
}

func (c *WebTransportConfig) AddAllowOrigin(origin string) {
	c.AllowOrigins = append(c.AllowOrigins, origin)
}
