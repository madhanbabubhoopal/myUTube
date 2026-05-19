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
       |      |-- Kotlin (org.jetbrains.kotlin.android): 2.1.0 (apply false)
       |      |-- Flutter Gradle Plugin: 1.0.0
       |
       |--- [ android/gradle-wrapper.properties ]
       |      |-- Gradle Version: 8.14 (Supports JDK 17, AGP 8.11)
       |
       |--- [ android/app/build.gradle ]
       |      |-- Compile/Target SDK: 34 (Android 14)
       |      |-- Java Compatibility: 17
       |      |-- Language: Java (Fallback verification baseline)
       |      |-- Namespace: com.kidstube.app
```

## Moving Parts & Current Baseline
1. **Gradle/AGP:** Gradle 8.14 + AGP 8.11.1. This is the latest stable pairing for Flutter 3.44.
2. **Java Fallback:** Temporarily switched to `MainActivity.java` to verify Flutter SDK linking while bypassing Kotlin toolchain issues.
3. **Android Resources:** `AndroidManifest.xml` uses `@android:drawable/ic_menu_gallery` as a temporary placeholder icon. 
4. **CI/CD:** GitHub Action runners are configured with Node 20 and JDK 17.

## Golden Configuration Reference

| Component | Version | Role |
| :--- | :--- | :--- |
| **Flutter** | `stable` | Framework SDK |
| **Gradle** | `8.14` | Build Automation |
| **AGP** | `8.11.1` | Android Gradle Plugin |
| **Language** | `Java 17` (Fallback) | Verification Baseline |
| **JDK** | `17` | Compilation Environment |
| **Target SDK** | `34` | Android 14 (Stable Baseline) |

## Mandatory Flags (gradle.properties)
| Flag | Value | Why? |
| :--- | :--- | :--- |
| `android.builtInKotlin` | `true` | Enables modern Flutter-Kotlin integration. |
| `android.newDsl` | `true` | Required for declarative plugin management. |
| `android.useAndroidX` | `true` | Standard for modern Android development. |

## Strategy for Smooth Builds
1. **Single Source of Truth:** All versioning MUST stay in `settings.gradle`.
2. **Java Baseline:** Using `MainActivity.java` to verify Flutter SDK linking, bypassing Kotlin issues.
3. **Explicit Repositories:** Keep `allprojects` in `build.gradle` with the Flutter Maven URL.
4. **Resource Protection:** Do not modify `android/app/src/main/res` without verifying existence.
