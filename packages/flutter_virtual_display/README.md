# flutter_virtual_display

# How-tos

## Install Virtual Display Driver into Driver Store

```
pnputil /add-driver indirect_display_1_0.inf
```

## Create Window Service for Virtual Display

```
sc create "Viewsonic AirSync Virtual Display Service" start=auto binPath=%rootpath%\windows\virtual-display-service-bin\x64\Release\virtual-display-service.exe
```

## Start Virtual Display Service
```
sc start "Viewsonic AirSync Virtual Display Service"
```

## Stop Virtual Display Service
```
sc stop "Viewsonic AirSync Virtual Display Service"
```

## Delete Window Service for Virtual Display
```
sc delete "Viewsonic AirSync Virtual Display Service"
```

## Disable Window Service Check
### When you want to see the logs, so that you want to run the virtual display service in console.

```
--- a/windows/flutter_virtual_display.cpp
+++ b/windows/flutter_virtual_display.cpp
@@ -19,7 +19,7 @@ const char* kEventChannelName = "FlutterVirtualDisplay.Event";

 FlutterVirtualDisplay::FlutterVirtualDisplay(flutter::BinaryMessenger* messenger)
     : messenger_(messenger) {
-  sn_client_ = std::make_unique<SNClient>();
+  sn_client_ = std::make_unique<SNClient>(false); // DISABLE SERVICE CHECK
   event_channel_ = EventChannelProxy::Create(messenger, kEventChannelName);
 }
```
