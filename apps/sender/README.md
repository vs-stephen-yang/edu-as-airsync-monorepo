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
