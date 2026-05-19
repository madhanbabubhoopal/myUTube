# Dependencies Map: KidsTube Build System

## Current Build State (Template-Aligned)
The project is now perfectly aligned with the official Flutter 3.44 'Golden Template' discovered via CI scaffolding.

### ASCII Dependency Flow
```text
[ Flutter SDK (Stable 3.44+) ]
       |
       |--- [ pubspec.yaml ]
       |      |-- video_player: ^2.11.1 (Min AGP 8+)
       |      |-- photo_manager: ^3.9.0 (Min SDK 24)
       |
       |--- [ android/settings.gradle ] (Template-Aligned Source of Truth)
       |      |-- pluginManagement: includeBuild(flutter_tools)
       |      |-- AGP (com.android.application): 8.11.1
       |      |-- Kotlin (org.jetbrains.kotlin.android): 2.1.0
       |      |-- Flutter Gradle Plugin: 1.0.0
       |
       |--- [ android/gradle-wrapper.properties ]
       |      |-- Gradle Version: 8.14 (Supports JDK 17, AGP 8.11)
       |
       |--- [ android/app/build.gradle ]
       |      |-- plugins { application, kotlin-android, flutter }
       |      |-- Compile/Target SDK: 34 (Android 14)
       |      |-- Java Compatibility: 17
       |      |-- Language: Kotlin (Restored)
       |      |-- Namespace: com.kidstube.app
```

## Moving Parts & Current Baseline
1. **Gradle/AGP:** Gradle 8.14 + AGP 8.11.1.
2. **Built-in Kotlin:** Using `id "kotlin-android"` shorthand as per official 3.44 template.
3. **Android Resources:** `AndroidManifest.xml` uses system placeholder icon.
4. **CI/CD:** GitHub Action runners use Node 20 and JDK 17.

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
| `android.builtInKotlin` | `true` | Enables modern Flutter-Kotlin integration. |
| `android.newDsl` | `true` | Required for declarative plugin management. |
| `android.useAndroidX` | `true` | Standard for modern Android development. |

## Strategy for Smooth Builds
1. **Single Source of Truth:** All versioning MUST stay in `settings.gradle`.
2. **Template Alignment:** Strictly follow the discovered Flutter 3.44 structure (includeBuild + declarative plugins).
3. **Explicit Repositories:** Keep `allprojects` in `build.gradle` with the Flutter Maven URL.
