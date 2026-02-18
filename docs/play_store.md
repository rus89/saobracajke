# Android Google Play Store — release checklist

Use this when preparing an app update for the Play Store.

## Version

- Version is defined in `pubspec.yaml`: `version: 1.0.0+1` (versionName `1.0.0`, versionCode `1`). Bump before each store update (e.g. `1.0.1+2`).
- Android reads versionCode and versionName from Flutter; no separate edit in `build.gradle.kts` is needed.

## Signing

- Release builds are signed when `android/key.properties` exists and contains `storeFile`, `keyAlias`, `storePassword`, and `keyPassword`.
- Copy `android/key.properties.example` to `android/key.properties` and fill in your upload keystore details. `key.properties` is gitignored.
- Create an upload keystore if needed: [Flutter signing docs](https://docs.flutter.dev/deployment/android#signing-the-app).
- Without `key.properties`, release builds use debug signing (so `flutter build appbundle` still runs e.g. on CI).

## Build

From project root:

```bash
flutter build appbundle
```

Output: `build/app/outputs/bundle/release/app-release.aab`. Upload this in Play Console.

## Release config (already set)

- `compileSdk` is 36 (required by some plugins; backward compatible).
- `targetSdk` is 35 to meet [Google Play target API requirements](https://developer.android.com/google/play/requirements/target-sdk).
- `minSdk` follows Flutter default (21).

## Store listing (Play Console)

Done in Google Play Console, not in the repo:

- Short and full description, screenshots, feature graphic, app icon (icon is in the app as `@mipmap/launcher_icon`).
- Content rating, privacy policy URL if required, target audience.

## Before uploading

- Run `flutter analyze` and `flutter test`.
- Install and test a release build locally: `flutter run --release` or install the AAB on a device via internal testing.
