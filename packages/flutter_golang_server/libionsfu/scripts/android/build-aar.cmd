go get golang.org/x/mobile/cmd/gomobile
go build golang.org/x/mobile/cmd/gomobile
gomobile bind -v -o ../android/libs/libionsfu.aar -target=android ./ionsfu
