# display_cast_flutter

AirSync Sender for Flutter [Android(java), iOS(swift), MacOS, Web, Windows)]

## Configurations description
Android will using "productFlavors" to separate different deploy channel: IFP, OPEN, STORE.

Configurations name will combination environment name and this "productFlavors" to naming.

#### environment:
* **Dev**: for dev environment (Developer)

* **Production**: for production environment (EndUser)

* **Stage**: for stage environment (Internal Test)

#### productFlavors:
* **no_flavor**: This is no flavor required App (none Android)

* **ifp**: This is Android system App, sign with viewsonic Platform key.

* **open**: This is Android normal App, sign with viewsonic key. Download link in myViewboard.com for other brand device

* **store**: This is Android normal App, sign with viewsonic key. Deploy to Google Play Store.

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

