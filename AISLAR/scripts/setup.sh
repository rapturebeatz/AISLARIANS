#!/bin/bash
# AISLAR Connect - Firebase Setup Script
# Run this script after creating your Firebase project

echo "=== AISLAR Connect Firebase Setup ==="
echo ""

# Check for firebase CLI
if ! command -v firebase &> /dev/null; then
    echo "Installing Firebase CLI..."
    npm install -g firebase-tools
fi

# Check for flutter
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter is not installed."
    echo "Install it from https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "1. Login to Firebase..."
firebase login

echo ""
echo "2. List your Firebase projects..."
echo "   Create one at https://console.firebase.google.com if you haven't."
echo "   Project ID should be: aislar-connect"
echo ""
read -p "Enter your Firebase project ID: " PROJECT_ID

echo ""
echo "3. Set up FlutterFire CLI..."
dart pub global activate flutterfire_cli

echo ""
echo "4. Configure Firebase for Flutter..."
cd "$(dirname "$0")/project"
flutterfire configure --project=$PROJECT_ID --yes

echo ""
echo "5. Enable Firebase services:"
echo "   - Authentication: Email/Password, Google"
echo "   - Cloud Firestore (start in test mode, then deploy rules)"
echo "   - Firebase Storage"
echo "   - Firebase Cloud Messaging"
echo ""
echo "6. Deploy security rules..."
firebase deploy --only firestore:rules,firestore:indexes,storage

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Run the app:"
echo "  cd AISLAR/project"
echo "  flutter pub get"
echo "  flutter run -d chrome   # Web"
echo "  flutter run              # Connected device"
