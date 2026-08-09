# Todo App

This Flutter Todo Management application is built for web (Chrome) and mobile.

Features

- Material 3 theming
- `Todo` domain model with JSON serialization
- `TodoRepository` with SharedPreferences persistence
- Riverpod provider for app state
- `TodoApiService` HTTP client scaffold
- Supabase initialization scaffolding
- Unit tests for repository persistence

Quick start

1. Install dependencies

```bash
flutter pub get
```

2. Run tests

```bash
flutter test
```

3. Run in Chrome

```bash
flutter run -d chrome
```

Production build

```bash
flutter build web --release
```

Notes

- To enable Supabase, call `SupabaseService.initialize(url: '<URL>', anonKey: '<ANON_KEY>')` early in `main()` before using the client.
- `todo_api_service.dart` expects a REST API at `baseUrl` with CRUD endpoints under `/todos`.

Next steps

- Add widget and integration tests
- Wire Supabase auth and realtime sync
- Polish UI and accessibility

Contact

This workspace is managed locally. For assistance, run the app locally and open issues in your preferred VCS.
