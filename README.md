# Big Fan Voice Chat - Final Package

This package includes:
- Agora voice integration (agoraAppId pre-filled)
- Firebase phone OTP authentication skeleton (requires Firebase project + google-services.json)
- Multiple rooms (Firestore-backed)
- Simple gifting system (writes to 'gifts' collection)
- Codemagic workflow (codemagic.yaml)
- README_FIREBASE.txt has Firebase setup steps

Important next steps before building:
1) Firebase: create Firebase project, add Android app with package `com.example.big_fan_voice_chat`, download `google-services.json` and put it into `android/app/`.
2) Enable Phone Authentication in Firebase Console (Authentication -> Sign-in method -> Phone).
3) In lib/constants.dart Agora App ID is already set to: 739a61014ae64d2eaf7dd9eb4872664e
4) If your Firebase project requires SHA-1 for phone auth, add SHA-1 in Firebase project settings (you can get SHA-1 from your keystore).
5) (Optional) Add your Android keystore for signing; do NOT commit keystore to public repo. Use Codemagic secure variables for signing setup.
6) Run locally to test:
   - flutter pub get
   - flutter pub run flutter_launcher_icons:main
   - flutter run

Notes on security and production:
- This repository intentionally contains skeleton code. For production, you MUST secure Firestore rules and use tokens for Agora if using App Certificate.
- Do not commit secrets (keystore, google-services.json for private projects) to public repos.

If you want, I can also prepare a Codemagic signing guide or upload instructions.