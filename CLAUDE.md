# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

Open `maple.xcworkspace` (not `.xcodeproj`) in Xcode — CocoaPods dependencies require the workspace.

```bash
# Install/update pods
pod install

# Clean pod cache and reinstall
bash podcleanup.sh && pod install

# Build from CLI (scheme: Maple)
# ARCHS=x86_64 is required — old FirebaseAnalytics pre-XCFramework binaries have arm64 (device) only,
# no arm64-simulator slice, so arm64 simulator builds fail at link time.
xcodebuild -workspace maple.xcworkspace -scheme Maple \
  -destination 'generic/platform=iOS Simulator' \
  ARCHS=x86_64 build

# Run tests
xcodebuild -workspace maple.xcworkspace -scheme Maple \
  -destination 'generic/platform=iOS Simulator' \
  ARCHS=x86_64 test
```

The deployment target is iOS 15.0 (enforced via `post_install` in the Podfile).

## Architecture

Maple is an iOS social photo-sharing app with location features, built on Firebase/Firestore.

**Entry point:** `AppDelegate.swift` (root) — configures Firebase, Google Maps/Places API keys, FCM push tokens, and installs `MainTabBarController` as the root view controller.

**Navigation:** `main/MainTabBarController.swift` — 5-tab UITabBarController:
1. Home (`HomeController`) — Firestore-backed post feed with pagination
2. Search (`SearchAlgoliaCollectionView`) — Algolia full-text search over posts/users/locations/categories
3. Share (`ShareController`) — photo/map post creation flow
4. Notifications (`NotificationViewController`) — user events/interactions
5. Profile (`UserProfileController`) — current user's grid and follow stats

**Source layout:**
- `main/` — all active source files
  - `AppDelegate.swift`, `MainTabBarController.swift` — app bootstrap
  - `User/` — profile, follow, auth picker views
  - `Search/` — Algolia search UI, map-based location search
  - `Notifications/` — notification list and cells
  - `Share/` — multi-step post creation (photo selection, crop, map tagging, settings)
  - `GoogleMapPicker/` — Google Maps location picker (localized into many languages)
  - `Utilities/` — shared helpers (see below)
- Root-level `*.swift` — older/alternate versions of Home and Post viewer controllers (some may be unused; prefer `main/` equivalents)
- `maple/` — secondary target with `ProductController`/`ProductCell`

**Utilities (`main/Utilities/`):**
- `FirestoreUtilities.swift` — `Firestore` static extensions: `fetchUserWithUID`, `fetchNotifications`, follow graph helpers, `updateUserProfile`
- `FirebaseUtilites.swift` / `FirebaseUtilities+Notifications.swift` — Realtime Database helpers and notification writes
- `Extensions.swift` — `UIView.anchor()` layout helper, `Date.timeAgoToDisplay()`, theme color extensions
- `Helper.swift` — `JJFloatingActionButton` alert helper

**Firestore data model:**
- `users/{uid}/profile/{uid}` — user profile document
- `users/{uid}/following/` — UIDs this user follows
- `users/{uid}/followed/` — UIDs that follow this user
- `users/{uid}/events/` — notification events (badge count source)
- `notification/` — global notification collection (queried by `uid` field)
- `posts/` — post documents (indexed in Algolia: `posts`, `users`, `locations`, `category` indices)

**Search (Algolia):** `main/Search/AlgoliaManager.swift` — singleton with four indices (`posts`, `users`, `locations`, `category`). App ID and API key are hardcoded there.

**Authentication:** FirebaseUI with email, Google Sign-In, and Facebook providers. Custom auth picker: `main/User/FPAuthPickerViewController`.

## Key Dependencies

| Pod | Purpose |
|-----|---------|
| Firebase/Firestore | Primary database |
| FirebaseMessaging | FCM push notifications |
| FirebaseUI | Auth UI + image loading |
| GoogleMaps / GooglePlaces | Map display and place search |
| InstantSearch-Core-Swift | Algolia search integration |
| MaterialComponents | MDC bottom bar, FAB, snackbar, collection views |
| SDWebImage | Async image loading/caching |
| Gallery / ImagePicker / CropViewController | Photo selection and editing |
| Alamofire | HTTP networking |
| ActiveLabel | Tappable hashtags/mentions in post captions |
| JJFloatingActionButton | Floating action button |
