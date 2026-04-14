# flutter_golang_server

## flutter_ion_sfu

A flutter plugin for ion sfu.

### Setup

```
flutter pub get

git submodule init
git submodule update
```

### Devlopment

1. First, open the project from root folder with Android Studio
1. Build the project
1. Then, re-open the project from ion_sfu_example/android folder with Android Studio
1. Build the project
1. Whenever you modify golang source codes under go_lib folder
   1. Build lib-server.aar with go_lib/scripts/android/build-aar.cmd
   1. Delete the build folder
   1. Re-build the project

### Test without flutter

```
# Run the ion sfu server on Android
.\go_lib\scripts\android\run.cmd

# Run the ion sfu server on Windows
.\go_lib\scripts\windows\run.cmd
```

### Language binding

Gobind generates bindings for calling Go functions from Java.

Debug the bindings by viewing the java files in `android/libs/lib-server-sources.jar`

## flutter_webtransport

A flutter plugin for webtransport

### Devlopment

1. First, open the project from root folder with Android Studio
1. Build the project
1. Then, re-open the project from webtransport_example/android folder with Android Studio
1. Build the project
1. Whenever you modify golang source codes under go_lib folder
   1. Build lib-server.aar with go_lib/scripts/android/build-aar.cmd
   1. Delete the build folder
   1. Re-build the project

### Test without flutter

```
cd go_lib
go run webtransport-main.go
```

## Run script to generate webtransport certs
1. Generate certs
   ```
   ./script/generate_certs.sh 20250201 20350201
   ```
2. Put certs/webtransport_certs_list.json to Display_Flutter/assets/channel
3. Generate hash
   ```
   ./script/generate_certs_hash.sh certs
   ```
4. Put certs/webtransport_cert_hashes.json to Display_Cast_Flutter/assets