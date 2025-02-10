go get -d golang.org/x/mobile/cmd/gomobile
gomobile bind -v -o ../android/libs/libionsfu.aar -target=android -androidapi 21 ./ionsfu
