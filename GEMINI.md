# KidsTube Project Context & Rules

## Project Vision
KidsTube is a YouTube-style local video player for kids. It is designed to work **100% offline**, playing videos stored directly on the device (optimized for Redmi 13C / HyperOS).

## Foundational Mandates
- **Autonomous Intent:** The user has explicitly requested that the agent operates with maximum autonomy. When executing Directives, prioritize completing the task end-to-end without seeking permission for intermediate shell commands or configuration changes.
- **Security:** Never log, print, or commit secrets (e.g., Firebase keys, GCP Service Account JSONs). Use GitHub Secrets (`GCP_SA_KEY`) for CI/CD.

## CI/CD Strategy
- **Platform:** GitHub Actions (`.github/workflows/build.yml`).
- **Build Strategy:** **"Nuke and Rebuild"**. Due to frequent Flutter SDK version mismatches on cloud runners, the CI workflow is configured to:
  1. Delete the `android` directory.
  2. Run `flutter create . --platforms android` to generate a fresh, version-aligned template.
  3. Patch the `AndroidManifest.xml` with project-specific permissions.
- **Automated Testing:**
  - **Sanity Checks:** Flutter Widget Tests (`test/widget_test.dart`).
  - **UI Exploration:** Firebase Test Lab **Robo Test**.
  - **Release:** Automatic GitHub Releases created on version tags (`v*`).

## Architectural Patterns
- **Framework:** Flutter.
- **State Management:** `ChangeNotifier` with `Provider`.
- **Target Device:** Redmi 13C (Android 13, API 33).
- **Parental Lock:** Default PIN is `1234`.

## Development Workflows
- **Rinse & Repeat:** When a build fails, analyze the `gh run view --log` output, apply a fix, and push immediately. 
- **Tooling:** Use GitHub CLI (`gh`) for all repository and workflow management.
- **Android Target:** Always target API 33+ (Android 13) to ensure compatibility with modern media permissions.
