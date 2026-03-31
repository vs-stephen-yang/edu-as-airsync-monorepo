go get golang.org/x/mobile/cmd/gomobile
gomobile bind -v -ldflags="-extldflags='-Wl,-z,max-page-size=16384'" -o ../android/libs/lib-server.aar -target=android -androidapi 21 ./server
