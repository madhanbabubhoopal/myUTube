# Dependencies Map: KidsTube Build System

## Current Build State (The "Golden" Config)
The project is fully aligned with the modernized declarative Gradle structure. Local and CI environments use identical toolchains.

### ASCII Dependency Flow
```text
[ Flutter SDK (Stable 3.44+) ]
       |
       |--- [ pubspec.yaml ]
       |      |-- video_player: ^2.11.1 (Min AGP 8+)
       |      |-- photo_manager: ^3.9.0 (Min SDK 24)
       |
       |--- [ android/settings.gradle ] (Declarative Source of Truth)
       |      |-- AGP (com.android.application): 8.11.1
       |      |-- Kotlin (org.jetbrains.kotlin.android): 2.2.20
       |      |-- Flutter Gradle Plugin: 1.0.0
       |
       |--- [ android/gradle-wrapper.properties ]
       |      |-- Gradle Version: 8.14 (Supports JDK 17, AGP 8.11)
       |
       |--- [ android/app/build.gradle ]
       |      |-- Compile/Target SDK: 35 (Android 15)
       |      |-- Java/Kotlin Compatibility: 17
       |      |-- Namespace: com.kidstube.app
```

## Moving Parts & Current Baseline
1. **Gradle/AGP:** Gradle 8.14 + AGP 8.11.1. This is the latest stable pairing for Flutter 3.44.
2. **Built-in Kotlin:** Successfully migrated to the declarative `plugins` block. Legacy `buildscript` and `allprojects` blocks have been removed from the root `android/build.gradle`.
3. **Android Resources:** `AndroidManifest.xml` uses `@android:drawable/ic_menu_gallery` as a temporary placeholder icon. 
4. **CI/CD:** GitHub Action runners are configured with Node 20 and JDK 17 to match the build requirements.

## Golden Configuration Reference

| Component | Version | Role |
| :--- | :--- | :--- |
| **Flutter** | `stable` | Framework SDK |
| **Gradle** | `8.14` | Build Automation |
| **AGP** | `8.11.1` | Android Gradle Plugin |
| **Kotlin** | `2.1.0` (`kotlin-android`) | Language Runtime |
| **JDK** | `17` | Compilation Environment |
| **Target SDK** | `35` | Android API Level |

## Mandatory Flags (gradle.properties)
| Flag | Value | Why? |
| :--- | :--- | :--- |
| `android.builtInKotlin` | `true` | Enables modern Flutter-Kotlin integration. |
| `android.newDsl` | `true` | Required for declarative plugin management. |
| `android.useAndroidX` | `true` | Standard for modern Android development. |

## Strategy for Smooth Builds
1. **Single Source of Truth:** All versioning MUST stay in `settings.gradle`.
2. **Explicit Repositories:** Keep `allprojects` in `build.gradle` with the Flutter Maven URL (`https://storage.googleapis.com/download.flutter.io`) to ensure background compilation tasks (like Kotlin) have immediate access to SDK classes.
3. **Root build.gradle:** Keep it clean except for shared repositories.
3. **Resource Protection:** Do not modify `android/app/src/main/res` without verifying existence.
