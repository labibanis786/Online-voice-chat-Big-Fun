Firebase setup steps (brief):
1) Create Firebase project at https://console.firebase.google.com/
2) Add Android app with package name: com.example.big_fan_voice_chat
3) Download google-services.json and place it under android/app/
4) In Firebase console enable Authentication -> Phone
5) In Firestore create collections: rooms, gifts (or they auto-create)
6) For production enable proper security rules.