# FitnessApp

This is a SwiftUI iOS fitness tracking app with Coach and User views, Apple Health sync, manual mood/water check-ins, coach notes, alerts, and per-athlete thresholds.

## Requirements
- Xcode 15+ / iOS 16+
- Physical iPhone for HealthKit

## Setup (Required)
1. Open `Package.swift` in Xcode.
2. Select the app target → Signing & Capabilities → add **HealthKit**.
3. In Signing & Capabilities, add **iCloud** (CloudKit) and use the container `iCloud.com.fitnessapp` or change the identifier in `Sources/FitnessApp/Resources/FitnessApp.entitlements`.
4. In Signing & Capabilities, attach the entitlements file `Sources/FitnessApp/Resources/FitnessApp.entitlements` if Xcode does not auto-detect it.
5. Ensure the target uses `Sources/FitnessApp/Resources/Info.plist` and `PrivacyInfo.xcprivacy`.
6. Run on a physical device for Apple Health data access.

## Notes
- Mood is a manual 1–10 check-in stored locally.
- Water can be manually logged if not tracked by a smart bottle.
- Coach notes, tags, and thresholds are stored locally per device.
- Alerts can trigger local notifications after thresholds are violated.
- Export formats include CSV and JSON (shareable from the Coach view).
- CloudKit sync is enabled for users, notes, tags, and thresholds (private database).
- Background app refresh is configured for CloudKit sync.
