# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

Tact is a multi-platform focus tool (macOS, iOS, iPadOS, watchOS) combining timer, Pomodoro, and quick capture with on-device AI weekly reflections. Working name — trademark/App Store name still TBD.

## Build and test

```bash
# Open in Xcode (builds all targets)
open Package.swift

# Run all tests (CLI)
swift test

# Run a single test
swift test --filter TimerEngineTests/testPauseResume
```

The Swift package (`TimerKit`) is the only thing buildable from the command line. The three app targets require Xcode with the `.xcodeproj` file (not yet committed — see README for setup steps).

## Architecture

### Package layout

`TimerKit` (`Sources/TimerKit/`) is a pure Swift Package containing **all** business logic shared across the three platforms. The app targets (`Apps/macOS`, `Apps/iOS`, `Apps/watchOS`) contain only SwiftUI views and platform-specific system integration (menu bar, WCSession, WidgetKit, etc.).

```
TimerKit/
├── Models/       SwiftData entities (TimerSession, PomodoroSession, Memo, Tag, DailyStats)
├── Engine/       TimerEngine (@Observable), PomodoroScheduler
├── Capture/      CaptureDetector (NSDataDetector + regex), MemoStore
├── Sync/         CloudKitContainer, DeviceIdentity
├── AI/           WeeklyReportGenerator (Apple Foundation Models, on-device)
├── Sound/        SoundLibrary (AVAudioEngine), HapticPattern
└── Tokens/       DesignTokens, StateColor (design system constants)
```

### Key design decisions

**Sync intent, not ticks.** `TimerSession` stores `startedAt` (UTC) + `duration` + `pauseHistory`. Each device computes displayed time locally from this metadata. Never broadcast the displayed countdown value.

**`configSnapshot` is frozen.** `PomodoroSession` captures `PomodoroConfig` at session start. Changing the user's global default must not rewrite historical statistics.

**`DailyStats` is pre-aggregated.** The heatmap queries exactly 365 rows, not ~1100 raw sessions. Refresh `DailyStats` asynchronously after each session ends.

**CloudKit schema is additive only after launch.** Adding optional fields is safe. Renaming, removing, or retyping a field requires migration logic and risks data loss. Lock the schema before App Store submission.

**`TimerEngine` does not poll for display.** It publishes state-change events. The View layer owns a 1 s `Timer.publish` loop scoped to its lifecycle and calls `session.remaining(at: now)` on each tick.

### Notification deduplication

All three devices pre-schedule a `UNNotificationRequest` with `id = session.id` at session start. When any device completes the session, the others call `removePendingNotificationRequests(withIdentifiers: [session.id])`.

### State → background color mapping

| State | Tint |
|---|---|
| Idle | Warm neutral gray |
| Focus | Cool teal-green |
| Short break | Warm amber |
| Long break | Deeper green |
| Capture | Violet |

Background transitions are 0.4 s `smooth`. Never use bounce animations.

## Design constraints

- SF Pro Rounded Semibold with monospaced digits for the time numeral (48 pt watchOS → 160 pt macOS)
- 4 pt spacing baseline; steps: 4/8/12/16/24/32/48
- Liquid Glass blur (30–50 pt) on macOS/iOS surfaces; solid color tints on watchOS
- SF Symbols only — no custom illustrations except the app icon
- Continuous curvature (squircle) corners everywhere

## Docs index

All product/architecture decisions live in `docs/`. Reference these rather than re-explaining context:

| Topic | File |
|---|---|
| Project pitch & goals | `docs/00-overview.md` |
| Design system | `docs/01-design.md` |
| Data model & sync | `docs/02-architecture.md` |
| Timer, Pomodoro, capture, stats | `docs/03-features.md` |
| AI weekly report | `docs/04-ai-reports.md` |
| Sound & haptics | `docs/05-sound.md` |
| Onboarding flow | `docs/06-onboarding.md` |
| Pricing & App Store | `docs/07-monetization.md` |
| Privacy & compliance | `docs/08-privacy.md` |
| Phased roadmap | `docs/09-roadmap.md` |

## Platform targets

| Target | Min OS | Notes |
|---|---|---|
| Tact-macOS | macOS 15 | `NSStatusItem` menu bar, global hotkey via `KeyboardShortcuts` package |
| Tact-iOS | iOS 18 | Live Activity / Dynamic Island, Lock Screen widget |
| Tact-watchOS | watchOS 11 | WidgetKit complications, WCSession relay to iPhone |

App Group: `group.com.yourbrand.tact` · CloudKit container: `iCloud.com.yourbrand.tact`
