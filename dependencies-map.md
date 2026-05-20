# Dependencies Map: KidsTube Build System

## Current Build State (Verified Kotlin DSL)
The project has successfully transitioned to Kotlin DSL (`.kts`), which is the mandatory standard for Flutter 3.44+ builds. Local and CI environments use verified identical configurations.

### ASCII Dependency Flow
```text
[ Flutter SDK (Stable 3.44+) ]
       |
       |--- [ pubspec.yaml ] (Verified)
       |      |-- video_player: ^2.11.1
       |      |-- photo_manager: ^3.9.0
       |
       |--- [ android/settings.gradle.kts ] (The "Golden" Source)
       |      |-- pluginManagement: includeBuild(flutter_tools)
       |      |-- AGP (com.android.application): 8.11.1
       |      |-- Kotlin (org.jetbrains.kotlin.android): 2.1.0
       |
       |--- [ android/gradle-wrapper.properties ]
       |      |-- Gradle Version: 8.14 (Verified)
       |
       |--- [ android/app/build.gradle.kts ]
       |      |-- plugins { application, kotlin-android, flutter }
       |      |-- Compile/Target SDK: 34 (Android 14)
       |      |-- Language: Kotlin (Standardized)
       |      |-- Namespace: com.kidstube.app
```

## Moving Parts & Verified Baseline
1. **Kotlin DSL:** Fully migrated to `.kts` files. Groovy `.gradle` files have been removed.
2. **Build Success:** Verified via CI run `26132729615`.
3. **Android Resources:** `AndroidManifest.xml` uses system placeholder icon.
4. **CI/CD:** Using Node 20 and JDK 17 on Ubuntu runners.

## Golden Configuration Reference

| Component | Version | Role |
| :--- | :--- | :--- |
| **Flutter** | `stable` | Framework SDK |
| **Gradle** | `8.14` | Build Automation |
| **AGP** | `8.11.1` | Android Gradle Plugin |
| **Kotlin** | `2.1.0` | Language Runtime |
| **JDK** | `17` | Compilation Environment |
| **Target SDK** | `34` | Android 14 (Stable Baseline) |

## Mandatory Flags (gradle.properties)
| Flag | Value | Why? |
| :--- | :--- | :--- |
| `android.builtInKotlin` | `true` | Required for modern Flutter integration. |
| `android.newDsl` | `true` | Required for .kts support. |
| `android.useAndroidX` | `true` | Standard modern Android. |

## Strategy for Smooth Builds
1. **Single Source of Truth:** All versioning MUST stay in `settings.gradle.kts`.
2. **Kotlin DSL ONLY:** Never add or revert to `.gradle` files in the `android/` directory.
3. **Scaffold Integrity:** If build fails, verify against a fresh `flutter create` template for the current SDK version.
4. **Resource Protection:** Do not modify `android/app/src/main/res` without verifying existence.
