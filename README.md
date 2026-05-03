# Sieve Herbal Remedies - Flutter App

A comprehensive herbal remedies mobile application built with Flutter.

## Features

- Browse 11 comprehensive herbs with detailed information
- Search and filter herbs by category
- Save favorite herbs
- Herb of the day feature
- Daily wellness tips
- Beautiful Material Design UI

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher

### Installation

1. Install dependencies:
```bash
flutter pub get
	2	Run the app:
flutter run
Project Structure
lib/
├── main.dart                 # App entry point
├── data/
│   └── herbs_data.dart      # Herb database
├── models/
│   └── herb.dart            # Herb model
├── navigation/
│   └── app_navigator.dart   # Bottom tab navigation
├── screens/
│   ├── home_screen.dart
│   ├── discover_screen.dart
│   ├── favorites_screen.dart
│   ├── tracker_screen.dart
│   ├── gardens_screen.dart
│   └── herb_detail_screen.dart
├── theme/
│   └── app_colors.dart      # Color scheme
├── utils/
│   └── storage.dart         # SharedPreferences wrapper
└── widgets/
    └── herb_card.dart       # Reusable herb card

## Android release notes

Follow these steps to prepare a release build for Google Play.

1. Generate Android platform (already done by this repository):

```bash
flutter create --platforms=android .
```

2. Generate an Android keystore (runs locally; do not commit the keystore or `android/key.properties`):

```bash
./scripts/generate_keystore.sh
# then follow prompts
```

3. Build a signed App Bundle for Play Store:

```bash
flutter build appbundle --release
```

4. Before uploading to Play Console, see [PLAY_STORE_SUBMISSION.md](PLAY_STORE_SUBMISSION.md) for the complete step-by-step submission guide.

Notes:
- `android/key.properties.template` is provided as a template. Copy it to `android/key.properties` and fill values, or run the script above.
- `android/key.properties` and `android/keystore/` are gitignored by default.
- The signed AAB file is located at: `build/app/outputs/bundle/release/app-release.aab`
- See `PRIVACY_POLICY.md` and `PLAY_STORE_SUBMISSION.md` for additional details.
