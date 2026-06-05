# Tact — Project Overview

> Working name. See "Naming" section for validation status.

## What it is

A calm, multi-platform focus tool covering macOS, iPadOS, iOS, and
watchOS. Three modules:

1. **Timer** — multiple concurrent timers with a clean single-window UI.
2. **Pomodoro** — 25/5/long-break cycles, task binding, statistics.
3. **Quick capture** — global hotkey memo capture with smart detection,
   tied to the active focus context.

Plus: on-device AI weekly reflections (Pro tier).

## Origin

Forked from [michaelvillar/timer-app](https://github.com/michaelvillar/timer-app)
(MIT-licensed Swift macOS app), but being rewritten from scratch.
Reason: master is AppKit-only with custom NSView drawing, which doesn't
carry to iOS or watchOS. Pure SwiftUI from the start lets the three
platforms share ~70% of view code.

The master's visual identity (blue draggable arc) is being discarded
in favor of the new "state is environment" design language.

## Success metrics for v1.0

- 5,000 downloads in first 60 days (Mac App Store + iOS App Store)
- 8% Premium conversion rate
- 1.5% Pro subscription conversion rate
- Day-7 retention ≥ 35% (industry-good for productivity apps)
- App Store rating ≥ 4.5 in the first 100 reviews

## Naming

Working name is **Tact**. Validation status:

| Check | Status |
|---|---|
| App Store Connect name availability | TODO |
| USPTO trademark (Class 9 / 42) | TODO |
| EUIPO trademark | TODO |
| JPO trademark | TODO |
| tact.app domain | Likely taken; trytact.app as fallback |
| @tact handles on X, Instagram, Threads | TODO |

Backup names if Tact is unavailable:

1. **Ma (間)** — Japanese for "interval/pause". Stronger cultural fit
   for Tokyo market; harder for global recognition.
2. **Span** — Clean but plain.
3. **Lull** — Soft, may conflict with "rest" connotations.

See `docs/01-design.md` for the brand reasoning.

## Open source decision

Deferred to post-launch. Likely approach: open-source `TimerKit` (the
shared business logic) under MIT, keep app targets closed. This gives
the community something to extend while protecting the commercial
product. Decision deadline: 30 days post v1.0 launch.

## License attribution

This project derives from michaelvillar/timer-app (MIT). The MIT license
requires retaining the original copyright notice. The full master
license must be preserved in the About screen and in `LICENSES/` at
ship time, even though the codebase is being fully rewritten.
