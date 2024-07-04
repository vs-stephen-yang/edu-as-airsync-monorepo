# flutter_ion_sfu

A flutter plugin for ion sfu.

# Setup

```
flutter pub get

git submodule init
git submodule update
```

# Devlopment

1. First, open the project from root folder with Android Studio
1. Build the project
1. Then, re-open the project from example/android folder with Android Studio
1. Build the project
1. Whenever you modify golang source codes under libionsfu folder
   1. Build libionsfu.aar with scripts/android/build-aar.cmd
   1. Delete the build folder
   1. Re-build the project

# Test without flutter

```
# Run the ion sfu server on Android
.\scripts\android\run.cmd

# Run the ion sfu server on Windows
.\scripts\windows\run.cmd
```

# Language binding

Gobind generates bindings for calling Go functions from Java.

Debug the bindings by viewing the java files in `android/libs/libionsfu-sources.jar`
