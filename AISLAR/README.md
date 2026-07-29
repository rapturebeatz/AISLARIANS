# AISLAR Connect

**One Class. One Network. Forever Connected.**

A cross-platform alumni community platform built with Flutter and Firebase.

## Project Structure

```
AISLAR/
├── docs/
│   ├── 01-srs.md              # Software Requirements Specification
│   └── 02-database-design.md  # Firestore database design (Next deliverable)
├── design/                     # UI/UX design assets
├── project/                    # Flutter application
│   ├── lib/
│   │   ├── core/              # Shared utilities, theme, routing
│   │   ├── features/          # Feature modules (auth, feed, chat, etc.)
│   │   │   └── {feature}/
│   │   │       ├── data/      # Repositories, data sources
│   │   │       ├── domain/    # Entities, use cases
│   │   │       └── presentation/ # UI screens, controllers
│   │   ├── models/            # Data models
│   │   └── main.dart
│   ├── assets/
│   └── pubspec.yaml
└── README.md
```

## Tech Stack

- **Frontend**: Flutter (Web, Android, iOS)
- **Backend**: Firebase
- **Auth**: Email, Google Sign-In, Phone OTP
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage
- **Push**: Firebase Cloud Messaging
- **Hosting**: Firebase Hosting

## MVP Features

- Secure authentication with admin approval
- Alumni directory with search
- Member profiles
- Community feed (posts, likes, comments)
- Real-time group chat
- Events with RSVP
- Photo gallery
- Push notifications
- Admin dashboard

## Getting Started

1. Install [Flutter](https://flutter.dev/docs/get-started/install)
2. Clone this repo
3. Create a Firebase project and download `google-services.json` / `GoogleService-Info.plist`
4. Run `cd AISLAR/project && flutter pub get`
5. Run `flutter run -d chrome` (web) or `flutter run` (mobile)

## Roadmap

1. Database design (done)
2. UI/UX design in Figma
3. Flutter project setup (done)
4. Authentication & member management
5. Core features (feed, directory, profile, chat)
6. Events & gallery
7. Admin dashboard
8. Android & iOS release

## License

MIT
