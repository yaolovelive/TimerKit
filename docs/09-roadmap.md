# Roadmap

Phases assume a single developer working full-time. Two developers
compress to ~10–12 weeks.

| Phase | Duration | Deliverable |
|---|---|---|
| P0 — Foundation | 1.5 weeks | TimerKit package, SwiftData schema, CloudKit container, Xcode Cloud CI |
| P0.5 — Data layer | 1 week | UserDefaults → SwiftData migration, schema lockdown, CloudKit container provisioned |
| P1 — macOS app | 2 weeks | Menu bar, global hotkey, full pomodoro module, quick capture panel |
| P2 — iOS app | 2 weeks | Main app, Lock Screen widget, Live Activity |
| P3 — watchOS app | 1.5 weeks | Independent watch app, complications, voice memo capture |
| P4 — Sync polish | 1.5 weeks | CloudKit three-device coordination, conflict resolution, notification dedup |
| P5 — Statistics and polish | 2 weeks | Stats views, animations, localization (中/英/日) |
| P6 — Beta and submission | 2 weeks | TestFlight, App Store submission, Mac App Store + iOS App Store launch |
| **Total** | **~13.5 weeks** | v1.0 launched |

## Phase details

### P0 — Foundation

- Initialize Swift package
- Define `@Model` types
- Define `CloudKitContainer.swift`
- Set up Xcode Cloud (or GitHub Actions) for CI
- SwiftLint config
- Repository structure as documented in this folder

### P0.5 — Data layer

- All SwiftData models tested
- CloudKit schema deployed to development environment
- Decision lock: nothing about the schema can change after this phase
  without a versioned migration plan

### P1 — macOS

- SwiftUI main window with state-driven background
- `TimerEngine` integration
- `PomodoroScheduler` integration
- Menu bar item with countdown
- Global hotkey for capture (`KeyboardShortcuts` package)
- Capture panel with `CaptureDetector`
- Local notifications via `UNUserNotificationCenter`

### P2 — iOS

- Reuse SwiftUI views from macOS where possible
- Lock Screen / Home Screen widgets
- Live Activity for Dynamic Island
- Control Center widget
- Action Button binding (iPhone 15+)

### P3 — watchOS

- Independent Watch App
- Complications on all major watch faces
- Crown adjustment for duration
- Speech.framework for voice memos
- WCSession for iPhone pairing
- Custom haptic patterns

### P4 — Sync polish

- WCSession message routing
- CloudKit subscription handlers
- Last-write-wins conflict tests
- Notification dedup logic
- Edge case testing: airplane mode, weak signal, mid-session reboot

### P5 — Statistics and polish

- Heatmap (365 days)
- Week comparison chart
- Hour distribution radial
- Tag distribution donut
- State transition animations
- Localization: English, Simplified Chinese, Japanese (Tokyo market)
- Accessibility audit

### P6 — Beta and submission

- TestFlight beta (50-100 testers minimum)
- App Store screenshots and metadata
- Privacy questionnaire
- First submission ~14 days before launch
- Plan for one rejection cycle

## What is NOT in v1

Listed here to resist scope creep:

- Apple Vision Pro adaptation
- AI cloud features (only on-device for v1)
- Third-party integrations (Notion, Todoist, Things)
- Team/collaboration features
- Web clipper extension for memo
- Themes marketplace
- Multipeer Connectivity fast lane (v2 enhancement)
- Monthly retrospective AI reports (v1.1)

## v1.1 — first 30 days post-launch

Reactive improvements based on user feedback:

- Bug fixes from real-world usage
- Top-requested features (likely: more theme colors, more sounds)
- Monthly AI retrospective

## v2 candidates

- Multipeer Connectivity fast sync lane
- Optional cloud-augmented AI (Claude API, opt-in)
- Apple Vision Pro app
- AppleScript / Shortcuts support for power users
- Open-source TimerKit
