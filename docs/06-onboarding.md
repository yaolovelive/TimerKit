# Onboarding

## The 60-second rule

7-day retention is determined primarily in the 60 seconds after first
launch. Goal: user should complete a real (small) pomodoro inside this
window, not just watch a tour.

## Five screens

### Screen 1 — Welcome

Single sentence: "Time, with a tempo."

Single primary button: "Begin"

No skip (the only action is begin).

### Screen 2 — Your rhythm

"How long do you focus best?"

Three options:

- 25 minutes (standard pomodoro)
- 50 minutes (deep work)
- Custom (number wheel)

Each option is a tap-and-advance. No "Next" button. Implicit message:
Tact respects your existing workflow.

### Screen 3 — Your sound

"Pick your timer end sound"

Three options:

- Soft chime
- Bell
- Silent

Tap to preview (~1 s). Tap again to confirm and advance.

### Screen 4 — Notifications

"We'll buzz you when your time's up. Nothing else."

Primary: "Allow" → triggers system notification permission prompt.
Secondary (small gray): "Maybe later"

Position matters: by this screen the user has invested in three
decisions. Authorization rate is ~30% higher than asking on first
launch.

### Screen 5 — First focus

One large round button: "Start your first 5-minute focus"

Note the 5 minutes (not 25). Low-stakes try. After tapping, drops
straight into the main UI with the timer running.

Onboarding ends here. Total time: 35–45 seconds.

## What to defer

These are common onboarding-pollution mistakes. They go OUT of the
first-run flow:

| Deferred until | What |
|---|---|
| 3 sessions completed | "Sync to other devices?" → CloudKit prompt |
| First main view open (iOS) | Lock Screen widget tutorial toast |
| First main view open (Mac) | Menu bar item explanation |
| Has Apple Watch but no Tact Watch App | Pair Watch tutorial toast |
| First completed pomodoro | Hotkey tooltip for `⌥ Space` capture |
| 5 pomodoros total | Tags UI gets revealed |
| 7 days of usage | Pro subscription first mentioned |

## Platform variations

### iOS

Insert a screen after Screen 4: "Add Tact to your Lock Screen" with an
animated demonstration. Lock Screen widget is the key entry point for
iOS users — guiding them increases activation 4–5x.

### macOS

Insert a screen after Screen 4: "Tact lives in your menu bar" with an
animation of the icon settling into the system menu bar position.
Without this step, users close the main window and think the app has
quit.

### watchOS

Single screen only: a screenshot of the Tact complication on a watch
face with one line of text: "Tap to focus. Spin the crown to set time."
No customization options — configuration happens on the iPhone.

## Default values

These are the settings new users get without making any choice:

| Setting | Default |
|---|---|
| Work duration | 25 min |
| Short break | 5 min |
| Long break | 15 min |
| Auto-start next segment | ON |
| End sound | Chime |
| Watch haptics | Strong |
| Theme | System (auto light/dark) |
| Daily goal | 4 pomodoros |
| First weekday | Locale-based |

## Empty states

Stats page before first pomodoro: a single line, "Your week starts
here." No fake data, no skeleton charts, no "Sample data" placeholders.
Showing empty data invites comparison; showing nothing at all sets the
expectation that the user is about to write the story.

After the first completed pomodoro, the stats view shows real data
(1 pomodoro, 5 minutes focused, etc.).

## Post-onboarding tooltips

| Trigger | Tooltip |
|---|---|
| First pomodoro completed | `⌥ Space` capture hint, near the title bar |
| Day 3 first open | "3 days in. Sync to your Watch?" — CloudKit setup |
| Day 7 first open | Weekly summary card appears for the first time |

After day 14, all tooltips end. Tact assumes the user has internalized
the product by then. No nagging.

## What completion feels like

When the user finishes their first pomodoro, do NOT show confetti or
fireworks. That's children's-app UX. Tact's reward is restrained:

- Background tint smoothly fades from focus-teal back to idle-gray
- Top of screen shows a small gray line: "1 pomodoro · 5m focused today"
- A soft Chime plays (≤1.2 s)
- Watch fires `.success` haptic if paired

The "completion is calm" pattern reinforces the brand at exactly the
moment users form their first emotional impression.
