# Feature specifications

## Timer (basic)

Inherited from the original timer-app concept, retained:

- Multiple concurrent timers (`⌘N` opens another)
- Each timer can be named/tagged
- Sound on completion (Chime/Bell/Silent — see `docs/05-sound.md`)
- Cross-platform sync (see `docs/02-architecture.md`)

New on top of master:

- Menu bar item on macOS (`NSStatusItem`) showing the shortest remaining
  timer's countdown
- Dock badge with remaining time when a timer is active
- Lock Screen widget and Control Center widget on iOS
- watchOS Complication on every standard face

## Pomodoro

### Default configuration

- Work: 25 min
- Short break: 5 min
- Long break: 15 min (after 4 work segments)
- Auto-start next segment: ON

All configurable per-session at start. Configuration is **frozen** into
`PomodoroSession.configSnapshot` so changing the global default doesn't
retroactively rewrite history.

### Session flow

```
W → SB → W → SB → W → SB → W → LB → (cycle restarts)
```

`PomodoroScheduler.segmentDidComplete(deviceID:)` advances the index
and decides what kind of segment is next.

### Pollution vs cancellation

If a work segment is interrupted (user taps Stop, doesn't let it run
out), it's marked `.cancelled` and counts toward `pollutedPomodoros`
in `DailyStats`. This is honest data — used in statistics, not for
guilt-tripping the user.

### Task binding

Optional. User can type a task title at session start
("Writing dev spec"). This title flows into `capturedContext` on any
memos created during the session, enabling the killer "during which
pomodoro was this captured" lookup.

### Focus mode integration

macOS: when a work segment starts, optionally enable a Focus Filter
(System Settings → Focus). User opts in once during onboarding.
iOS: same, via `INFocusStatusCenter` and Focus Filter API.

## Quick capture

The thought-capture system. See dedicated logic in
`TimerKit/Capture/`. Headline behavior:

1. User presses global hotkey (`⌥ Space` default on macOS)
2. Capture panel appears within ~80 ms, already focused
3. User types
4. `CaptureDetector` runs per-keystroke (debounced 300 ms) and shows
   chips below the input: Reminder, time, todo, tag, etc.
5. Return saves with auto-applied detections; Escape discards
6. Panel dismisses; user returns to whatever they were doing

### Smart detection

All local via `NSDataDetector` and lightweight regex. No network,
no ML inference.

Detected types: URL, date/time, phone, email, todo (line starting
`- ` or `todo:`), hashtag (`#word`), question (ending `?`).

### Context awareness — the differentiator

When the user invokes capture, `MemoStore.save` reads
`TimerEngine.activeSession` and `PomodoroScheduler.currentPomodoro`
and stamps the memo with `CapturedContext`:

- Pomodoro ID
- Task title
- Tag name
- Time into session

In the inbox, users can filter memos by pomodoro session. "What did I
capture during that Tuesday morning marketing pomodoro?" — answerable
in one tap.

### Inbox

Chronological stream, newest first. Three smart groups: Reminders,
Links, Questions. Swipe actions: archive, convert to system reminder,
attach to current pomodoro, delete.

Auto-archive: untouched memos older than 30 days move out of the
visible inbox to keep things tidy. Soft delete via `archived: Bool`
flag, never actual deletion.

### Don'ts

- No folders or notebooks (tags only)
- No rich text or Markdown rendering during capture
- No backlinks or wiki-style references
- No collaboration
- No web clipper extension (deferred to v2)

## Statistics

Four views: Today / Week / Month / All-time.

| Metric | Computation |
|---|---|
| Focus minutes | Sum `completed` work `TimerSession.duration` |
| Completed pomodoros | Count `PomodoroSession.completedAt != nil` |
| Pollution rate | `cancelled / started` for work segments |
| Best hour | Most frequent `startedAt` hour bucket |
| Streak | Longest consecutive days with ≥ 1 completed pomodoro |
| Top tags | `groupBy(tag).sum(duration)` |

### Visualizations

- **Heatmap** — GitHub-style 365-day grid, color depth = focus minutes
- **Week comparison** — 7-day bars with last week as gray overlay
- **Hour distribution** — 24-hour radial chart
- **Tag share** — donut chart with top 5 list

### watchOS

Just one card on watchOS: today's focus minutes, today's pomodoro
count, current streak. Tapping it opens an expanded view but no
interactive charts (the screen is too small to be useful).
