# Xcode Project Setup for WhyApp

## Prerequisites
- Xcode 15+
- iOS 17+ deployment target
- An Apple Developer account (Screen Time API requires a provisioning profile)

## Step 1: Create the Xcode Project

1. File → New → Project → iOS → App
2. Product Name: **WhyApp**
3. Interface: **SwiftUI**
4. Language: **Swift**
5. Replace the generated files with the files from `App/`

## Step 2: Add App Group Capability

1. Select the WhyApp target → Signing & Capabilities
2. Click **+ Capability** → **App Groups**
3. Add group: `group.com.whynot.shared`

## Step 3: Add Family Controls Capability

1. Same target → **+ Capability** → **Family Controls**
2. You may need to request the Family Controls entitlement from Apple:
   https://developer.apple.com/contact/request/family-controls-distribution

## Step 4: Add the Shield Configuration Extension

1. File → New → Target → **Shield Configuration Extension**
2. Name: **ShieldConfiguration**
3. Add to the project, activate the scheme when prompted
4. Replace the generated file with `ShieldConfiguration/WhyNotShieldConfiguration.swift`
5. Add **App Groups** capability with the same group: `group.com.whynot.shared`
6. Add `Shared/` folder files to this target's membership

## Step 5: Add the Shield Action Extension

1. File → New → Target → **Shield Action Extension**
2. Name: **ShieldAction**
3. Add to the project, activate the scheme when prompted
4. Replace the generated file with `ShieldAction/WhyNotShieldAction.swift`
5. Add **App Groups** capability with the same group: `group.com.whynot.shared`
6. Add `Shared/` folder files to this target's membership

## Step 6: Configure Target Membership

The files in `Shared/` must be included in ALL three targets:
- WhyApp (main app)
- ShieldConfiguration (extension)
- ShieldAction (extension)

Select each file in `Shared/` → File Inspector → check all three targets.

## Step 7: Build & Run

1. Select a physical device (Screen Time APIs do not work in the Simulator)
2. Build and Run (Cmd+R)
3. The app will request Screen Time authorization on first launch

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                   WhyApp (main)                  │
│  - Onboarding (FamilyActivityPicker)             │
│  - Home (manage blocked items)                   │
│  - Log (view access attempts)                    │
│  - PendingReasonView (forced "why yes" prompt)   │
│  - ScreenTimeManager (auth + shield management)  │
├─────────────────────────────────────────────────┤
│              Shared (App Group)                   │
│  - SharedDataStore (UserDefaults suite)           │
│  - BlockedItem, AccessAttempt, PendingReason     │
├─────────────────────────────────────────────────┤
│  ShieldConfiguration     │  ShieldAction          │
│  (shows "why not" on     │  (handles button taps  │
│   the block screen)      │   on the block screen) │
└─────────────────────────────────────────────────┘
```
