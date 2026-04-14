// package main

// import (
// 	"fmt"
// 	"go_lib/server"
// 	"syscall"
// 	"unsafe"
// )

// func main() {

// 	server.Initialize()

// 	fmt.Println("server is started")

// 	var configInfo server.ConfigInfo
// 	configInfo.Ballast = 0
// 	configInfo.WithStats = false
// 	configInfo.MaxBandwidth = 1500
// 	configInfo.MaxPacketTrack = 500
// 	configInfo.AudioLevelThreshold = 40
// 	configInfo.AudioLevelInterval = 1000
// 	configInfo.AudioLevelFilter = 20
// 	configInfo.BestQualityFirst = true
// 	configInfo.EnableTemporalLayer = false
// 	configInfo.ICEPortRangeStart = 5000
// 	configInfo.ICEPortRangeEnd = 5200
// 	configInfo.SDPSemantics = "unified-plan"
// 	configInfo.MDNS = true
// 	configInfo.ICEDisconnectedTimeout = 5
// 	configInfo.ICEFailedTimeout = 25
// 	configInfo.ICEKeepaliveInterval = 2
// 	configInfo.Credentials = "pion=ion,pion2=ion2"

// 	server.StartServer(&configInfo)

// 	MessageBox(0, "Running", "Running", 0)

// 	server.StopServer()

// 	MessageBox(0, "Done", "Done", 0)

// }

// func MessageBox(hwnd uintptr, caption, title string, flag uint) int {
// 	ret, _, _ := syscall.NewLazyDLL("user32.dll").NewProc("MessageBoxW").Call(
// 		uintptr(hwnd),
// 		uintptr(unsafe.Pointer(syscall.StringToUTF16Ptr(caption))),
// 		uintptr(unsafe.Pointer(syscall.StringToUTF16Ptr(title))),
// 		uintptr(flag))

// 	return int(ret)
// }
