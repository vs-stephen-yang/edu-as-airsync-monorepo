# display_cast_flutter

AirSync Sender for Flutter [Android(java), iOS(swift), MacOS, Web, Windows)]

## Flutter SDK Version Requirements
This project requires **Flutter SDK** version 3.24.2.

## Configurations description
Android will using "productFlavors" to separate different deploy channel: IFP, OPEN, STORE.

Configurations name will combination environment name and this "productFlavors" to naming.

#### environment:
* **Dev**: for dev environment (Developer)

* **Production**: for production environment (EndUser)

* **Stage**: for stage environment (Internal Test)

## Version control description

A version number is three numbers separated by dots, like 1.2.43
followed by an optional build number separated by a +.

#### Version number:
##### Major, Minor, Point(build)

* **Major**: Modify this number when has Big changed like using different program language or main framework has change, etc (Demand)

* **Minor**: Modify this number when each Production Release (Quarterly)

* **Point(build)**: Modify this number when each Stage Release (Bi-Weekly)

#### Build number:
##### <font color=red>**DO NOT**</font> using this "Build number" to identify Production/ Stage/ Dev settings, using "ConfigSettings" to set different environment settings.
##### Upload to App Store will using  this "Build number" to deploy to different channel.
![Image](/README_TestFlight.png)

* **Even number**:
    * Apple App Store: Production
    * Google Play Store: Production

* **Odd number**:
    * Apple App Store: TestFlight
    * Google Play Store: Testing -> Closed testing


# __Other Packages__

## [figma2flutter](https://pub.dev/packages/figma2flutter)

- Run the command in the root of your project to generate tokens:

`figma2flutter --input ./design/airsync-vsdsw-token-v2.json --output ./lib/assets/tokens/`

# Deployment

## Build WEB PWA on local
Run the build script to build PWA supports offline
```
flutter build web --target=lib/main_dev.dart --pwa-strategy=none

dart web/generate_assets.dart
```


