# KidsTube Development Plans 🚀

## Phase 1: The Curator (Current Focus)
- [x] Add `isApproved` flag to `VideoItem` model.
- [x] Build PIN-protected "Manage Approved Videos" UI in Settings.
- [x] Filter Home Screen and Clips to only show approved content.
- [x] Add version indicator (v1.0.0-beta) to landing page.
- [ ] **Next:** Improve the "Empty State" for Kid Mode (show a friendly message if no videos are approved yet).

## Phase 2: YouTube UI Polish
- [ ] **Skeleton Loaders:** Add shimmer effects during thumbnail generation.
- [ ] **Mini-Player:** Implement a swipe-down-to-minimize bar (Picture-in-Picture style).
- [ ] **Rounded Corners:** Update all cards and player elements to match 2024 YouTube aesthetics.
- [ ] **Up Next:** Add a horizontal scroll of related approved videos below the player.

## Phase 3: Parental Controls & Analytics
- [ ] **Kiosk Mode:** Research native Android App Pinning to lock the child into the app.
- [ ] **Offline Analytics:** Log playback events locally (which segments are watched most).
- [ ] **Screen Time Limits:** Add a "Sleep Timer" that locks the app after X minutes.
- [ ] **Session Reports:** Summarize total watch time per day for the parent.

## Phase 4: Intelligence (Genetic/AI)
- [ ] **On-Device Tagging:** Use TFLite to automatically tag videos (e.g., "Cartoons", "Educational").
- [ ] **Smart Loop:** Detect high-frequency playback and offer to "Loop" that specific segment.
