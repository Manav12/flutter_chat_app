# Chat App

A real-time chat app made in Flutter, using Firebase for login and messages.

## What This App Do

- User can register and login with email and password.
- After login, user see list of all other user, with last message preview.
- User can open a chat and send, edit, delete text message in real time.
- Unread message count show on home screen, like WhatsApp.
- Works fine on different screen size and both portrait/landscape.

## How It Is Built

App follow Clean Architecture. Each feature (`auth`, `users`, `chat`) is split in three layer:

- **domain** — entities, repository contracts, use cases. No Flutter or Firebase code here.
- **data** — models, Firebase data sources, repository implementation.
- **presentation** — Bloc, pages, widgets.

Some other choices:

- **Bloc** for state management.
- **get_it** for dependency injection.
- **Hive** for local caching, so app can show something even when offline.
- **go_router** with one central redirect, so login/logout navigation always correct.
- Own simple `Result<T>` type instead of using dartz/fpdart package, keep it light.

## How To Run

1. Run `flutter pub get` to install package.
2. Firebase is already set up (`firebase_options.dart` in repo).
3. Run `flutter run` to start app on connected device or emulator.

## How To Run Tests

Run `flutter test` — this run all unit, bloc, and widget test.

## Feature Checklist

| Requirement | Done |
|---|---|
| Email/password auth | Yes, Firebase Auth |
| Real-time messaging | Yes, Firestore live listener |
| Send / edit / delete message | Yes |
| Offline caching | Yes, Hive |
| Dependency injection | Yes, get_it |
| Unit / bloc / widget tests | Yes |
| Loading, error, empty states | Yes |
| Responsive UI | Yes |
