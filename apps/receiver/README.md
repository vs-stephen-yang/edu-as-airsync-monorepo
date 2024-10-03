# display_flutter

AirSync for Flutter [Android(java), iOS(swift), MacOS, Web, Windows)]

## __[Flutter SDK Version Requirements]__
This project requires **Flutter SDK** version 3.24.2.

## __[Configurations description]__

Android will using "productFlavors" to separate different deploy channel: EDLA, IFP, OPEN, STORE.

Configurations name will combination environment name and this "productFlavors" to naming.

### __channel:__

* **EDLA**: for ViewSonic EDLA model (Preload APK in ViewSonic EDLA model)
  * Sign with platform key and **<font color=red>NOT Set</font>** android:sharedUserId="android.uid.system" in AndroidManifest.xml

* **IFP**: for ViewSonic AOSP model (Preload APK in ViewSonic AOSP model)
  * Sign with platform key and **<font color=green>Set</font>** android:sharedUserId="android.uid.system" in AndroidManifest.xml

* **OPEN**: for Others AOSP model (Download APK from myViewboard.com)
  * Sign with normal key

* **STORE**: for Google Play Store publish (Download APK from Google Play Store)
  * Sign with normal key

### __environment:__

* **Dev**: for dev environment (Developer)

* **Production**: for production environment (EndUser)

* **Stage**: for stage environment (Internal Test)

## __[Version control description]__

A version number is three numbers separated by dots, like 1.2.43
followed by an optional build number separated by a +.

### __Version number:__
* #### Major, Minor, Point(build)

  * **Major**: Modify this number when has Big changed like using different program language or main framework has change, etc (Demand)

  * **Minor**: Modify this number when each Production Release (Monthly) or (Quarterly)

  * **Point(build)**: Modify this number when each Stage Release (Weekly) or (Bi-Weekly)

### __Build number:__
* #### <font color=red>**DO NOT**</font> using this "Build number" to identify Production/ Stage/ Dev settings, using "ConfigSettings" to set different environment settings.
* #### Upload to App Store will using  this "Build number" to deploy to different channel.

  * **Even number**:
    * Apple App Store: Production
    * Google Play Store: Production

  * **Odd number**:
    * Apple App Store: TestFlight
    * Google Play Store: Testing -> Closed testing

![Image](/README_TestFlight.png)

![Image](/README_GooglePlay.png)

# __Other Packages__

## [figma2flutter](https://pub.dev/packages/figma2flutter)

- Run the command in the root of your project to generate tokens:

`figma2flutter --input ./design/airsync-token-v3-2.json --output ./lib/assets/tokens/`
