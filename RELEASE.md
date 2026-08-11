# Build & Release Process Specification

This document details the build configurations, environment keys, compilation commands, and code-signing procedures required to generate production-ready release builds of the Todo Management Application across Android, iOS, and Web platforms.

---

## 1. Build Configurations

Flutter supports three compilation modes:
* **Debug Mode:** Utilized during local development. Supports Hot Reload, includes complete service asserts, and attaches Dart VM service debug ports.
* **Profile Mode:** Retains sufficient debugging logs for performance profiling (via DevTools).
* **Release Mode:** Optimizes compilation for performance and file size. Disables asserts, strips debug symbols, and compiles code to native machine code (or highly optimized JavaScript/Wasm for Web).

---

## 2. Environment Configuration

The application uses an **Offline-First Hybrid Sync Service**. Switching between sandboxed **Mock Mode** and a live cloud database is configured via custom credentials inside the application drawer:

* **Mock Mode (Default):** Runs when live credentials are absent. Executes queries against memory-backed lists stored locally inside SharedPreferences.
* **Live Mode:** Supply a valid `Supabase URL` and `Anon API Key` inside the settings drawer to initialize the real Supabase Client. User registration, real-time replication streams, and PostgreSQL queries will run live.

---

## 3. Platform Compilation & Release Steps

### 3.1. Flutter Web Deployment (Primary)

Flutter compiles Dart into optimized HTML/CSS/JavaScript components ready for CDN deployment.

#### Compilation Command:
```bash
flutter build web --release
```
This builds optimized release bundles inside the `build/web/` directory.

#### Hosting & Deployment:
1. **Hosting Providers:** The `build/web/` directory can be uploaded directly to static hosting platforms such as Firebase Hosting, Netlify, Vercel, or AWS S3.
2. **Caching Policy:** Ensure the HTTP headers configure:
   * `Cache-Control: no-cache` for `index.html` and `flutter_service_worker.js` (ensuring clients retrieve updates instantly).
   * `Cache-Control: max-age=31536000` for assets in `/assets/` directory (highly cacheable).

---

### 3.2. Android Release Build

To distribute the app through the Google Play Store (via Android App Bundle) or direct installs (APK):

#### 1. Code Signing (Keystore Generation):
Generate a secure upload keystore file using `keytool`:
```bash
keytool -genkey -v -keystore C:/Users/iniya/todo_app/android/app/upload-keystore.jks -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

#### 2. Configure Build Properties:
Create `android/key.properties` to reference the keystore:
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=upload
storeFile=C:/Users/iniya/todo_app/android/app/upload-keystore.jks
```

#### 3. Run Compilation Commands:
* To compile a single **APK** for direct distribution:
  ```bash
  flutter build apk --release
  ```
  Resulting APK location: `build/app/outputs/flutter-apk/app-release.apk`
* To compile an **Android App Bundle (AAB)** for Google Play Store upload:
  ```bash
  flutter build appbundle --release
  ```
  Resulting AAB location: `build/app/outputs/bundle/release/app-release.aab`

---

### 3.3. iOS Release Build

iOS builds require a macOS workstation with Xcode installed and an active Apple Developer Program membership.

#### 1. Configure Signing:
1. Open the `/ios` project directory inside **Xcode**.
2. Under **Signing & Capabilities**, select your developer team and check **Automatically manage signing**. This downloads the necessary Provisioning Profiles and Signing Certificates.

#### 2. Run Compilation Command:
Compile the iOS archive bundle:
```bash
flutter build ipa --release
```
This command compiles the app bundle and packages it inside `build/ios/ipa/` directory.

#### 3. Upload to App Store Connect:
Upload the generated `.ipa` archive directly using Xcode Organizer or Transporter to distribute via TestFlight (beta testing) or release on the App Store.
