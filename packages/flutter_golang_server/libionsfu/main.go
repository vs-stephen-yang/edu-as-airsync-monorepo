package main

import (
	"fmt"
	"libionsfu/ionsfu"
	"syscall"
	"unsafe"
)

func main() {

	ionsfu.Initialize()

	fmt.Println("server is started")

	ionsfu.StartServer()

	MessageBox(0, "Running", "Running", 0)

	ionsfu.StopServer()

	MessageBox(0, "Done", "Done", 0)

}

func MessageBox(hwnd uintptr, caption, title string, flag uint) int {
	ret, _, _ := syscall.NewLazyDLL("user32.dll").NewProc("MessageBoxW").Call(
		uintptr(hwnd),
		uintptr(unsafe.Pointer(syscall.StringToUTF16Ptr(caption))),
		uintptr(unsafe.Pointer(syscall.StringToUTF16Ptr(title))),
		uintptr(flag))

	return int(ret)
}
