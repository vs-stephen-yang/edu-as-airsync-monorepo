# Set up the Development Environment

## Install Android Studio

## Install Flutter SDK

Install Flutter SDK 3.3.10+

checks your environment and displays a report of the sta7tus of your Flutter installation

```
flutter doctor
```

## Add credentials for Azure Artifacts

1. Add or edit the `gradle.properties` file under Gradle user home directory (which defaults to <home directory of the current user>/.gradle if not set)

```
 AZURE_ARTIFACTS_USERNAME=viewsonic-ssi
 AZURE_ARTIFACTS_PASSWORD=
```

2. On Azure DevOps, [generate a Personal Access Tokens](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows#create-a-pat) with Packaging read & write scopes. Paste the token into the AZURE_ARTIFACTS_PASSWORD.

## Copy IFP keystore files

1. Create a `keystore` folder under %USERPROFILE%
2. Copy the keystore file (.jks) and its properties file (e.g. `keystore.properties`) to the `keystore` folder
3. Edit the keystore path in `keystore.properties`

```
storeFile=c:/users/<user>/keystore/keystore.jks
```

# Development

1. Run `flutter pub get` in the root folder
1. Use `adb connect` to connect to the Android device

## Development with Android Studio

Method 1: You want to debug Java or C++

1. In Android Studio, open example\android folder
1. Run > Run 'app' or Debug 'app'

Method 1: You want to debug Dart

1. In Android Studio, open example folder
1. Run > Run 'main.dart' or Debug 'main.dart'

## Development with Visual Studio Code

1. In Visual Studio Code, open the root folder
1. Press F5 to run the example App

## Development with local airplay and googlecast folders

googlecast

1. cd android/src/main/cpp/googlecast
1. git clone https://viewsonic-ssi.visualstudio.com/Display%20App/_git/googlecast
1. git submodule init
1. git submodule update
1. Patch android/build.gradle to remove googlecast dependency
1. Patch android/src/main/cpp/googlecast/CMakeLists.txt to add the local googlecast into the build

See the `local-dependency-dev` branch for how to patch the build scripts.

airplay

1. cd to android/src/main/cpp/airplay
1. `git clone https://viewsonic-ssi.visualstudio.com/Display%20App/_git/airplay`
1. `git submodule init`
1. `git submodule update`
1. Patch `android/build.gradle` to remove airplay dependency
1. Patch `android/src/main/cpp/airplay/CMakeLists.txt` to add the local airplay into the build
1. There are some file changes required when using a local build of AirPlay. You need to apply these patches manually.
   1. In `android/build.gradle` 
      1. Remove the line `implementation 'com.viewsonic.airplay:airplay:0.18.0'`
   1. In `android/src/main/cpp/airplay/CMakeLists.txt`
      1. Change the line `#find_package(airplay REQUIRED CONFIG)` to `add_subdirectory(airplay)`
      1. Change the line `airplay::airplayreceiver` to `airplayreceiver`  

See the branch for how to patch the build scripts.

# Troubleshooting

```
flutter_airplay\example\.dart_tool\package_config.json does not exist.
Did you run this command from the same directory as your pubspec.yaml file?
```

```
flutter.sdk not set in local.properties. Expression: (flutterSdkPath != null). Values: flutterSdkPath = null
```

Run `flutter pub get`

```
Because flutter_airplay requires SDK version >=2.18.6 <3.0.0, version solving failed
```

Upgrade flutter to the latest version. Run `flutter upgrade`
