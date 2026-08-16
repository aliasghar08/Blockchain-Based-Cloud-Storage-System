# Implementation Tasks

- [x] Set up dependency injection with `provider` package in `pubspec.yaml`.
- [x] Add system permission handlers for storage and notifications.
- [x] Implement robust `NotificationService` for cross-platform local push notifications.
- [x] Configure native Android/iOS properties (`AndroidManifest.xml`, `Info.plist`) for app permissions.
- [x] Create core abstraction layers: `Constants`, `Theme`, `ABI`.
- [x] Architect clean Data Model `FileModel` and UI state logic.
- [x] Refactor `BlockchainService` and `PinataService` to dynamically accept credentials at runtime.
- [x] Build `WalletProvider` for centralized key management and authentication with `flutter_secure_storage`.
- [x] Develop a beautiful, professional `LoginScreen` allowing Ethereum Key submission.
- [x] Develop a `DashboardScreen` integrating IPFS, Blockchain, file lists, sharing, and notifications.
- [x] Wire up the `main.dart` root to route between Authentication and Dashboard flows.
- [x] Cleanly analyze and fix code quality, migrating packages like `file_picker` to their latest v12 APIs and `web3dart` to stable v2.7.2.
- [x] Implement widget tests for the new Provider-based app structure.
