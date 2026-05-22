# Dependencies Map: KidsTube Build System

## Current Build State (The "Golden State")
The project is fully modernized using Kotlin DSL (`.kts`) and perfectly aligned with the official Flutter 3.44 templates.

### ASCII Dependency Flow
```text
[ Flutter SDK (Stable 3.44+) ]
       |
       |--- [ pubspec.yaml ] (Verified)
       |
       |--- [ android/settings.gradle.kts ] (Declarative Plugin Source)
       |      |-- pluginManagement: includeBuild(flutter_tools)
       |      |-- id("dev.flutter.flutter-plugin-loader"): 1.0.0
       |      |-- AGP (com.android.application): 8.11.1
       |      |-- Kotlin (org.jetbrains.kotlin.android): 2.2.20
       |
       |--- [ android/gradle-wrapper.properties ]
       |      |-- Gradle Version: 8.14 (Verified)
       |
       |--- [ android/app/build.gradle.kts ]
       |      |-- plugins { application, flutter }
       |      |-- Compile/Target SDK: flutter.sdk (API 34/35)
       |      |-- Java Compatibility: 17
       |      |-- Namespace: com.kidstube.app
```

## Moving Parts & Verified Baseline
1. **Kotlin DSL:** Fully migrated to `.kts` files.
2. **Built-in Kotlin:** Successfully integrated. The Flutter plugin handles Kotlin compilation automatically.
3. **Bundled Assets:** Added `assets/videos/demo_video.mp4` (22MB) and `assets/videos/admin_demo.mp4` (5MB). Both verified to contain audio streams.
4. **Audio Verification:** Programmable volume checks added to integration tests to ensure sound is not muted by default.
5. **APK Location:** Standard build paths restored to ensure CI artifact collection.
6. **CI/CD:** Ubuntu runner, Node 20, JDK 17, Flutter Stable.

## Golden Configuration Reference

| Component | Version | Role |
| :--- | :--- | :--- |
| **Flutter** | `stable` | Framework SDK |
| **Gradle** | `8.14` | Build Automation |
| **AGP** | `8.11.1` | Android Gradle Plugin |
| **Kotlin** | `2.2.20` | Language Runtime |
| **JDK** | `17` | Compilation Environment |
| **Target SDK** | `34/35` | Android API Level |

## Mandatory Flags (gradle.properties)
| Flag | Value | Why? |
| :--- | :--- | :--- |
| `android.builtInKotlin` | `true` | Enables modern Flutter integration. |
| `android.newDsl` | `true` | Required for .kts support. |

## Strategy for Smooth Builds
1. **Single Source of Truth:** All versioning MUST stay in `settings.gradle.kts`.
2. **Kotlin DSL ONLY:** Never add or revert to `.gradle` files.
3. **Template Integrity:** Strictly follow the discovered Flutter 3.44 structure.
4. **Resource Protection:** Do not modify `android/app/src/main/res` without verifying existence.
