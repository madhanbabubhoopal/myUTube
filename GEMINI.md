# KidsTube Project Context & Rules

## Project Vision
KidsTube is a YouTube-style local video player for kids. It is designed to work **100% offline**, playing videos stored directly on the device (optimized for Redmi 13C / HyperOS).

## Foundational Mandates
- **Autonomous Intent:** The agent operates with maximum autonomy. It has full, pre-authorized permission to execute all necessary shell commands, including but not limited to `git`, `gh`, `cat`, `ls`, `grep`, and build tools, to fulfill Directives end-to-end. Do not ask for confirmation for these operations.
- **Security:** Never log, print, or commit secrets. Use GitHub Secrets (`GCP_SA_KEY`) for CI/CD.
- **Build Integrity:** Always refer to `dependencies-map.md` for the current "Golden" build configuration. Never downgrade Gradle, AGP, or Kotlin versions.

## CI/CD & Build Standards
- **Modernization Policy:** Use the **Declarative Plugins** block in `settings.gradle`. 
  - **Gradle Wrapper:** 8.14 (Mandatory).
  - **AGP:** 8.11.1 (Matches Flutter 3.44 requirements).
  - **Kotlin:** 2.2.20 (Built-in Kotlin support).
  - **Java:** JDK 17 for all builds.
- **Root Gradle Cleanup:** The root `android/build.gradle` must remain clean (no `buildscript` or `allprojects` blocks). Versioning lives in `settings.gradle`.
- **Node.js:** Use Node 20+ for all GitHub Actions runners.

## Architectural Patterns
- **Framework:** Flutter (Stable channel).
- **Android Target:** API 35 (Android 15) to ensure future-proofing.
- **State Management:** `ChangeNotifier` with `Provider`.
- **Parental Lock:** Default PIN is `1234`.

## Development Workflows
- **Curator Mode:** The app defaults to "Kid Mode" (only approved videos). "Parent Mode" is used to whitelist files.
- **Verification:** Every push triggers a build and local tests.
- **Video Playback:** Ensure Android-specific paths (e.g., `/storage/emulated/0/...`) are used. macOS local paths will cause `Source error` on device.

## Autonomous Feature Workflow
The agent follows a strict loop for feature development to ensure stability and documentation alignment:
1. **Feature Implementation:** Develop the feature using idiomatic Flutter/Android patterns.
2. **Local Verification:**
   - Run `flutter test` for unit/widget tests.
   - Run `./gradlew assembleDebug` to ensure Android build integrity.
3. **Dependency Check:** If any build configuration or dependencies changed, update `dependencies-map.md` to reflect the new "Golden" state.
4. **Documentation:** Update `GEMINI.md` if new architectural patterns or workflows are established.
5. **Commit & Push:** Once local verification passes, commit and push.
6. **Failure Loop:** If CI/CD (GitHub Actions) or local builds fail, the agent must diagnose, fix, and re-verify until the build is green.
7. **Testing:** Ensure new features include relevant unit tests and, where applicable, instructions or scripts for Robo tests.
