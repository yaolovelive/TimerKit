# AI Weekly Report

The Pro-tier hero feature. A weekly reflection delivered every Sunday
evening (configurable) that surfaces patterns the user can't see
themselves.

## Design philosophy

The report is a brief letter, not a dashboard. Five sections, each
short:

1. **Headline** — one sentence describing the week's character
2. **Patterns** — 1–2 observations with specific evidence
3. **Worth a look** — an anomaly (omitted if none)
4. **A question** — one open-ended reflective prompt
5. **One small suggestion** — one concrete action for next week

Tone: calm, observational, never generic. Never "Great job, you focused
11 hours!" — always "You focused best between 9 and 11 AM. Four of your
five longest sessions started in that window."

## Architectural decision: on-device only for v1

Use Apple Foundation Models (`FoundationModels` framework, iOS 18+ /
macOS 15+). On Apple Intelligence-capable devices, the local 3B model
handles weekly reports.

Reasons:

- **Privacy:** memo contents never leave the device
- **Cost:** $0 per report at any user scale
- **Offline:** works on planes, in low signal
- **Brand fit:** matches Tact's "calm, private" positioning

For devices without Apple Intelligence (older iPhones, Intel Macs,
Apple Watch), use a rule-based template fallback. Still useful, just
not literary prose.

Cloud-based generation (Claude / GPT API) is deferred to v2+ and would
require explicit opt-in per user, with clear data handling disclosure.

## Structured output via `@Generable`

We don't render raw LLM text. We constrain the model to populate a
Swift struct using `@Generable`:

```swift
@Generable
public struct WeeklyReport {
    let headline: String
    let patterns: [Pattern]
    let anomaly: Anomaly?
    let reflectionQuestion: String
    let suggestion: Suggestion
}
```

The SwiftUI view renders the struct's fields, never raw model output.
This keeps the surface area predictable and limits "weird LLM moments"
from reaching users.

## Input data

Pre-aggregated in Swift before calling the model. See
`WeekAggregate` in `Sources/TimerKit/AI/WeeklyReportGenerator.swift`.

What gets included:

- Session counts and total focus minutes
- Sessions by day of week and hour bucket
- Top tags by focus minutes
- Completion rate per tag
- Memo counts by type
- Deltas vs previous week

What does NOT get included:

- Raw memo bodies (too sensitive)
- Tag names if they contain PII (TODO: add a sanitizer)
- Any identifiers that could leak across users

## System prompt

```
You are writing a brief weekly reflection for a focus tracking app user.
Style: calm, observational, specific. Never generic praise.
Always reference the user's actual tag names and time windows.
If patterns are weak or absent, say so honestly — do not invent.
Keep each section to one or two sentences.
```

Tuned over time. Keep this in a versioned constant so we can A/B test
prompt variations.

## Delivery

`BGTaskScheduler` runs Sunday 03:00 local time, generates and caches
the report. `UNUserNotificationCenter` schedules a notification for
user-chosen delivery time (default 19:00 Sunday).

Notification body: "Your week, briefly summarized."

Tap → opens the cached report view directly.

If background generation fails (no Apple Intelligence available at the
moment, low battery, etc.), regenerate on-demand when user opens the
report. ~2–3 s with skeleton loading.

## Edge cases and product copy

| Situation | Behavior |
|---|---|
| < 3 days of data | Don't generate; show "Come back next week" |
| Apple Intelligence not available | Rule-based template fallback |
| Zero sessions (vacation) | "Resting is part of the rhythm" — no guilt |
| Identical week to last | "A consistent week. Sometimes that's the win." |
| Backgrond gen failed | Regenerate on open with loading state |

## Save reflection feature

The report's reflective question gets a `Save reflection` button. The
user types their answer, and it's saved as a `Memo` with type
`.reflection`. Over time, this becomes a long-tail archive of weekly
self-reflections — high emotional value, near-zero implementation cost.

## Monthly and quarterly retrospectives (v1.1+)

Same architecture, longer window. The structured output schema gets a
`monthlyTrajectory` field describing direction-of-travel across the
past few months. Quarterly deferred to v2.

## Pro tier positioning

The weekly report is the marketing message, not the only feature, of
Pro. Pro tier bundles:

- AI weekly report
- AI monthly retrospective
- Smart focus-time suggestions
- White noise expansion pack
- Custom state-color themes
- Priority CloudKit sync

Marketing line: **"Tact learns your rhythm and reflects it back."**
