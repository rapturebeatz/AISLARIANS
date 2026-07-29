# Getting Started

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>=3.0.0)
- [Firebase account](https://console.firebase.google.com)
- Node.js (for Firebase CLI)

## Step-by-Step

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add project** → name it `aislar-connect`
3. Disable Google Analytics (optional)

### 2. Enable Services

| Service | What for | How |
|---|---|---|
| **Authentication** | Login | Enable Email/Password + Google providers |
| **Cloud Firestore** | Database | Create database (start in test mode) |
| **Firebase Storage** | Photos/docs | Use default rules initially |
| **Firebase Cloud Messaging** | Push notifications | No setup needed |

### 3. Register Apps

In Project Settings → General → Your apps:

**Web app:**
- Click `Add app` → Web → Copy the `firebaseConfig` values

**Android app:**
- Package name: `com.aislar.connect`
- Download `google-services.json` → place in `android/app/`

**iOS app:**
- Bundle ID: `com.aislar.connect`
- Download `GoogleService-Info.plist` → place in `ios/Runner/`

### 4. Configure & Deploy

```bash
# Navigate to project
cd AISLAR/project

# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Activate FlutterFire
dart pub global activate flutterfire_cli

# Generate Firebase config files
flutterfire configure --project=aislar-connect

# Deploy security rules
firebase deploy --only firestore:rules,firestore:indexes,storage

# Install dependencies
flutter pub get
```

### 5. Run

```bash
# Web (quickest to test)
flutter run -d chrome

# Android (connected device)
flutter run

# iOS (requires macOS)
cd ios && pod install && cd ..
flutter run
```

## Architecture

```
lib/
├── core/              # Shared: services, theme, constants
├── features/          # Feature modules (clean architecture)
│   └── {feature}/
│       ├── data/      # Repositories, data sources
│       ├── domain/    # Controllers, providers
│       └── presentation/ # Screens, widgets
├── models/            # Data models
├── app.dart           # App widget
└── main.dart          # Entry point
```

## Firebase Collections

22 collections auto-created on first write (no manual setup needed):

`users`, `profiles`, `roles`, `posts`, `comments`, `likes`, `chat_rooms`, `messages`, `events`, `attendees`, `albums`, `photos`, `videos`, `documents`, `businesses`, `jobs`, `polls`, `votes`, `notifications`, `donations`, `audit_logs`, `settings`

## Troubleshooting

| Issue | Fix |
|---|---|
| `FirebaseException: No Firebase App` | Run `flutterfire configure` again |
| `google-services.json not found` | Download from Firebase console → Android app |
| `CocoaPods not installed` | `sudo gem install cocoapods` |
| Chat not working | Check Firestore rules allow reads on `chat_rooms` |
