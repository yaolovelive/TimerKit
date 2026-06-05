# Tact

A calm, multi-platform focus tool for macOS, iPadOS, iOS, and watchOS.
Timer + Pomodoro + Quick capture, with on-device AI weekly reflections.

> **Working name.** Trademark, App Store name, and domain registration
> still pending. See `docs/00-overview.md` for the naming validation
> checklist.

---

## Project structure

```
Tact/
├── Package.swift           Swift Package defining TimerKit
├── Sources/
│   └── TimerKit/           Shared business logic, all platforms
│       ├── Models/         SwiftData entities
│       ├── Engine/         Timer + Pomodoro state machines
│       ├── Capture/        Quick memo + smart detection
│       ├── Sync/           CloudKit + WCSession coordination
│       ├── AI/             Foundation Models weekly report
│       ├── Sound/          AVAudio engine + haptic patterns
│       └── Tokens/         Design tokens (colors, type, spacing)
├── Tests/
│   └── TimerKitTests/
├── Apps/
│   ├── macOS/              Tact-macOS Xcode target
│   ├── iOS/                Tact-iOS Xcode target (also iPad)
│   └── watchOS/            Tact-watchOS Xcode target
├── Resources/
│   ├── Sounds/             AAC files: chime, bell, white noise
│   └── Assets/             App icons, marketing assets
└── docs/                   All product/design/architecture decisions
```

---

## First-time setup

### 1. Open the package

```bash
cd /Users/alyjiya/XcodeProjects/Tact
open Package.swift
```

Xcode will open the package directly. You can build and run `TimerKit`
tests immediately with `Cmd+U`.

### 2. Create the app targets in Xcode

The Swift package only contains shared logic. The app targets are
generated and managed by Xcode:

1. `File > New > Project > Multiplatform > App`
2. Product Name: `Tact`
3. Organization Identifier: `com.yourbrand` (replace before App Store)
4. Interface: SwiftUI, Language: Swift
5. Save the new `.xcodeproj` inside `Apps/` (next to the existing
   per-platform source folders)
6. Add the TimerKit package as a local dependency:
   `File > Add Package Dependencies > Add Local` → select the repo root
7. Repeat steps 1–6 for watchOS target (`watchOS App` template)
8. Move the placeholder Swift files from `Apps/macOS`, `Apps/iOS`,
   `Apps/watchOS` into the respective Xcode targets

### 3. Capabilities to enable per target

For both iOS and macOS targets:

- App Sandbox (macOS only)
- App Groups: `group.com.yourbrand.tact`
- iCloud with CloudKit
- CloudKit Containers: `iCloud.com.yourbrand.tact`
- Background Modes: Background fetch, Remote notifications
- Push Notifications
- User Notifications

For the watchOS target:

- App Groups: `group.com.yourbrand.tact` (same as iOS)
- Background Modes: Self Care, Workout Processing (only if used)

### 4. Privacy manifest

Add `PrivacyInfo.xcprivacy` to each app target with required-reason
declarations for `UserDefaults` (`CA92.1`) and file timestamps
(`C617.1`). See `docs/08-privacy.md`.

---

## Where the planning lives

All product, design, and architecture decisions are in `docs/`. When
working with Claude Code or another AI assistant, point it at the
relevant doc rather than re-explaining context:

| Topic | File |
|---|---|
| Project pitch and goals | `docs/00-overview.md` |
| Design system and brand | `docs/01-design.md` |
| Data model and sync | `docs/02-architecture.md` |
| Timer, pomodoro, capture, stats | `docs/03-features.md` |
| AI weekly report | `docs/04-ai-reports.md` |
| Sound and haptics | `docs/05-sound.md` |
| Onboarding flow | `docs/06-onboarding.md` |
| Pricing and App Store | `docs/07-monetization.md` |
| Privacy and compliance | `docs/08-privacy.md` |
| Phased roadmap | `docs/09-roadmap.md` |

---

## License

This project is private/closed-source for now. Decision on partial
open-sourcing (likely the TimerKit core) is deferred to post-launch.
See `docs/00-overview.md` for context.
