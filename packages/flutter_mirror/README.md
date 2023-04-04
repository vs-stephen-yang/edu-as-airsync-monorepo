# Set up the Development Environment

## Install Android Studio

## Install Flutter SDK
Install Flutter SDK 3.3.10+

checks your environment and displays a report of the status of your Flutter installation
```
flutter doctor
```

## Add credentials for Azure Artifacts

1. Add or edit the gradle.properties file in %USERPROFILE%\.gradle\
 ```
  AZURE_ARTIFACTS_USERNAME=viewsonic-ssi
  AZURE_ARTIFACTS_PASSWORD=
 ```
2. On Azure DevOps, generate a Personal Access Tokens with Packaging read & write scopes. Paste the token into the AZURE_ARTIFACTS_PASSWORD.

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
