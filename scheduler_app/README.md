# Nux Scheduler

A simple Flutter (Android) scheduler: a week strip, a daily time/course list, a home page with
subjects and upcoming lessons, and add / edit / delete for events. Events are stored on the device.

## Install

Pre-built APKs are in `release/`:

- `nux-scheduler-arm64-v8a.apk` — almost all modern phones
- `nux-scheduler-armeabi-v7a.apk` — older 32-bit phones

They are signed with the Flutter debug key, so Android may ask you to allow installs from unknown sources.

## Build

```bash
flutter pub get
flutter test
flutter build apk --release --split-per-abi
```

## iOS (requires a Mac with Xcode)

The `ios/` project is included. It has not been built or tested on iOS yet, because it was generated on Linux.

```bash
cd scheduler_app
flutter pub get
open -a Simulator
flutter run
```

- **Simulator:** no Apple account needed.
- **Your own iPhone:** open `ios/Runner.xcworkspace` in Xcode, select the Runner target, go to
  Signing & Capabilities and pick your Team (a free Apple ID works). If Xcode reports the bundle ID is taken,
  change `com.nux.nuxScheduler` to something unique. Then run `flutter run` with the phone connected.
  Free-account installs expire after 7 days.
- **TestFlight / App Store / sharing with others:** needs the paid Apple Developer Program ($99/year).
  Build with `flutter build ipa`.
