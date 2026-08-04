# Schema Lock — v1.0 Development

**Lock Date**: 2026-07-30  
**Container**: `iCloud.com.a1itx.tact` (Development)  
**Environment**: CloudKit Development (test environment before App Store submission)  
**Locked By**: CloudKit Development schema deployment and validation

---

## Why Schema Lock Matters

After this date, any schema change (field rename, type change, field removal) requires a formal **SwiftData `VersionedSchema` + `SchemaMigrationPlan`** to safely migrate existing user data. New **optional** fields can be added without migration, but are still logged here for tracking.

See CLAUDE.md, "Design constraints" section for additive-only CloudKit rules.

---

## Current Schema (Locked Snapshot)

### 1. TimerSession
Atomic unit of timing. Every standalone timer and every pomodoro segment is one `TimerSession`.

| Field | Type | Optional | Notes |
|---|---|---|---|
| `id` | UUID | No | Primary key, auto-generated |
| `startedAt` | Date | No | UTC timestamp, single source of truth for cross-device |
| `duration` | TimeInterval | No | Planned duration in seconds |
| `state` | SessionState | No | One of: running, paused, completed, cancelled |
| `kind` | SessionKind | No | One of: standalone, pomodoroWork, pomodoroShortBreak, pomodoroLongBreak |
| `pauseHistory` | [PauseRecord] | No | Pause/resume records; sum subtracted from elapsed time |
| `initiatedByDeviceID` | String | No | Device ID that started this session (for sync origin tracking) |
| `pomodoro` | PomodoroSession? | Yes | Relationship: parent pomodoro (if this is a segment) |
| `tag` | Tag? | Yes | Relationship: optional categorization tag |

**Key Design Decision**: `startedAt` + `duration` + `pauseHistory` is the sync surface. Never broadcast displayed countdown value; compute locally on each device.

---

### 2. PomodoroSession
A pomodoro sequence (work + breaks) bound to an optional task.

| Field | Type | Optional | Notes |
|---|---|---|---|
| `id` | UUID | No | Primary key |
| `startedAt` | Date | No | Session creation time |
| `completedAt` | Date? | Yes | When this pomodoro sequence ended |
| `taskTitle` | String? | Yes | Optional task label, e.g. "Writing dev spec" |
| `configSnapshot` | PomodoroConfig | No | **Frozen at start time**; changing user prefs later does not retroactively rewrite historical stats |
| `rounds` | [TimerSession]? | Yes | Relationship: child segments (work/break sessions), cascading delete |
| `tag` | Tag? | Yes | Relationship: optional categorization |

**PomodoroConfig structure** (nested Codable):
```swift
{
  workDuration: TimeInterval,
  shortBreakDuration: TimeInterval,
  longBreakDuration: TimeInterval,
  roundsBeforeLongBreak: Int,
  autoStartNextSegment: Bool
}
```

**Key Design Decision**: `configSnapshot` is read-only after creation. Protects historical accuracy from user preference changes.

---

### 3. Memo
User-captured note, optionally tagged and linked to a pomodoro session.

| Field | Type | Optional | Notes |
|---|---|---|---|
| `id` | UUID | No | Primary key |
| `createdAt` | Date | No | Capture timestamp |
| `content` | String | No | The memo text |
| `detectedType` | MemoType | No | Enum: plain, reminder, todo, url, contact, question, reflection |
| `archived` | Bool | No | Soft-archived from Inbox; captured data is preserved |
| `convertedToTaskID` | UUID? | Yes | If converted to system reminder via EventKit |
| `capturedContext` | CapturedContext? | Yes | Frozen snapshot: pomodoroID, taskTitle, tagName, timeIntoSession |
| `tag` | Tag? | Yes | Relationship: optional categorization |

**MemoType enum values**: `plain`, `reminder`, `todo`, `url`, `contact`, `question`, `reflection`

**CapturedContext structure** (nested Codable):
```swift
{
  pomodoroID: UUID?,
  taskTitle: String?,
  tagName: String?,
  timeIntoSession: TimeInterval?
}
```

**Key Design Decision**: `capturedContext` is frozen at capture time. Protects memo's historical context from later preference/tag changes.

---

### 4. Tag
Categorization label, with inverse relationships to TimerSession, Memo, and PomodoroSession.

| Field | Type | Optional | Notes |
|---|---|---|---|
| `id` | UUID | No | Primary key |
| `name` | String | No | Tag name |
| `color` | TagColor | No | Enum: slate, sky, teal, sage, amber, coral, plum, blush |
| `createdAt` | Date | No | Creation timestamp |
| `timerSessions` | [TimerSession]? | Yes | Inverse relationship: all TimerSessions tagged with this |
| `memos` | [Memo]? | Yes | Inverse relationship: all Memos tagged with this |
| `pomodoroSessions` | [PomodoroSession]? | Yes | Inverse relationship: all Pomodoros tagged with this |

**TagColor enum values**: `slate`, `sky`, `teal`, `sage`, `amber`, `coral`, `plum`, `blush`

**Key Design Decision**: Inverse relationships maintained for CloudKit compatibility. Deletion of a Tag does not cascade; orphaned references remain but become null pointers (to preserve memo/session history).

---

### 5. DailyStats
Pre-aggregated per-day statistics. Queried by heatmap/stats views to avoid scanning raw sessions.

| Field | Type | Optional | Notes |
|---|---|---|---|
| `date` | Date | No | Start-of-day, normalized to UTC midnight of that local day |
| `focusMinutes` | Int | No | Total focused time in minutes, summed across completed sessions |
| `completedPomodoros` | Int | No | Count of completed pomodoro work rounds |
| `pollutedPomodoros` | Int | No | Count of interrupted pomodoro work rounds |
| `memoCount` | Int | No | Count of memos captured during this day |
| `topTagID` | UUID? | Yes | Most-used tag ID (if any) |
| `lastUpdated` | Date | No | Last time this row was recomputed |

**Key Design Decision**: Asynchronously refreshed after each session ends. Read-path only for statistics UI (no direct user mutation).

---

## Related Value Types (Not Entities)

These are nested Codable structures, **not** SwiftData entities, so they don't have their own CloudKit records.

### SessionState (Enum)
```swift
enum SessionState {
    case running
    case paused
    case completed
    case cancelled
}
```

### SessionKind (Enum)
```swift
enum SessionKind {
    case standalone
    case pomodoroWork
    case pomodoroShortBreak
    case pomodoroLongBreak
}
```

### PauseRecord (Struct)
```swift
struct PauseRecord {
    let pausedAt: Date
    var resumedAt: Date?
    var duration: TimeInterval { /* computed */ }
}
```

---

## Sync & Cross-Device Rules

1. **Single Source of Truth**: `TimerSession.startedAt` + `duration` + `pauseHistory`; displayed time is computed locally.
2. **Notification Deduplication**: All devices pre-schedule a `UNNotificationRequest` at session start (id = session.id). When any device completes, it calls `removePendingNotificationRequests(withIdentifiers:)` on other devices (implementation: P4 phase). Local stop/pause also cancels pending notification (implementation: P0.5 bugfix).
3. **Device Origin Tracking**: `TimerSession.initiatedByDeviceID` marks which device started this session; used for sync diagnostics.
4. **Relationship Cascade**: `PomodoroSession.rounds` has `deleteRule: .cascade` — deleting a pomodoro deletes all its child segments.

---

## Migration Path: Future Schema Changes

### For Optional Field Additions (Additive Only)
1. Add field with `?` optional annotation in `@Model`
2. Set sensible default in `init` or via `@Attribute(...)` macro
3. No `SchemaMigrationPlan` required (CloudKit allows additive-only changes)
4. Update this document with new field

### For Breaking Changes (Rename, Remove, Retype, Make Non-Optional)
1. Create a new `VersionedSchema` in `Sources/TimerKit/Sync/` with old + new fields
2. Write a `SchemaMigrationPlan` that maps old → new schema
3. Bump `CloudKitContainer` to check `modelContext.schemaVersion` and apply migration
4. Test thoroughly in Development environment before production
5. Document the migration in a new section below

Currently, **zero breaking changes have occurred**. This section will expand as v1.1, v2.0, etc. are planned.

---

## Verification & Auditing

- **Schema exported**: 2026-07-30 from CloudKit Dashboard (Development environment)
- **Deployment verified**: macOS app ran with `TACT_USE_CLOUDKIT=1`, confirmed `TimerSession` record created in CloudKit
- **Entitlements validated**: `iCloud.com.a1itx.tact` in all three app targets (macOS, iOS, watchOS)
- **APS environment**: `development` (pre-production)

### To Re-Verify Later
```bash
# In Xcode, set environment variable
TACT_USE_CLOUDKIT=1

# Run app, create a timer, observe CloudKit Dashboard → Container: iCloud.com.a1itx.tact → Records
# Should see TimerSession record appear within seconds
```

---

## Next Phase

After v1.0 App Store launch, if a schema change is needed:
1. File an issue or ADR in `docs/` with breaking change rationale
2. Implement `VersionedSchema` + `SchemaMigrationPlan` per SwiftData docs
3. Add a new "Migration: v1.0 → v1.1" section below
4. Test against production CloudKit container before pushing to users

**Until then, schema is frozen. No changes without formal versioning.**
