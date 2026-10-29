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
