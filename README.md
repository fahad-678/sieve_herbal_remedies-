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
