# Xcode Project Setup for WhyApp

## Prerequisites
- Xcode 15+
- iOS 17+ deployment target
- An Apple Developer account (Screen Time API requires a provisioning profile)

---

## Option A: XcodeGen (Recommended)

This repo includes a `project.yml` for [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
# Install XcodeGen (once)
brew install xcodegen

# From the repo root, generate the .xcodeproj
xcodegen generate

# Open in Xcode
open WhyApp.xcodeproj
```

Then follow Steps 2–3 below (App Group + Family Controls capabilities) and set
your Team ID in `project.yml` under `DEVELOPMENT_TEAM`.

---

## Option B: Manual Setup

### Step 1: Create the Xcode Project

1. File → New → Project → iOS → App
2. Product Name: **WhyApp**
3. Interface: **SwiftUI**
4. Language: **Swift**
5. Replace the generated files with the files from `App/`

### Step 2: Add App Group Capability

1. Select the WhyApp target → Signing & Capabilities
2. Click **+ Capability** → **App Groups**
3. Add group: `group.com.whynot.shared`

### Step 3: Add Family Controls Capability

1. Same target → **+ Capability** → **Family Controls**
2. You may need to request the Family Controls entitlement from Apple:
   https://developer.apple.com/contact/request/family-controls-distribution

### Step 4: Add the Shield Configuration Extension

1. File → New → Target → **Shield Configuration Extension**
2. Name: **WhyNotShieldConfiguration**

   > **Important:** Do NOT name it `ShieldConfiguration`. Apple's
   > `ManagedSettingsUI` framework exports a type called `ShieldConfiguration`,
   > so a target with that exact name creates a Swift module-name conflict that
   > prevents `ShieldConfigurationExtension` from being found at compile time.

3. Add to the project, activate the scheme when prompted
4. Replace the generated file with `ShieldConfiguration/WhyNotShieldConfiguration.swift`
5. Add **App Groups** capability with the same group: `group.com.whynot.shared`
6. Add `Shared/` folder files to this target's membership

### Step 5: Add the Shield Action Extension

1. File → New → Target → **Shield Action Extension**
2. Name: **WhyNotShieldAction**

   > **Important:** Do NOT name it `ShieldAction`. Apple's `ManagedSettings`
   > framework exports an enum called `ShieldAction`, so a target with that
   > exact name creates a Swift module-name conflict that prevents
   > `ShieldActionExtension` from being found at compile time, producing errors
   > like *"Cannot find type 'ShieldActionExtension' in scope"* and
   > *"Method does not override any method from its superclass"*.

3. Add to the project, activate the scheme when prompted
4. Replace the generated file with `ShieldAction/WhyNotShieldAction.swift`
5. Add **App Groups** capability with the same group: `group.com.whynot.shared`
6. Add `Shared/` folder files to this target's membership

### Step 6: Configure Target Membership

The files in `Shared/` must be included in ALL three targets:
- WhyApp (main app)
- WhyNotShieldConfiguration (extension)
- WhyNotShieldAction (extension)

Select each file in `Shared/` → File Inspector → check all three targets.

### Step 7: Build & Run

1. Select a physical device (Screen Time APIs do not work in the Simulator)
2. Build and Run (Cmd+R)
3. The app will request Screen Time authorization on first launch

---

## Troubleshooting

### "Cannot find type 'ShieldActionExtension' in scope"
Your extension target is named `ShieldAction`, which conflicts with the
`ShieldAction` enum in `ManagedSettings`. Rename the target to
`WhyNotShieldAction` (or any name that doesn't collide with a ManagedSettings
type). If you used XcodeGen, run `xcodegen generate` to regenerate the project.

### "Cannot find type 'ShieldConfigurationExtension' in scope"
Same issue — your target is named `ShieldConfiguration`. Rename it to
`WhyNotShieldConfiguration`.

---

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
│  WhyNotShieldConfiguration │ WhyNotShieldAction  │
│  (shows "why not" on       │ (handles button     │
│   the block screen)        │  taps on the block  │
│                            │  screen)            │
└─────────────────────────────────────────────────┘
```
