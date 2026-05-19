# Dependencies Map: KidsTube Build System

## Current Mismatch Analysis
The project is transitioning to a "Standardized Modernization" state. However, the CI environment is lagging because local changes aren't committed, and some configuration files still contain legacy/duplicate blocks.

### ASCII Dependency Flow
```text
[ Flutter SDK (3.44+) ]
       |
       |--- [ pubspec.yaml ]
       |      |-- video_player: ^2.11.1 (Min AGP 8+)
       |      |-- photo_manager: ^3.9.0 (Min SDK 24)
       |
       |--- [ android/settings.gradle ] (Modern Declarative Source)
       |      |-- AGP (com.android.application): 8.11.1
       |      |-- Kotlin (org.jetbrains.kotlin.android): 2.2.20
       |      |-- Flutter Gradle Plugin: 1.0.0
       |
       |--- [ android/gradle-wrapper.properties ]
       |      |-- Gradle Version: 8.14 (Supports JDK 17/21, AGP 8.11)
       |
       |--- [ android/app/build.gradle ]
       |      |-- Compile/Target SDK: 35 (Android 15)
       |      |-- Java/Kotlin Compatibility: 17
       |      |-- Namespace: com.kidstube.app
```

## Moving Parts & Risks
1. **Gradle vs AGP:** Using Gradle 8.14 requires at least AGP 8.x. We are moving to 8.11.1, which is a stable match.
2. **Kotlin Migration:** The app is moving to "Built-in Kotlin" (declarative). Legacy `buildscript` blocks in `android/build.gradle` must be removed to avoid "Duplicate plugin" errors.
3. **Android Resources:** `AndroidManifest.xml` currently points to a system icon because `mipmap/ic_launcher` was accidentally deleted. This is a "safe" temporary fix but prevents custom branding.
4. **CI Environment:** The GitHub Action runner (`ubuntu-24.04`) comes with Node 20/24 and JDK 17, which matches our target, but we must ensure `flutter-action` uses the `stable` channel.

## Proposed Future State (The "Golden" Config)

| Component | Target Version | Why? |
| :--- | :--- | :--- |
| **Flutter** | `stable` (3.44.x) | Matches current development toolchain. |
| **Gradle** | `8.14` | Latest stable; required for Android 15 toolchains. |
| **AGP** | `8.11.1` | Optimal compatibility with Gradle 8.14 and Flutter 3.44. |
| **Kotlin** | `2.2.20` | Full support for Kotlin 2.0 features and modern Android. |
| **JDK** | `17` | Required by modern AGP/Gradle. |
| **Target SDK** | `35` | Future-proof for Android 15. |

## Strategy for Smooth Builds
1. **Single Source of Truth:** Keep all versioning in `settings.gradle` (Declarative).
2. **Clean build.gradle:** Remove `buildscript` and `allprojects` blocks from the root `android/build.gradle`; they are handled by the `pluginManagement` block in `settings.gradle`.
3. **Resource Safety:** Never delete `res/mipmap-*` folders again. If icons are missing, regenerate them using `flutter_launcher_icons`.
