# Architecture

## Tech stack

| Layer | Choice |
|---|---|
| UI | SwiftUI for all three platforms |
| Bridges | AppKit for macOS menu bar (`NSStatusItem`), global hotkey |
| Data | SwiftData with CloudKit mirror |
| Sync | CloudKit private DB + Watch Connectivity (WCSession) |
| Timing precision | `UNUserNotificationCenter` + `BGTaskScheduler` |
| Live Activity | ActivityKit (iOS 16.1+) |
| Complications | WidgetKit (watchOS 10+) |
| Speech | `Speech.framework` (on-device) |
| Global hotkey (macOS) | `KeyboardShortcuts` Swift package by Sindre Sorhus |
| AI | Apple Foundation Models (on-device LLM) |

## Source layout

`TimerKit/` is the shared Swift Package. Every model and service lives
here. The three app targets only contain platform-specific UI and
system integration code.

This split lets a SwiftUI view written for iOS be reused on watchOS
unchanged. The macOS menu bar item is the only piece that can't share.

## SwiftData schema

Five entities. See `Sources/TimerKit/Models/` for the full Swift
definitions.

```
TimerSession
  id, startedAt, duration, state, kind,
  pauseHistory[], initiatedByDeviceID,
  pomodoro?, tag?

PomodoroSession
  id, startedAt, completedAt?, taskTitle?,
  configSnapshot (PomodoroConfig — frozen!),
  rounds[TimerSession], tag?

Memo
  id, createdAt, content, detectedType,
  convertedToTaskID?, capturedContext?, tag?

Tag
  id, name, color, createdAt

DailyStats (pre-aggregated)
  date (start of day), focusMinutes,
  completedPomodoros, pollutedPomodoros,
  memoCount, topTagID?, lastUpdated
```

Why `configSnapshot` is frozen: users will change their pomodoro
config over time (25→50 minutes for deep work). Without a snapshot,
historic statistics would retroactively change as if you'd always used
the new config. Freezing the config at the start of each
PomodoroSession preserves history.

Why `DailyStats` is pre-aggregated: the heatmap renders 365 days. At
~3 sessions/day, naive query scans ~1100 records every chart render.
With `DailyStats`, it's exactly 365 fast lookups. Refresh `DailyStats`
asynchronously when a session ends (~5 ms cost).

## CloudKit container

Container identifier: `iCloud.com.yourbrand.tact`

All five entities sync via SwiftData's CloudKit mirror. Each entity
appears in CloudKit as a record type with the same name.

**Schema is additive only after launch.** Adding optional fields is
safe. Renaming, removing, or retyping is a breaking change that requires
migration logic and risks data loss for existing users. Lock the
schema before submitting to the App Store.

Sync timing on the typical Watch + iPhone + Mac configuration:

| Path | Latency |
|---|---|
| Watch → iPhone (paired, both foreground) | 100–300 ms via WCSession |
| iPhone → Mac (same iCloud account) | 1–3 s typical |
| Worst case (all offline, reconnect) | 5–15 s via CloudKit |

For the typical 25-minute pomodoro use case, even worst-case delays are
imperceptible.

## Three-device live sync

The trick is to **sync intent, not ticks.** A naive design would broadcast
the current displayed time every second. We don't. We sync only:

- `startedAt` (UTC absolute timestamp)
- `duration`
- `state` (running/paused)
- `pauseHistory`

Each device computes its own displayed time locally from this metadata.
NTP-synced device clocks keep three-device displays within ~100 ms of
each other — invisible to the user.

When a Watch starts a session:

1. Watch writes the `TimerSession` to its local SwiftData
2. WCSession pushes the record to iPhone (~200 ms)
3. iPhone writes to its local store, kicks off CloudKit upload
4. Mac receives CloudKit silent push (~1–3 s)
5. Each device fires its own local `UNNotificationRequest` to ring at
   the session end

## Notification deduplication

The hard problem: at session end, all three devices ring at once.

Solution: each device pre-schedules a local notification with
identifier = `session.id` when the session starts. When any device
fires the notification and the user interacts with it (or the
`state = completed` record propagates via CloudKit), the other devices
call `removePendingNotificationRequests(withIdentifiers: [session.id])`.

Worst case: a few hundred milliseconds of overlap before dedup. The
user feels "all three buzzed at once" and dismisses on one device.

## Conflict resolution

CloudKit defaults to last-write-wins by modification date. For
TimerSession, this is fine — user intent is monotonic ("I paused" or
"I cancelled" is the last word). Don't introduce CRDT or
operational-transform complexity unless v2 reveals concrete cases
where LWW is wrong.

## Live Activity / Dynamic Island

iOS-only. ActivityKit must be started locally on the iPhone — you
can't start a Live Activity from the Watch. When a session begins
on the Watch, the iPhone's CloudKit subscription handler triggers a
local `Activity.request()` 1–3 s later. This delay is acceptable
because Live Activity is "glance later" UX, not real-time.

## Offline-first behavior

SwiftData's local store is the source of truth at the moment of any
user action. CloudKit sync is best-effort. If the user starts a Watch
session in airplane mode:

1. The session writes locally
2. Marked as pending sync
3. WCSession queue holds it
4. On next connectivity, queue drains in seconds

This is built into SwiftData + CloudKit; no custom queue logic needed.
