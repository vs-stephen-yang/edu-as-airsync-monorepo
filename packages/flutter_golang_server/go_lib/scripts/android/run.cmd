@echo off

set NDK_ROOT=%ANDROID_HOME%/ndk
set NDK_VER=23.2.8568313

set GOOS=android
set GOARCH=arm64
set CGO_ENABLED=1
set CC=%NDK_ROOT%/%NDK_VER%/toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android30-clang

set BIN=build/test
set TARGET_ROOT=/data/local/tmp/ionsfu
set TARGET_BIN=%TARGET_ROOT%/%BIN%

rem Build the executable
go build -work -o %BIN% main.go

if %errorlevel% neq 0 exit /b %errorlevel%

rem Setup adb.exe path
set PATH=%PATH%;%ANDROID_HOME%/platform-tools

rem Push the executable to the Android device
adb shell mkdir -p %TARGET_ROOT%

adb push %BIN% %TARGET_BIN%
adb shell chmod 777 %TARGET_BIN%

rem Run the executable on the Android device
echo:
adb shell "ip -4 -brief address show|grep -v lo"
echo:

adb shell %TARGET_BIN%
